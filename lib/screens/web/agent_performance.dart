import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class AgentPerformanceScreen extends StatelessWidget {
  const AgentPerformanceScreen({super.key});

  // ================= DEMO DATA =================

  final Map<String, dynamic> agentInfo = const {
    "name": "Sarah Jenkins",
    "date": "Oct 24, 2023",
  };

  final Map<String, dynamic> callSummary = const {
    "total": 85,
    "connected": 42,
    "missed": 43,
  };

  final Map<String, String> timeActivity = const {
    "totalDuration": "3h 45m",
    "avgDuration": "2m 15s",
    "firstCall": "09:02 AM",
    "lastCall": "05:45 PM",
  };

  final List<Map<String, dynamic>> activityLogs = const [
    {
      "name": "John Doe",
      "company": "Acme Corp",
      "phone": "+1 (555) 123-4567",
      "time": "05:45 PM",
      "duration": "05m 12s",
      "status": "Connected",
    },
    {
      "name": "Alice Smith",
      "company": "Tech Solutions",
      "phone": "+1 (555) 987-6543",
      "time": "04:30 PM",
      "duration": "--",
      "status": "No Answer",
    },
    {
      "name": "Robert Johnson",
      "company": "Global Inc.",
      "phone": "+1 (555) 456-7890",
      "time": "02:15 PM",
      "duration": "12m 45s",
      "status": "Meeting Booked",
    },
    {
      "name": "Emily Miller",
      "company": "Startup Hub",
      "phone": "+1 (555) 222-3333",
      "time": "11:00 AM",
      "duration": "02m 10s",
      "status": "Callback",
    },
  ];

  // ================= BUILD =================

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
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: _leftColumn()),
                const SizedBox(width: 20),
                Expanded(child: _activityTable()),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              "Reviewing daily activity for ${agentInfo["name"]}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(agentInfo["date"]),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text("Export"),
            ),
          ],
        ),
      ],
    );
  }

  // ================= LEFT COLUMN =================

  Widget _leftColumn() {
    return Column(
      children: [
        _callSummaryCard(),
        const SizedBox(height: 16),
        _timeActivityCard(),
      ],
    );
  }

  Widget _callSummaryCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Call Summary",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            "${callSummary["total"]}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text("Total Calls", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _summaryRow("Connected", callSummary["connected"], Colors.green),
          const SizedBox(height: 6),
          _summaryRow("Missed", callSummary["missed"], Colors.red),
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
          backgroundColor: color.withOpacity(0.1),
          labelStyle: TextStyle(color: color),
        ),
      ],
    );
  }

  Widget _timeActivityCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Time Activity",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _timeRow("Total Duration", timeActivity["totalDuration"]!),
          _timeRow("Avg Duration", timeActivity["avgDuration"]!),
          _timeRow("First Call", timeActivity["firstCall"]!),
          _timeRow("Last Call", timeActivity["lastCall"]!),
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

  Widget _activityTable() {
    return _card(
      Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...activityLogs.map(_tableRow).toList(),
          const Divider(height: 1),
          _pagination(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("LEAD NAME")),
          Expanded(child: Text("PHONE")),
          Expanded(child: Text("TIME")),
          Expanded(child: Text("DURATION")),
          Expanded(child: Text("STATUS")),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(log["name"][0]),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log["name"],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(log["company"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: Text(log["phone"])),
          Expanded(child: Text(log["time"])),
          Expanded(child: Text(log["duration"])),
          Expanded(child: _statusChip(log["status"])),
          TextButton(onPressed: () {}, child: const Text("View")),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Connected":
        color = Colors.green;
        break;
      case "No Answer":
        color = Colors.red;
        break;
      case "Meeting Booked":
        color = Colors.blue;
        break;
      case "Callback":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Showing 1–5 of 85 results"),
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

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
