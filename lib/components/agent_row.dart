import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/agent_performance.dart';
import '../models/agent.dart';


class AgentRow extends StatelessWidget {
  final Agent agent;

  const AgentRow({
    super.key,
    required this.agent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = agent.totalCalls > 0
        ? agent.connected / agent.totalCalls
        : 0.0;

    return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentPerformanceScreen(
          agentId: agent.id,
          agentName: agent.name,
        ),
      ),
    );
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        // NAME
        Expanded(
          flex: 3,
          child: Text(
            agent.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        // STATUS
        Expanded(
          flex: 2,
          child: Text(agent.status),
        ),

        // TOTAL CALLS + PROGRESS
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: agent.totalCalls > 0
                    ? agent.connected / agent.totalCalls
                    : 0.0,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
              ),
              const SizedBox(height: 4),
              Text(
                agent.totalCalls.toString(),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),

        // CONNECTED
        Expanded(
          flex: 2,
          child: Text(agent.connected.toString()),
        ),

        // MISSED
        Expanded(
          flex: 2,
          child: Text(agent.missed.toString()),
        ),

        // ACTION
        const Expanded(
          flex: 1,
          child: Icon(Icons.more_vert),
        ),
      ],
    ),
  ),
);

  }
}
