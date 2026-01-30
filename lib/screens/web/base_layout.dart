import 'package:flutter/material.dart';
import 'package:truecaller/components/sidebar.dart';

class WebLayout extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  const WebLayout({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarItems = [
      {"icon": Icons.dashboard, "title": "Dashboard", "route": "/"},
      {"icon": Icons.people, "title": "Team Members", "route": "/team-member"},
      {"icon": Icons.campaign, "title": "Campaigns", "route": "/campaign"},
      // {"icon": Icons.bar_chart, "title": "Activity Log", "route": "/activity-log"},
      {"icon": Icons.list_alt_outlined, "title": "Templates", "route": "/msg-template"},
      {"icon": Icons.upload_file, "title": "Upload Leads", "route": "/upload-leads"},
      // {"icon": Icons.upload_file, "title": "Agent performace", "route": "/agent-performance"},

    ];


    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Row(
        children: [
          ///  SIDEBAR
          Sidebar(
            selectedIndex: selectedIndex,
            items: sidebarItems,
            onItemSelected: (index) {
              final route = sidebarItems[index]["route"] as String?;

              if (route != null) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),

          const SizedBox(width: 20),

          ///  MAIN CONTENT
          Expanded(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: child),
          ),
        ],
      ),
    );
  }
}
