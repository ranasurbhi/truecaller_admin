import 'package:flutter/material.dart';
import '../models/agent.dart';
import 'agent_row.dart';

class AgentPerformanceTable extends StatelessWidget {
  final List<Agent> agents;

  const AgentPerformanceTable({
    super.key,
    required this.agents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SECTION HEADER
        const Text(
          "Agent Performance",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),

        const SizedBox(height: 16),

        /// TABLE
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

              /// TABLE ROWS (MODEL-DRIVEN)
              if (agents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No agents available",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...agents.map(
                  (agent) => AgentRow(agent: agent),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _HeaderCell("AGENT", flex: 3),
          _HeaderCell("STATUS", flex: 2),
          _HeaderCell("TOTAL CALLS", flex: 2),
          _HeaderCell("CONNECTED", flex: 2),
          _HeaderCell("MISSED", flex: 2),
          _HeaderCell("AVG DURATION", flex: 2),
          _HeaderCell("ACTION", flex: 1),
        ],
      ),
    );
  }
}

// ───────────── HEADER CELL ─────────────
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
