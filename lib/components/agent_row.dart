import 'package:flutter/material.dart';
import '../models/agent.dart';

class AgentRow extends StatelessWidget {
  final Agent agent;

  const AgentRow({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(agent.name)),
          Expanded(flex: 2, child: Text(agent.status)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: agent.totalCalls > 0
                  ? agent.connected / agent.totalCalls
                  : 0,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
            ),
          ),
          Expanded(flex: 2, child: Text(agent.totalCalls.toString())),
          Expanded(flex: 2, child: Text(agent.avgDurationFormatted)),
          Expanded(flex: 1, child: Text(agent.connected.toString())),
          Expanded(flex: 1, child: Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}
