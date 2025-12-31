import 'package:flutter/material.dart';
import 'agent_row.dart';

class AgentPerformanceTable extends StatelessWidget {
  const AgentPerformanceTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///  SECTION HEADER
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

        ///  TABLE
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              /// TABLE HEADER 👇
              _tableHeader(),

              const Divider(),

              /// TABLE ROWS
              const AgentRow(
                name: "Sarah Jenkins",
                status: "On Call",
                progress: 0.98,
                calls: 98,
                duration: "3m 12s",
                sales: 12,
              ),
              const AgentRow(
                name: "Mike Ross",
                status: "Available",
                progress: 0.84,
                calls: 84,
                duration: "2m 45s",
                sales: 9,
              ),
              const AgentRow(
                name: "Elena Gilbert",
                status: "Away",
                progress: 0.76,
                calls: 76,
                duration: "2m 30s",
                sales: 7,
              ),
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