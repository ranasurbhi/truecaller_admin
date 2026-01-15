import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/services/api_service2.dart';

enum ColumnStatus { matched, unmapped, skipped }

class MapColumnsScreen extends StatefulWidget {
  final List<String> excelHeaders;
  final Map<String, String> sampleRow;
  final List<Map<String, String>> previewRows;
  final int campaignId;

  const MapColumnsScreen({
    super.key,
    required this.excelHeaders,
    required this.sampleRow,
    required this.previewRows,
    required this.campaignId,
  });

  @override
  State<MapColumnsScreen> createState() => _MapColumnsScreenState();
}

class _MapColumnsScreenState extends State<MapColumnsScreen> {
  final List<String> requiredFields = ["Phone Number"];
  final List<String> optionalFields = [
    "Full Name",
    "Email",
    "Company",
    "City",
    "Interest Level",
    "Source"
  ];

  final Map<String, String?> columnMapping = {};
  final Map<String, ColumnStatus> columnStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeMapping();
  }

  void _initializeMapping() {
    for (final header in widget.excelHeaders) {
      final match = [...requiredFields, ...optionalFields]
          .firstWhere(
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

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Map Columns for Import",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "Match the columns from your uploaded file to the CRM fields.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _mappingTable(),
            const SizedBox(height: 20),
            _footerActions(),
          ],
        ),
      ),
    );
  }

  Widget _mappingTable() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("EXCEL HEADER")),
                Expanded(flex: 3, child: Text("LEAD FIELD")),
                Expanded(flex: 1, child: Text("SKIP")),
              ],
            ),
          ),
          const Divider(height: 1),
          ...widget.excelHeaders.map(_mappingRow).toList(),
        ],
      ),
    );
  }

  Widget _mappingRow(String header) {
    final status = columnStatus[header]!;
    final isSkipped = status == ColumnStatus.skipped;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: columnMapping[header],
              hint: const Text("Map column"),
              items: [...requiredFields, ...optionalFields]
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: isSkipped
                  ? null
                  : (val) {
                setState(() {
                  columnMapping[header] = val;
                  columnStatus[header] = ColumnStatus.matched;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: isSkipped,
              onChanged: (v) {
                setState(() {
                  columnStatus[header] =
                  v ? ColumnStatus.skipped : ColumnStatus.unmapped;
                  if (v) columnMapping[header] = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerActions() {
    final hasRequiredMapped =
    requiredFields.every((f) => columnMapping.values.contains(f));

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: hasRequiredMapped ? _uploadLeadsToBackend : null,
          child: const Text("Upload & Assign Leads"),
        ),
      ],
    );
  }

  Future<void> _uploadLeadsToBackend() async {
    // CRM_FIELD -> EXCEL_HEADER
    final Map<String, String> mapping = {};
    columnMapping.forEach((excelHeader, crmField) {
      if (crmField != null) {
        mapping[crmField] = excelHeader;
      }
    });

    // Build backend-ready leads
    final List<Map<String, dynamic>> leads = widget.previewRows.map((row) {
      return {
        "name": row[mapping["Full Name"]] ?? "Unknown",
        "phone": row[mapping["Phone Number"]] ?? "",
        "email": mapping["Email"] != null ? row[mapping["Email"]] : null,
        "company": mapping["Company"] != null ? row[mapping["Company"]] : null,
      };
    }).toList();

    if (leads.any((l) => l["phone"] == "")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is required")),
      );
      return;
    }

    final res = await ApiService2.uploadLeadsBatch(
      widget.campaignId,
      leads,
    );

    if (!mounted) return;

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"])),
      );
      Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Upload failed")),
      );
    }
  }


  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
