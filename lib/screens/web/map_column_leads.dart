import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/screens/web/imported_leads.dart';

enum ColumnStatus { matched, unmapped, skipped }

class MapColumnsScreen extends StatefulWidget {
  const MapColumnsScreen({
    super.key,
    required this.excelHeaders,
    required this.sampleRow,
    required this.previewRows, 
  });

  final List<String> excelHeaders;
  final Map<String, String> sampleRow;

  /// ALL parsed rows from Excel
  final List<Map<String, String>> previewRows;

  @override
  State<MapColumnsScreen> createState() => _MapColumnsScreenState();
}

class _MapColumnsScreenState extends State<MapColumnsScreen> {
  // ================= CRM CONFIG =================

  final List<String> requiredFields = [
    "Phone Number",
  ];

  final List<String> optionalFields = [
    "Full Name",
    "Email",
    "Company",
    "City",
    "Interest Level",
    "Source",
  ];

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
      final match = [
        ...requiredFields,
        ...optionalFields,
      ].firstWhere(
        (f) => f.toLowerCase() == header.toLowerCase(),
        orElse: () => "",
      );

      if (match.isNotEmpty) {
        columnMapping[header] = match;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Map Columns for Import",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          "Match the columns from your uploaded file to the corresponding CRM fields.",
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

    final double progress = total == 0 ? 0.0 : mapped / total;

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
          ...widget.excelHeaders.map(_mappingRow).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("EXCEL HEADER (SOURCE)")),
          Expanded(flex: 3, child: Text("LEAD FIELD (TARGET)")),
          Expanded(flex: 1, child: Text("SKIP")),
        ],
      ),
    );
  }

  Widget _mappingRow(String header) {
    final status = columnStatus[header]!;
    final isUnmapped = status == ColumnStatus.unmapped;
    final isSkipped = status == ColumnStatus.skipped;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          // SOURCE COLUMN
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(header,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Sample: "${widget.sampleRow[header] ?? ""}"',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // TARGET FIELD
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: columnMapping[header],
              hint: const Text("What is this column?"),
              items: [
                ...requiredFields,
                ...optionalFields,
              ]
                  .map(
                    (f) =>
                        DropdownMenuItem(value: f, child: Text(f)),
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
                errorText:
                    isUnmapped ? "Please map this column" : null,
              ),
            ),
          ),

          // SKIP TOGGLE
          Expanded(
            flex: 1,
            child: Switch(
              value: isSkipped,
              onChanged: (v) {
                setState(() {
                  if (v) {
                    columnStatus[header] = ColumnStatus.skipped;
                    columnMapping[header] = null;
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
    final bool hasRequiredMapped = requiredFields.every(
      (f) => columnMapping.values.contains(f),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!hasRequiredMapped)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  "Phone Number is required to import leads",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ElevatedButton(
              onPressed: hasRequiredMapped ? _confirmMapping : null,
              child: const Text("Confirm Mapping"),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmMapping() {
  final importedLeads = buildImportedLeads();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ImportedLeadsWebScreen(
        importedLeads: importedLeads,
      ),
    ),
  );
}

List<Map<String, dynamic>> buildImportedLeads() {
  return widget.previewRows.map((row) {
    final Map<String, dynamic> lead = {};

    columnMapping.forEach((excelHeader, crmField) {
      if (crmField != null) {
        lead[crmField] = row[excelHeader];
      }
    });

    // default system fields
    lead["status"] = "New";
    lead["importDate"] =
        DateTime.now().toIso8601String().split("T").first;

    return lead;
  }).toList();
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
