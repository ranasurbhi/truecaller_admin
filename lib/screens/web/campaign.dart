import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/services/api_service2.dart';
import 'package:truecaller/screens/web/campaign_lead.dart';


class CampaignManagementWebScreen extends StatefulWidget {
  const CampaignManagementWebScreen({super.key});

  @override
  State<CampaignManagementWebScreen> createState() =>
      _CampaignManagementWebScreenState();
}

class _CampaignManagementWebScreenState
    extends State<CampaignManagementWebScreen> {
  List<Map<String, dynamic>> campaigns = [];
  Map<String, dynamic>? dashboardStats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => loading = true);
    try {
      final stats = await ApiService2.getDashboardStats();
      final campListRaw = await ApiService2.getCampaigns();


      print("RAW CAMPAIGNS DATA:");
      print(campListRaw);


      // Convert campListRaw to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> campList = (campListRaw as List<dynamic>).map<Map<String, dynamic>>((c) {
        final Map<String, dynamic> campaignMap = Map<String, dynamic>.from(c);

        // Map agents to assignedTeam
        final List<dynamic> agentsRaw = campaignMap['agents'] ?? [];
        final List<Map<String, dynamic>> assignedTeam = agentsRaw
            .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from({
          "name": a['name'] ?? "NA",
          "avatar": a['profile_image'] ?? "",
        }))
            .toList();

        // Parse start/end dates
        final start = DateTime.tryParse(campaignMap['start_date'] ?? '');
        final end = DateTime.tryParse(campaignMap['end_date'] ?? '');
        final durationText = (start != null && end != null)
            ? "${start.day}/${start.month} - ${end.day}/${end.month}"
            : "";

        return {
          "id": campaignMap['id'],
          "name": campaignMap['campaign_name'] ?? "NA",
          "status": campaignMap['status'] ?? "draft",
          "duration": durationText,
          "assignedTeam": assignedTeam,
          "progress": 0.0,
          "performance": 0.0,
        };
      }).toList();

      setState(() {
        dashboardStats = stats;
        campaigns = campList;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Error fetching dashboard/campaigns: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 2,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
          onPressed: () {
            Navigator.pushNamed(context, '/create-campaign')
                .then((value) => _fetchData());
          },
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
    if (dashboardStats == null) return const SizedBox();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard("Active Campaigns",
            "${dashboardStats!['active_campaigns']}", "+0 this week"),
        _statCard(
            "Calls Today", "${dashboardStats!['calls_today']}", "+0 vs yest."),
        _statCard("Conversion Rate",
            "${dashboardStats!['conversion_rate']}%", "+0% vs target"),
        _statCard("Available Agents",
            "${dashboardStats!['available_agents']}", "out of total"),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _filterButton("Status: All"),
        const SizedBox(width: 12),
        _filterButton("This Month"),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampaignLeadsScreen(
                          campaignId: int.tryParse(c['id'].toString()) ?? 0,
                          campaignName: c['name'] ?? 'NA',
                        ),
                      ),
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
            flex: 2,
            child: Text(
              c["duration"],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: assignedTeamAvatars(c["assignedTeam"]),
          ),
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
    switch (status.toLowerCase()) {
      case "active":
        color = Colors.green;
        break;
      case "paused":
        color = Colors.orange;
        break;
      case "completed":
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
        Text("${(value * 100).toInt()}%",
            style: const TextStyle(fontSize: 12)),
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
      avatarSize + (visibleCount - 1) * overlap + (remaining > 0 ? overlap : 0),
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: team[i]["avatar"] != null &&
                    team[i]["avatar"].toString().isNotEmpty
                    ? NetworkImage(team[i]["avatar"])
                    : null,
                child: (team[i]["avatar"] == null ||
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