import 'package:flutter/material.dart';

class AgentRow extends StatelessWidget {
  final String name;
  final String status;
  final double progress;
  final int calls;
  final String duration;
  final int sales;

  const AgentRow({
    super.key,
    required this.name,
    required this.status,
    required this.progress,
    required this.calls,
    required this.duration,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name)),
          Expanded(
            child: Chip(
              label: Text(status),
              backgroundColor:
                  status == "On Call" ? Colors.green.shade50 : Colors.grey.shade200,
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(value: progress),
          ),
          Expanded(child: Text("$calls")),
          Expanded(child: Text(duration)),
          Expanded(child: Text("$sales")),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
