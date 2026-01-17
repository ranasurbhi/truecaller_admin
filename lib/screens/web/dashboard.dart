import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:truecaller/components/agent_table.dart';
import 'package:truecaller/components/stat_card.dart';
import 'package:truecaller/screens/web/base_layout.dart';

import '../../services/api_service.dart';
import '../../models/agent.dart';
import '../../models/call_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CallSummary? summary;
  List<Agent> agents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ---------------- API FETCH ----------------

  Future<void> _loadDashboardData() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.fetchDashboardData();

      if (!mounted) return;

      setState(() {
        summary = ApiService.parseSummary(data);
        agents = ApiService.parseAgents(data['agents']);
        loading = false;
      });
    } catch (e) {
      debugPrint("Dashboard error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------------- CSV EXPORT ----------------

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
      ..setAttribute("download", "agent_performance_report.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (summary != null)
              _statsRow(context, summary!)
            else
              const Center(child: Text("No data available")),

            const SizedBox(height: 24),

            if (!loading)
              AgentPerformanceTable(agents: agents),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _header(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width < 700
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerText(),
              const SizedBox(height: 12),
              _exportButton(),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerText(),
              _exportButton(),
            ],
          );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Overview",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          "Real-time statistics for today's operations",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _exportButton() {
    return ElevatedButton.icon(
      onPressed: agents.isEmpty ? null : _exportDashboardReport,
      icon: const Icon(Icons.download, size: 18, color: Colors.white),
      label: const Text(
        "Export Report",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ---------------- STATS ----------------

  Widget _statsRow(BuildContext context, CallSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 4;
        if (constraints.maxWidth < 1200) columns = 2;
        if (constraints.maxWidth < 700) columns = 1;

        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statItem(
              cardWidth,
              StatCard(
                title: "Total Calls",
                value: summary.totalCalls.toString(),
                subtitle: "All agents",
                icon: Icons.phone,
                positive: true,
              ),
            ),
            _statItem(
              cardWidth,
              StatCard(
                title: "Connected",
                value: summary.connected.toString(),
                subtitle: "Successful calls",
                icon: Icons.call,
                positive: true,
              ),
            ),
            _statItem(
              cardWidth,
              StatCard(
                title: "Avg Duration",
                value: formatDuration(
                  (summary.avgDuration * 60).round(),
                ),
                subtitle: "Across agents",
                icon: Icons.timer,
                positive: true,
              ),
            ),
            _statItem(
              cardWidth,
              StatCard(
                title: "Missed Calls",
                value: summary.missedCalls.toString(),
                subtitle: "Needs attention",
                icon: Icons.call_missed,
                positive: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statItem(double width, Widget child) {
    return SizedBox(width: width, child: child);
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes}m ${secs}s";
  }
}
