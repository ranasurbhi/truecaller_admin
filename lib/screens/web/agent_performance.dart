import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class AgentPerformanceScreen extends StatefulWidget {
  final int agentId;
  final String agentName;

  const AgentPerformanceScreen({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  State<AgentPerformanceScreen> createState() =>
      _AgentPerformanceScreenState();
}

class _AgentPerformanceScreenState extends State<AgentPerformanceScreen> {
  bool loading = true;
  Map<String, dynamic>? data;

  DateTime selectedDate = DateTime.now();

  String get formattedDate {
    return "${selectedDate.year.toString().padLeft(4, '0')}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    fetchAgentPerformance();
  }

  Future<void> fetchAgentPerformance() async {
    setState(() => loading = true);

    final url =
        "http://localhost:3000/web/agent-performance"
        "?agentId=${widget.agentId}&date=$formattedDate";

    try {
      final res = await http.get(Uri.parse(url));
      final json = jsonDecode(res.body);

      setState(() {
        data = json;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= DATE PICKER =================

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      fetchAgentPerformance();
    }
  }

  // ================= CSV EXPORT =================

  String _csvSafe(String value) {
    return '"${value.replaceAll('"', '""').replaceAll('\n', ' ')}"';
  }

  void _exportAgentPerformance() {
    if (data == null) return;

    final summary = data!["summary"];
    final time = data!["timeActivity"];
    final logs = data!["logs"];

    String csv = "Agent Performance Report\n\n";

    csv += "Agent Name,Date\n";
    csv += "${_csvSafe(widget.agentName)},$formattedDate\n\n";

    csv += "Total Calls,Connected,Missed\n";
    csv +=
        "${summary['total']},${summary['connected']},${summary['missed']}\n\n";

    csv += "Total Duration,Avg Duration,First Call,Last Call\n";
    csv +=
        "${time['totalDuration']},${time['avgDuration']},${time['firstCall']},${time['lastCall']}\n\n";

    csv += "Lead,Company,Phone,Time,Status\n";

    for (final log in logs) {
      csv +=
          "${_csvSafe(log['name'])},"
          "${_csvSafe(log['company'] ?? '')},"
          "${_csvSafe(log['phone'] ?? '')},"
          "${_csvSafe(log['time'])},"
          "${_csvSafe(log['status'])}\n";
    }

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "agent_performance_${widget.agentName}_$formattedDate.csv",
      )
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null || data!["success"] != true) {
      return const Center(child: Text("Failed to load data"));
    }

    final summary = data!["summary"];
    final time = data!["timeActivity"];
    final logs = data!["logs"];
    final pagination = data!["pagination"];
    final int totalResults =
        int.tryParse(pagination["total"].toString()) ?? 0;

    return WebLayout(
      selectedIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      _summaryCard(summary),
                      const SizedBox(height: 16),
                      _timeCard(time),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(child: _activityTable(logs, totalResults)),
              ],
            ),
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
              "Agent Performance",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Reviewing daily activity for ${widget.agentName}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(formattedDate),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _exportAgentPerformance,
              icon: const Icon(Icons.download),
              label: const Text("Export"),
            ),
          ],
        ),
      ],
    );
  }

  // ================= LEFT CARDS =================

  Widget _summaryCard(Map s) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Call Summary",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            "${int.tryParse(s['total'].toString()) ?? 0}",
            style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text("Total Calls", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _summaryRow(
            "Connected",
            int.tryParse(s["connected"].toString()) ?? 0,
            Colors.green,
          ),
          _summaryRow(
            "Missed",
            int.tryParse(s["missed"].toString()) ?? 0,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Chip(
          label: Text("$value"),
          backgroundColor: color.withOpacity(0.12),
          labelStyle: TextStyle(color: color),
        ),
      ],
    );
  }

  Widget _timeCard(Map t) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Time Activity",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _timeRow("Total Duration", t["totalDuration"]),
          _timeRow("Avg Duration", t["avgDuration"]),
          _timeRow("First Call", t["firstCall"]),
          _timeRow("Last Call", t["lastCall"]),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= ACTIVITY TABLE =================

  Widget _activityTable(List logs, int total) {
    return _card(
      Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text("LEAD NAME")),
                Expanded(child: Text("PHONE")),
                Expanded(child: Text("TIME")),
                Expanded(child: Text("DURATION")),
                Expanded(child: Text("STATUS")),
              ],
            ),
          ),
          const Divider(),
          ...logs.map((log) => _tableRow(log)).toList(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Showing ${logs.length} of $total results",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(Map log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log["name"],
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  log["company"] ?? "",
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(child: Text(log["phone"] ?? "")),
          Expanded(child: Text(log["time"] ?? "--")),
          const Expanded(child: Text("--")),
          Expanded(child: _statusChip(log["status"])),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "connected":
        color = Colors.green;
        break;
      case "no activity":
      case "no answer":
        color = Colors.red;
        break;
      case "callback":
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color),
    );
  }

  // ================= SHARED =================

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
