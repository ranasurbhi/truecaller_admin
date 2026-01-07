import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class UploadLeadsScreen extends StatefulWidget {
  const UploadLeadsScreen({super.key});

  @override
  State<UploadLeadsScreen> createState() => _UploadLeadsScreenState();
}

class _UploadLeadsScreenState extends State<UploadLeadsScreen> {
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
      selectedIndex: 5,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upload Leads Data",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Import your telecalling lists to assign to agents. Supported formats: .xlsx, .csv",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text("Sample Template"),
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
    final active = currentStep == step || currentStep > step;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor:
              active ? Colors.blue : Colors.grey.shade300,
          child: Text(
            "$step",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Divider(color: Colors.grey.shade300),
    );
  }

  // ================= UPLOAD =================

  Widget _uploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(dashed: true),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload,
              size: 40, color: Colors.blue),
          const SizedBox(height: 12),
          const Text(
            "Click to upload or drag and drop",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            "XLSX, CSV or XLS (Max 10MB)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
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
      currentStep = 2;
      previewHeaders.clear();
      previewRows.clear();
    });

    if (file.extension == "csv") {
      _parseCsv(file.bytes!);
    } else {
      _parseExcel(file.bytes!);
    }
  }

  // ================= PARSING =================

  void _parseCsv(Uint8List bytes) {
    final csvString = String.fromCharCodes(bytes);
    final rows = const CsvToListConverter().convert(csvString);

    if (rows.isEmpty) return;

    setState(() {
      previewHeaders =
          rows.first.map((e) => e.toString()).toList();

      previewRows = rows.skip(1).map((row) {
        final Map<String, String> map = {};
        for (int i = 0; i < previewHeaders.length; i++) {
          map[previewHeaders[i]] =
              i < row.length ? row[i].toString() : "";
        }
        return map;
      }).toList();
    });
  }

  void _parseExcel(Uint8List bytes) {
    final excelFile = excel.Excel.decodeBytes(bytes);

    final sheet = excelFile.tables.values.first;

    if (sheet == null || sheet.rows.isEmpty) return;

    final headers = sheet.rows.first
        .map((cell) => cell?.value.toString() ?? "")
        .toList();

    final rows = sheet.rows.skip(1).map((row) {
      final Map<String, String> map = {};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] =
            i < row.length ? row[i]?.value.toString() ?? "" : "";
      }
      return map;
    }).toList();

    setState(() {
      previewHeaders = headers;
      previewRows = rows;
    });
  }

  // ================= PREVIEW =================

  Widget _filePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _uploadedFileTile(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("File Preview",
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text("Displaying first 5 rows",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        _previewTable(),
        const SizedBox(height: 20),
        _footerActions(),
      ],
    );
  }

  Widget _uploadedFileTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(fileName ?? "",
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                fileBytes = null;
                fileName = null;
                previewHeaders.clear();
                previewRows.clear();
                currentStep = 1;
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _previewTable() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...previewRows.take(5).map(_tableRow).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: previewHeaders
            .map((h) => Expanded(
                  child: Text(
                    h.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _tableRow(Map<String, String> row) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: previewHeaders
            .map((h) => Expanded(
                  child: Text(
                    row[h] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ================= FOOTER =================

  Widget _footerActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () {},
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => currentStep = 3);
          },
          child: const Text("Next: Map Columns"),
        ),
      ],
    );
  }

  // ================= SHARED =================

  BoxDecoration _cardDecoration({bool dashed = false}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
    );
  }
}
