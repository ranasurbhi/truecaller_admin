import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class CampaignManagementWebScreen extends StatefulWidget {
  const CampaignManagementWebScreen({super.key});

  @override
  State<CampaignManagementWebScreen> createState() =>
      _CampaignManagementWebScreenState();
}

class _CampaignManagementWebScreenState
    extends State<CampaignManagementWebScreen> {
  static const String baseUrl = "http://localhost:3000";

  List<Map<String, dynamic>> campaigns = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  // ================= API FETCH =================

  Future<void> _loadCampaigns() async {
    setState(() => loading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/campaigns"));

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        setState(() {
          campaigns = (json["data"] as List).map((c) {
            return {
              "id": c["id"],
              "name": c["campaign_name"],
              "status": _mapStatus(c["status"]),
              "duration": "${c["start_date"]} - ${c["end_date"]}",
              "progress": 0.0, // placeholder (logic later)
              "performance": 0.0, // placeholder
              "assignedTeam":
                  (c["agents"] as List?)
                      ?.map<Map<String, dynamic>>(
                        (a) => {
                          "name": a["name"] ?? "",
                          "avatar": a["profile_image"] ?? "",
                        },
                      )
                      .toList() ??
                  [],
            };
          }).toList();
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (e) {
      debugPrint("Campaign load error: $e");
      setState(() => loading = false);
    }
  }

  String _mapStatus(String status) {
    switch (status) {
      case "active":
        return "Active";
      case "completed":
        return "Completed";
      case "draft":
        return "Paused";
      default:
        return "Unknown";
    }
  }

  // ================= EXPORT =================

  void _exportCampaigns() {
    if (campaigns.isEmpty) return;

    String csv = "Campaign Name,Campaign ID,Status,Duration,Assigned Team\n";

    for (final c in campaigns) {
      final teamNames = (c["assignedTeam"] as List)
          .map((m) => m["name"])
          .join(" | ");

      csv +=
          "${c['name']},${c['id']},${c['status']},${c['duration']},$teamNames\n";
    }

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "campaign_report.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 2,
      child: SingleChildScrollView(
        child: Padding(
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
              "Dashboard > Campaigns",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 6),
            Text(
              "Campaign Management",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          label: const Text(
            "Create New Campaign",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
        _statCard("Total Campaigns", campaigns.length.toString(), ""),
        _statCard(
          "Active Campaigns",
          campaigns.where((c) => c["status"] == "Active").length.toString(),
          "",
        ),
        _statCard(
          "Completed",
          campaigns.where((c) => c["status"] == "Completed").length.toString(),
          "",
        ),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
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
              hintText: "Search by campaign name or ID...",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportCampaigns,
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
          ...campaigns.map(_tableRow).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("CAMPAIGN NAME")),
          Expanded(flex: 2, child: Text("STATUS")),
          Expanded(flex: 3, child: Text("DURATION")),
          Expanded(flex: 3, child: Text("ASSIGNED TEAM")),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/campaign-lead',
                      arguments: {
                        "campaignId": c["id"],
                        "campaignName": c["campaign_name"],
                      },
                    );
                  },

                  child: Text(
                    c["name"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "ID: ${c["id"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _statusChip(c["status"])),
          Expanded(
            flex: 3,
            child: Text(
              c["duration"],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(flex: 3, child: assignedTeamAvatars(c["assignedTeam"])),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Active":
        color = Colors.green;
        break;
      case "Paused":
        color = Colors.orange;
        break;
      case "Completed":
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget assignedTeamAvatars(List<Map<String, dynamic>> team) {
    if (team.isEmpty)
      return const Text("-", style: TextStyle(color: Colors.grey));

    const double avatarSize = 28;
    const double overlap = 18;

    final int visibleCount = team.length > 3 ? 3 : team.length;
    final int remaining = team.length - visibleCount;

    return SizedBox(
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  team[i]["name"][0],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: visibleCount * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey.shade400,
                child: Text(
                  "+$remaining",
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
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
