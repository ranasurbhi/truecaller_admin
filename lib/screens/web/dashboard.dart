import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:truecaller/components/agent_table.dart';
import 'package:truecaller/components/stat_card.dart';
import 'package:truecaller/screens/web/base_layout.dart';

import '../../models/agent.dart';
import '../../models/call_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String baseUrl = "http://localhost:3000";

  CallSummary? summary;
  List<Agent> agents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ===================== API CALL =====================

  Future<void> _loadDashboardData() async {
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/call-stats/summary"),
      );

      final decoded = jsonDecode(response.body);

      if (decoded['success'] != true) {
        throw Exception("Dashboard API failed");
      }

      final data = decoded['data'];

      setState(() {
        summary = CallSummary.fromJson(data);
        agents = (data['agents'] as List)
            .map((e) => Agent.fromJson(e))
            .toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Dashboard error: $e");
      setState(() => loading = false);
    }
  }

  // ===================== CSV EXPORT =====================

  void _exportDashboardReport() {
    if (agents.isEmpty) return;

    String csv =
        "Agent Name,Status,Total Calls,Connected,Missed,Average Duration\n";

    for (final agent in agents) {
      csv +=
          "${agent.name},"
          "${agent.status},"
          "${agent.totalCalls},"
          "${agent.connected},"
          "${agent.missed},"
          "${agent.avgDurationFormatted}\n";
    }

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "dashboard_report.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
          
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (summary != null)
                _statsSection(summary!)
              else
                const Center(child: Text("No data available")),
          
              const SizedBox(height: 32),
          
              // const Text(
              //   "Agent Performance",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              // ),
              const SizedBox(height: 12),
          
              if (!loading)
                AgentPerformanceTable(agents: agents),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HEADER =====================

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Overview",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              "Real-time statistics for today's operations",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: agents.isEmpty ? null : _exportDashboardReport,
          icon: const Icon(Icons.download, size: 18),
          label: const Text("Export Report",style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== STATS =====================

  Widget _statsSection(CallSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1100 ? 4 : 2;
        final width =
            (constraints.maxWidth - (columns - 1) * 16) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statCard(
              width,
              "Total Calls",
              summary.totalCalls.toString(),
              "+12% vs yesterday",
              Icons.phone,
              true,
            ),
            _statCard(
              width,
              "Connected",
              summary.connectedCalls.toString(),
              "+5% vs avg",
              Icons.call,
              true,
            ),
            _statCard(
              width,
              "Avg Duration",
              formatDuration(summary.avgDuration),
              "+10% improvement",
              Icons.timer,
              true,
            ),
            _statCard(
              width,
              "Missed Calls",
              summary.missedCalls.toString(),
              "-7% drop",
              Icons.call_missed,
              false,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(
    double width,
    String title,
    String value,
    String subtitle,
    IconData icon,
    bool positive,
  ) {
    return SizedBox(
      width: width,
      child: StatCard(
        title: title,
        value: value,
        subtitle: subtitle,
        icon: icon,
        positive: positive,
      ),
    );
  }

  // ===================== HELPERS =====================

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes}m ${secs}s";
  }
}
