import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class ImportedLeadsWebScreen extends StatefulWidget {
  const ImportedLeadsWebScreen({
    super.key,
    required this.importedLeads,
  });

  /// importedLeads MUST already be in backend format:
  /// { name, phone, email?, company? }
  final List<Map<String, dynamic>> importedLeads;

  @override
  State<ImportedLeadsWebScreen> createState() =>
      _ImportedLeadsWebScreenState();
}

class _ImportedLeadsWebScreenState
    extends State<ImportedLeadsWebScreen> {
  final String apiUrl =
      "http://127.0.0.1:3000/api/leads/batch";
  final int campaignId = 1;

  final Set<int> selectedRows = {};
  bool isImporting = false;

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 5,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _table(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Confirm Imported Leads",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ElevatedButton.icon(
          onPressed: isImporting ? null : _importLeads,
          icon: const Icon(Icons.upload),
          label: Text(
            selectedRows.isEmpty
                ? "Import All"
                : "Import Selected (${selectedRows.length})",
          ),
        ),
      ],
    );
  }

  Widget _table() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...widget.importedLeads
              .asMap()
              .entries
              .map(_tableRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const [
          SizedBox(width: 40),
          Expanded(child: Text("NAME")),
          Expanded(child: Text("PHONE")),
          Expanded(child: Text("EMAIL")),
          Expanded(child: Text("COMPANY")),
        ],
      ),
    );
  }

  Widget _tableRow(MapEntry<int, Map<String, dynamic>> entry) {
    final index = entry.key;
    final lead = entry.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Checkbox(
            value: selectedRows.contains(index),
            onChanged: (v) {
              setState(() {
                v == true
                    ? selectedRows.add(index)
                    : selectedRows.remove(index);
              });
            },
          ),
          Expanded(child: Text(lead["name"] ?? "")),
          Expanded(child: Text(lead["phone"] ?? "")),
          Expanded(child: Text(lead["email"] ?? "—")),
          Expanded(child: Text(lead["company"] ?? "—")),
        ],
      ),
    );
  }

  Future<void> _importLeads() async {
    final indices = selectedRows.isEmpty
        ? List.generate(widget.importedLeads.length, (i) => i)
        : selectedRows.toList();

    final payload = indices
    .map((i) {
      final l = widget.importedLeads[i];

      final name = l["name"]?.toString().trim();
      final phone = l["phone"]?.toString().trim();

      if (name == null ||
          name.isEmpty ||
          phone == null ||
          phone.isEmpty) {
        return null; // DROP invalid row
      }

      return {
        "name": name,
        "phone": phone,
        "email": l["email"]?.toString().trim(),
        "company": l["company"]?.toString().trim(),
      };
    })
    .whereType<Map<String, dynamic>>() // removes nulls
    .toList();

    if (payload.isEmpty) return;

    setState(() => isImporting = true);

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "campaign_id": campaignId,
          "leads": payload,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"])),
        );
        Navigator.pop(context);
      } else {
        throw Exception();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Import failed")),
      );
    } finally {
      setState(() => isImporting = false);
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}
