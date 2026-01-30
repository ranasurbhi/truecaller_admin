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
  static const String baseUrl = "http://localhost:3000";

  List<Lead> leads = [];
  bool loading = true;

  late int campaignId;
  late String campaignName;

  bool _initialized = false;

  /* ================= FETCH LEADS ================= */

  Future<void> _loadLeads() async {
    setState(() => loading = true);

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/web/campaigns/$campaignId/leads"),
      );

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        setState(() {
          leads = (json["data"] as List).map((e) => Lead.fromJson(e)).toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Load leads error: $e");
      setState(() => loading = false);
    }
  }

  /* ================= EXPORT ================= */

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

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    campaignId = args["campaignId"];
    campaignName = args["campaignName"];

    if (!_initialized) {
      _initialized = true;
      _loadLeads();
    }

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
            loading
                ? const Center(child: CircularProgressIndicator())
                : _tableCard(),
          ],
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Campaigns > $campaignName > Leads",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              onPressed: _exportLeads,
              icon: const Icon(Icons.download),
              label: const Text("Export CSV"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Add Lead"),
            ),
          ],
        ),
      ],
    );
  }

  /* ================= STATS ================= */

  Widget _statsRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard("Total Leads", leads.length.toString()),
        _statCard(
          "Converted",
          leads.where((l) => l.status == "Converted").length.toString(),
        ),
        _statCard(
          "Interested",
          leads.where((l) => l.status == "Interested").length.toString(),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /* ================= FILTERS ================= */

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
      ],
    );
  }

  /* ================= TABLE ================= */

  Widget _tableCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...leads.map(_tableRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
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
    return MouseRegion(
      cursor: SystemMouseCursors.click, // 🖱️ web UX
      child: InkWell(
        onTap: () {
          // 🔥 NAVIGATION TO LEAD ACTIVITY
          Navigator.pushNamed(
            context,
            '/lead-activity',
            arguments: {"leadId": l.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Converted":
        color = Colors.green;
        break;
      case "Interested":
        color = Colors.orange;
        break;
      case "Call Back":
        color = Colors.purple;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  /* ================= SHARED ================= */

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}

/* ================= MODEL ================= */

class Lead {
  final int id; 
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final String telecaller;
  final String lastActivity;

  Lead({
    required this.id,
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
      id: json["id"], // 🔥 BACKEND MUST SEND THIS
      name: json["name"] ?? "",
      company: json["company"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      status: json["status"] ?? "New Lead",
      telecaller: json["telecaller"] ?? "Unassigned",
      lastActivity: json["lastActivity"] ?? "-",

    );
  }
}
