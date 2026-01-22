import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/screens/web/map_column_leads.dart';

class UploadLeadsScreen extends StatefulWidget {
  const UploadLeadsScreen({super.key});

  @override
  State<UploadLeadsScreen> createState() => _UploadLeadsScreenState();
}

class _UploadLeadsScreenState extends State<UploadLeadsScreen> {
  // ================= BACKEND CONTRACT =================
  /// Only these fields will EVER go to backend
  static const List<String> backendFields = [
    "name",
    "phone",
    "email",
    "company",
  ];

  // ================= STATE =================
  int currentStep = 1;

  Uint8List? fileBytes;
  String? fileName;

  List<String> previewHeaders = [];
  List<Map<String, String>> previewRows = [];

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _stepIndicator(),
            const SizedBox(height: 24),
            _uploadCard(),
            if (previewRows.isNotEmpty) ...[
              const SizedBox(height: 24),
              _filePreviewSection(),
            ],
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
          "Upload Leads Data",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          "Upload XLSX or CSV files. Columns will be mapped in the next step.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= STEPS =================
  Widget _stepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _stepItem(1, "Upload"),
          _stepDivider(),
          _stepItem(2, "Map Columns"),
          _stepDivider(),
          _stepItem(3, "Confirm"),
        ],
      ),
    );
  }

  Widget _stepItem(int step, String label) {
    final active = currentStep >= step;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? Colors.blue : Colors.grey.shade300,
          child: Text("$step",
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(child: Divider(color: Colors.grey.shade300));
  }

  // ================= UPLOAD =================
  Widget _uploadCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload, size: 40, color: Colors.blue),
          const SizedBox(height: 12),
          const Text("Upload CSV or XLSX"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text("Browse Files"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ["csv", "xlsx", "xls"],
    );

    if (result == null) return;

    final file = result.files.single;

    setState(() {
      fileName = file.name;
      fileBytes = file.bytes;
      previewHeaders.clear();
      previewRows.clear();
      currentStep = 2;
    });

    if (file.extension == "csv") {
      _parseCsv(file.bytes!);
    } else {
      _parseExcel(file.bytes!);
    }
  }

  // ================= PARSING =================
  void _parseCsv(Uint8List bytes) {
    final rows =
        const CsvToListConverter().convert(String.fromCharCodes(bytes));
    if (rows.isEmpty) return;

    final headers =
        rows.first.map((e) => e.toString().trim()).toList();

    final dataRows = rows.skip(1).map((row) {
      final map = <String, String>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] =
            i < row.length ? row[i]?.toString() ?? "" : "";
      }
      return map;
    }).toList();

    setState(() {
      previewHeaders = headers;
      previewRows = dataRows;
    });
  }

  void _parseExcel(Uint8List bytes) {
    final excelFile = excel.Excel.decodeBytes(bytes);
    final sheet = excelFile.tables.values.first;
    if (sheet == null || sheet.rows.isEmpty) return;

    final headers = sheet.rows.first
        .map((c) => c?.value.toString().trim() ?? "")
        .toList();

    final dataRows = sheet.rows.skip(1).map((row) {
      final map = <String, String>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] =
            i < row.length ? row[i]?.value.toString() ?? "" : "";
      }
      return map;
    }).toList();

    setState(() {
      previewHeaders = headers;
      previewRows = dataRows;
    });
  }

  // ================= PREVIEW =================
  Widget _filePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Preview (first 5 rows)",
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _previewTable(),
        const SizedBox(height: 20),
        _footerActions(),
      ],
    );
  }

  Widget _previewTable() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...previewRows.take(5).map(_tableRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: previewHeaders
            .map((h) => Expanded(child: Text(h.toUpperCase())))
            .toList(),
      ),
    );
  }

  Widget _tableRow(Map<String, String> row) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: previewHeaders
            .map((h) => Expanded(child: Text(row[h] ?? "")))
            .toList(),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _footerActions() {
    final hasName =
        previewHeaders.any((h) => h.toLowerCase().contains("name"));
    final hasPhone =
        previewHeaders.any((h) => h.toLowerCase().contains("phone"));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: (!hasName || !hasPhone)
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapColumnsScreen(
                        excelHeaders: previewHeaders,
                        previewRows: previewRows,
                        backendFields: backendFields,
                      ),
                    ),
                  );
                },
          child: const Text("Next: Map Columns"),
        ),
      ],
    );
  }

  // ================= SHARED =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}
