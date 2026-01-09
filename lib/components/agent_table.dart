import 'package:flutter/material.dart';

class AgentPerformanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> agentData;

  const AgentPerformanceTable({
    super.key,
    required this.agentData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _tableHeader(),
          const SizedBox(height: 8),
          const Divider(),

          ...agentData.map((agent) => _tableRow(agent)).toList(),
        ],
      ),
    );
  }

  // ───────────── HEADER ─────────────
  Widget _tableHeader() {
    return Row(
      children: const [
        Expanded(flex: 3, child: _HeaderText("AGENT")),
        Expanded(flex: 2, child: _HeaderText("STATUS")),
        Expanded(flex: 3, child: _HeaderText("DAILY TARGET")),
        Expanded(flex: 2, child: _HeaderText("CALLS MADE")),
        Expanded(flex: 2, child: _HeaderText("AVG DURATION")),
        Expanded(flex: 1, child: _HeaderText("SALES")),
        SizedBox(width: 32),
      ],
    );
  }

  // ───────────── ROW ─────────────
  Widget _tableRow(Map<String, dynamic> agent) {
    final progress = agent["achieved"] / agent["target"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          /// AGENT
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: agent["avatar"] != null
                      ? NetworkImage(agent["avatar"])
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: agent["avatar"] == null
                      ? Text(
                          agent["name"][0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      agent["role"],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// STATUS
          Expanded(
            flex: 2,
            child: _statusChip(agent["status"]),
          ),

          /// DAILY TARGET
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${agent["achieved"]}/${agent["target"]}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          /// CALLS MADE
          Expanded(
            flex: 2,
            child: Text(
              agent["calls"].toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          /// AVG DURATION
          Expanded(
            flex: 2,
            child: Text(agent["avgDuration"]),
          ),

          /// SALES
          Expanded(
            flex: 1,
            child: Text(
              agent["sales"].toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          /// ACTION
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  // ───────────── STATUS CHIP ─────────────
  Widget _statusChip(String status) {
    late Color bg;
    late Color text;

    switch (status) {
      case "On Call":
        bg = Colors.green.shade50;
        text = Colors.green;
        break;
      case "Available":
        bg = Colors.grey.shade200;
        text = Colors.grey.shade700;
        break;
      default:
        bg = Colors.orange.shade50;
        text = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, color: text),
      ),
    );
  }
}

// ───────────── HEADER TEXT ─────────────
class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}
