import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'dart:convert';
import 'dart:html' as html;

class CampaignManagementWebScreen extends StatefulWidget {
  const CampaignManagementWebScreen({super.key});

  @override
  State<CampaignManagementWebScreen> createState() =>
      _CampaignManagementWebScreenState();
}

class _CampaignManagementWebScreenState
    extends State<CampaignManagementWebScreen> {
  final List<Map<String, dynamic>> campaigns = [
    {
      "name": "Q4 Renewal Drive",
      "id": "CMP-2023-001",
      "status": "Active",
      "duration": "Oct 1 - Dec 31\n32 days left",
      "progress": 0.68,
      "performance": 18.2,
      "assignedTeam": [
        {"name": "Jane", "avatar": ""},
        {"name": "Mark", "avatar": ""},
        {"name": "Alex", "avatar": ""},
        {"name": "Ryan", "avatar": ""},
      ],
    },
    {
      "name": "Flash Sale Outreach",
      "id": "CMP-2023-014",
      "status": "Paused",
      "duration": "Nov 10 - Nov 15\nHold",
      "progress": 0.45,
      "performance": 12.4,
      "assignedTeam": [
        {"name": "Jane", "avatar": ""},
        {"name": "Steve", "avatar": ""},
      ],
    },
  ];
  void _exportCampaigns() {
    String csv =
        "Campaign Name,Campaign ID,Status,Duration,Assigned Team,Progress %,Performance %\n";

    for (final c in campaigns) {
      final teamNames = (c["assignedTeam"] as List)
          .map((m) => m["name"])
          .join(" | ");

      csv +=
          "${c['name']},${c['id']},${c['status']},${c['duration'].replaceAll('\n', ' ')},$teamNames,${(c['progress'] * 100).toInt()}%,${c['performance']}%\n";
    }

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "campaign_report.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

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
              _tableCard(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
        _statCard("Active Campaigns", "12", "+2 this week"),
        _statCard("Calls Today", "1,240", "+12% vs yest."),
        _statCard("Conversion Rate", "18.5%", "+1.2% vs target"),
        _statCard("Available Agents", "8", "out of 24 total"),
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
        _filterButton("Status: All"),
        const SizedBox(width: 12),
        _filterButton("This Month"),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _exportCampaigns,
          icon: const Icon(Icons.download),
          label: const Text("Export"),
        ),
      ],
    );
  }

  Widget _filterButton(String text) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list),
      label: Text(text),
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
          const Divider(height: 1),
          _pagination(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("CAMPAIGN NAME")),
          Expanded(flex: 2, child: Text("STATUS")),
          Expanded(flex: 2, child: Text("DURATION")),
          Expanded(flex: 2, child: Text("ASSIGNED TEAM")),
          Expanded(flex: 2, child: Text("PROGRESS")),
          Expanded(flex: 2, child: Text("PERFORMANCE")),
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
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/campaign-lead'),
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
            flex: 2,
            child: Text(
              c["duration"],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(flex: 2, child: assignedTeamAvatars(c["assignedTeam"])),
          Expanded(flex: 2, child: _progressBar(c["progress"])),
          Expanded(
            flex: 2,
            child: Text(
              "${c["performance"]}%",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
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

  Widget _progressBar(double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: Colors.grey.shade200,
          color: Colors.blue,
        ),
        const SizedBox(height: 4),
        Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget assignedTeamAvatars(List<Map<String, dynamic>> team) {
    const double avatarSize = 28;
    const double overlap = 18;

    final int visibleCount = team.length > 3 ? 3 : team.length;
    final int remaining = team.length - visibleCount;

    return SizedBox(
      height: avatarSize,
      width:
          avatarSize +
          (visibleCount - 1) * overlap +
          (remaining > 0 ? overlap : 0),
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    team[i]["avatar"] != null &&
                        team[i]["avatar"].toString().isNotEmpty
                    ? NetworkImage(team[i]["avatar"])
                    : null,
                child:
                    (team[i]["avatar"] == null ||
                        team[i]["avatar"].toString().isEmpty)
                    ? Text(
                        team[i]["name"][0],
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: visibleCount * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey.shade300,
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

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Showing 1 to 5 of 12 results"),
          Row(
            children: [
              Icon(Icons.chevron_left),
              SizedBox(width: 8),
              Text("1"),
              SizedBox(width: 8),
              Text("2"),
              SizedBox(width: 8),
              Text("3"),
              SizedBox(width: 8),
              Icon(Icons.chevron_right),
            ],
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
