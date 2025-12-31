import 'package:flutter/material.dart';
import 'package:truecaller/components/sidebar.dart';

class WebLayout extends StatefulWidget {
  final int selectedIndex;
  final Widget child;

  const WebLayout({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  @override
  State<WebLayout> createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  late int currentIndex;

  final sidebarItems = [
    {"icon": Icons.dashboard, "title": "Dashboard"},
    {"icon": Icons.people, "title": "Team Members"},
    {"icon": Icons.campaign, "title": "Campaigns"},
    {"icon": Icons.bar_chart, "title": "Reports"},
    {"icon": Icons.settings, "title": "Settings"},
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Row(
        children: [
          Sidebar(
            selectedIndex: currentIndex,
            items: sidebarItems,
            onItemSelected: (index) {
              setState(() {
                currentIndex = index;
              });

              /// later you can add navigation here
            },
          ),

          /// 🔹 MAIN CONTENT
          
          SizedBox(width: 20,),

          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
