import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class CampaignLeadsScreen extends StatefulWidget {
  const CampaignLeadsScreen({super.key});

  @override
  State<CampaignLeadsScreen> createState() => _CampaignLeadsScreenState();
}

class _CampaignLeadsScreenState extends State<CampaignLeadsScreen> {
  List<Lead> leads = [];
  bool loading = true;
  bool _initialized = false;

  int campaignId = 0;
  String campaignName = '';

  // ================= INIT =================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;

    if (args is Map<String, dynamic>) {
      campaignId = args['campaignId'] ?? 0;
      campaignName = args['campaignName'] ?? 'Campaign';
    }

    if (campaignId > 0) {
      _fetchLeads();
    } else {
      setState(() => loading = false);
    }
  }

  // ================= API =================

  Future<void> _fetchLeads() async {
    setState(() {
      loading = true;
      leads = [];
    });

    final url = "http://localhost:3000/campaigns/$campaignId/leads";

    try {
      final res = await http.get(Uri.parse(url));
      final json = jsonDecode(res.body);

      if (json['success'] == true && json['data'] is List) {
        setState(() {
          leads = (json['data'] as List).map((e) => Lead.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Fetch leads error: $e");
    }

    setState(() => loading = false);
  }

  // ================= EXPORT =================

  void _exportLeads() {
    if (leads.isEmpty) return;

    String csv = "Name,Company,Phone,Email,Status,Telecaller,Last Activity\n";

    for (final l in leads) {
      csv +=
          "${l.name},${l.company},${l.phone},${l.email},${l.status},${l.telecaller},${l.lastActivity}\n";
    }

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "campaign_leads.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // ================= IMPORT (UI ONLY) =================

  void _importLeads() {
    final uploadInput = html.FileUploadInputElement()..accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((_) {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsText(file);

      reader.onLoadEnd.listen((_) {
        final content = reader.result as String;
        final lines = const LineSplitter().convert(content);

        final imported = lines.skip(1).map((line) {
          final values = line.split(',');

          return Lead(
            name: values.isNotEmpty ? values[0] : '',
            company: values.length > 1 ? values[1] : '',
            phone: values.length > 2 ? values[2] : '',
            email: values.length > 3 ? values[3] : '',
            status: values.length > 4 ? values[4] : 'New Lead',
            telecaller: values.length > 5 ? values[5] : 'Unassigned',
            lastActivity: values.length > 6 ? values[6] : '-',
          );
        }).toList();

        setState(() {
          leads.addAll(imported);
        });
      });
    });
  }

  Future<void> _submitLead(
    String name,
    String phone,
    String email,
    String company,
  ) async {
    final url = "http://localhost:3000/campaigns/$campaignId/leads";

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
          "company": company,
        }),
      );

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        _fetchLeads(); // 🔥 refresh table immediately
      }
    } catch (e) {
      debugPrint("Add lead error: $e");
    }
  }

  void _openAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final companyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Lead"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: "Company"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitLead(
                nameCtrl.text,
                phoneCtrl.text,
                emailCtrl.text,
                companyCtrl.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Save Lead"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTableToBackend() async {
    if (leads.isEmpty) return;

    final url = "http://localhost:3000/campaigns/$campaignId/leads/bulk";

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "leads": leads
              .map(
                (l) => {
                  "name": l.name,
                  "company": l.company,
                  "phone": l.phone,
                  "email": l.email,
                  "status": l.status,
                  "telecaller": l.telecaller,
                },
              )
              .toList(),
        }),
      );

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Saved ${json['count']} leads")));

        // Optional: refresh from DB
        _fetchLeads();
      }
    } catch (e) {
      debugPrint("Bulk save error: $e");
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 24),
            _statsRow(),
            const SizedBox(height: 20),
            _filtersRow(),
            const SizedBox(height: 20),
            _tableCard(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Campaigns > Leads",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "$campaignName Leads",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _importLeads,
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _openAddLeadDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Lead"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _saveTableToBackend,
              icon: const Icon(Icons.save),
              label: const Text("Save to Campaign"),
            ),
          ],
        ),
      ],
    );
  }

  // ================= STATS =================

  Widget _statsRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard("Total Leads", leads.length.toString(), "Campaign total"),
        _statCard("Contacted", "-", "-"),
        _statCard("Qualified Leads", "-", "-"),
        _statCard("Avg Call Duration", "-", "-"),
      ],
    );
  }

  Widget _statCard(String title, String value, String subtitle) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name, phone or email...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportLeads,
          icon: const Icon(Icons.download),
          label: const Text("Export"),
        ),
      ],
    );
  }

  // ================= TABLE =================

  Widget _tableCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (leads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No leads found"),
            )
          else
            ...leads.map(_tableRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("LEAD")),
          Expanded(flex: 3, child: Text("CONTACT")),
          Expanded(flex: 2, child: Text("STATUS")),
          Expanded(flex: 2, child: Text("TELECALLER")),
          Expanded(flex: 2, child: Text("LAST ACTIVITY")),
        ],
      ),
    );
  }

  Widget _tableRow(Lead l) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  l.company,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.phone),
                Text(
                  l.email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _statusChip(l.status)),
          Expanded(flex: 2, child: Text(l.telecaller)),
          Expanded(flex: 2, child: Text(l.lastActivity)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color =
        {
          "Interested": Colors.orange,
          "Converted": Colors.green,
          "Call Back": Colors.purple,
          "New Lead": Colors.blue,
        }[status] ??
        Colors.grey;

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
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

// ================= MODEL =================

class Lead {
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final String telecaller;
  final String lastActivity;

  Lead({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.status,
    required this.telecaller,
    required this.lastActivity,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'New Lead',
      telecaller: json['telecaller']?.toString() ?? 'Unassigned',
      lastActivity: json['last_activity']?.toString() ?? '-',
    );
  }
}
