import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/screens/web/imported_leads.dart';

enum ColumnStatus { matched, unmapped, skipped }

class MapColumnsScreen extends StatefulWidget {
  const MapColumnsScreen({
    super.key,
    required this.excelHeaders,
    required this.previewRows,
    required this.backendFields,
  });

  final List<String> excelHeaders;
  final List<Map<String, String>> previewRows;

  /// Backend-supported fields ONLY
  final List<String> backendFields;

  @override
  State<MapColumnsScreen> createState() => _MapColumnsScreenState();
}

class _MapColumnsScreenState extends State<MapColumnsScreen> {
  // ================= BACKEND FIELDS =================

  /// backendKey -> label
  final Map<String, String> backendFieldLabels = {
    "name": "Full Name",
    "phone": "Phone Number",
    "email": "Email",
    "company": "Company",
  };

  // phone is required
  final List<String> requiredBackendFields = ["name", "phone"];

  // ================= STATE =================

  final Map<String, String?> columnMapping = {};
  final Map<String, ColumnStatus> columnStatus = {};

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _initializeMapping();
  }

  void _initializeMapping() {
    for (final header in widget.excelHeaders) {
      final match = backendFieldLabels.entries.firstWhere(
        (e) => e.value.toLowerCase() == header.toLowerCase(),
        orElse: () => const MapEntry("", ""),
      );

      if (match.key.isNotEmpty) {
        columnMapping[header] = match.key;
        columnStatus[header] = ColumnStatus.matched;
      } else {
        columnMapping[header] = null;
        columnStatus[header] = ColumnStatus.unmapped;
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _progressSection(),
            const SizedBox(height: 24),
            _mappingTable(),
            const SizedBox(height: 20),
            _footerActions(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Map Columns for Import",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          "Map your file columns to lead fields required by the system.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= PROGRESS =================

  Widget _progressSection() {
    final total = widget.excelHeaders.length;
    final mapped =
        columnStatus.values.where((s) => s == ColumnStatus.matched).length;

    final progress = total == 0 ? 0.0 : mapped / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toInt()}% columns mapped",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ================= TABLE =================

  Widget _mappingTable() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...widget.excelHeaders.map(_mappingRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("EXCEL COLUMN")),
          Expanded(flex: 3, child: Text("MAP TO FIELD")),
          Expanded(flex: 1, child: Text("SKIP")),
        ],
      ),
    );
  }

  Widget _mappingRow(String header) {
    final status = columnStatus[header]!;
    final isSkipped = status == ColumnStatus.skipped;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Excel column
          Expanded(
            flex: 3,
            child: Text(header,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),

          // Backend field dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: columnMapping[header],
              hint: const Text("Select field"),
              items: backendFieldLabels.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: isSkipped
                  ? null
                  : (value) {
                      setState(() {
                        columnMapping[header] = value;
                        columnStatus[header] = ColumnStatus.matched;
                      });
                    },
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Skip toggle
          Expanded(
            flex: 1,
            child: Switch(
              value: isSkipped,
              onChanged: (v) {
                setState(() {
                  if (v) {
                    columnMapping[header] = null;
                    columnStatus[header] = ColumnStatus.skipped;
                  } else {
                    columnStatus[header] = ColumnStatus.unmapped;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= FOOTER =================

  Widget _footerActions() {
    final hasRequired = requiredBackendFields.every(
      (f) => columnMapping.values.contains(f),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back"),
        ),
        ElevatedButton(
          onPressed: hasRequired ? _confirmMapping : null,
          child: const Text("Confirm Mapping"),
        ),
      ],
    );
  }

  // ================= CONFIRM =================

  void _confirmMapping() {
    final importedLeads = widget.previewRows.map((row) {
      final Map<String, dynamic> lead = {};

      columnMapping.forEach((excelHeader, backendKey) {
        if (backendKey != null) {
          final value = row[excelHeader]?.trim();
if (value != null && value.isNotEmpty && value != "null") {
  lead[backendKey] = value;
}

        }
      });

      return lead;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImportedLeadsWebScreen(
          importedLeads: importedLeads,
        ),
      ),
    );
  }

  // ================= SHARED =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
