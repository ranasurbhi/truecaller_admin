import 'package:flutter/material.dart';
import 'package:truecaller/components/agent_table.dart';
import 'package:truecaller/components/stat_card.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),
            _statsRow(context),
            const SizedBox(height: 24),
            const AgentPerformanceTable(),
          ],
        ),
      ),
    );
  }

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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
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
    onPressed: () {},
    icon: const Icon(Icons.download, size: 18),
    label: const Text("Export Report"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}


  Widget _statsRow(BuildContext context) {
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
          _statItem(cardWidth,
              const StatCard(
                title: "Total Calls",
                value: "1,240",
                subtitle: "+12% vs yesterday",
                icon: Icons.phone,
                positive: true,
              )),
          _statItem(cardWidth,
              const StatCard(
                title: "Connected",
                value: "840",
                subtitle: "+5% vs avg",
                icon: Icons.call,
                positive: true,
              )),
          _statItem(cardWidth,
              const StatCard(
                title: "Avg Duration",
                value: "2m 14s",
                subtitle: "+30s improvement",
                icon: Icons.timer,
                positive: true,
              )),
          _statItem(cardWidth,
              const StatCard(
                title: "Missed Calls",
                value: "45",
                subtitle: "-2% (Good)",
                icon: Icons.call_missed,
                positive: false,
              )),
        ],
      );
    },
  );
}

Widget _statItem(double width, Widget child) {
  return SizedBox(
    width: width,
    child: child,
  );
}

}
