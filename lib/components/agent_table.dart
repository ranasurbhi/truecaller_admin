import 'package:flutter/material.dart';
import 'agent_row.dart';
import '../models/agent.dart';

class AgentPerformanceTable extends StatelessWidget {
  final List<Agent> agents;

  const AgentPerformanceTable({super.key, required this.agents});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Agent Performance",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search agent...",
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text("Filter"),
                ),
                
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _tableHeader(),
              const Divider(),
              ...agents.map((agent) => AgentRow(agent: agent)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          _HeaderCell("AGENT", flex: 3),
          _HeaderCell("STATUS", flex: 2),
          _HeaderCell("DAILY TARGET", flex: 3),
          _HeaderCell("CALLS MADE", flex: 2),
          _HeaderCell("AVG DURATION", flex: 2),
          _HeaderCell("SALES", flex: 1),
          _HeaderCell("ACTION", flex: 1),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
