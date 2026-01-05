import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class LeadActivityScreen extends StatefulWidget {
  const LeadActivityScreen({super.key});

  @override
  State<LeadActivityScreen> createState() =>
      _LeadActivityScreenState();
}

class _LeadActivityScreenState extends State<LeadActivityScreen> {
  // ================= STATE =================

  String selectedTab = "All";
  final TextEditingController activityController = TextEditingController();

  final Map<String, dynamic> lead = {
    "name": "Sarah Jenkins",
    "role": "VP of Operations at TechSolutions Inc.",
    "avatar": "",
    "score": 85,
    "status": "Contacted",
    "phone": "+1 (555) 123-4567",
    "email": "sarah.j@techsolutions.inc",
    "location": "San Francisco, CA",
    "tags": ["Enterprise", "Q4 Priority", "Tech"],
  };

  final List<Map<String, dynamic>> activities = [
    {
      "type": "call",
      "title": "Outbound Call",
      "user": "Mike Ross",
      "time": "2 hours ago",
      "date": "Today",
      "description":
          "Tried calling Sarah regarding the new proposal. No answer, left a voicemail asking for a callback tomorrow morning.",
    },
    {
      "type": "note",
      "title": "Note Added",
      "user": "Jessica Pearson",
      "time": "4:30 PM",
      "date": "Today",
      "description":
          "Client is extremely interested in the Enterprise plan but needs final budget approval from the CTO.",
    },
    {
      "type": "status",
      "from": "New Lead",
      "to": "Contacted",
      "time": "Oct 12, 4:05 PM",
      "date": "Yesterday",
    },
  ];

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _profileCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _activitySection()),
                ],
              );
            }
            return Column(
              children: [
                _profileCard(),
                const SizedBox(height: 20),
                _activitySection(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= LEFT PROFILE =================

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(lead["name"][0]),
          ),
          const SizedBox(height: 10),
          Text(lead["name"], style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            lead["role"],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pill("Score: ${lead["score"]}"),
              const SizedBox(width: 6),
              _pill(lead["status"]),
            ],
          ),
          const SizedBox(height: 16),
          _actionButtons(),
          const Divider(height: 30),
          _infoRow(Icons.phone, lead["phone"]),
          _infoRow(Icons.email, lead["email"]),
          _infoRow(Icons.location_on, lead["location"]),
          const Divider(height: 30),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: lead["tags"]
                .map<Widget>((t) => Chip(label: Text(t)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call, size: 16),
            label: const Text("Call"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.email, size: 16),
            label: const Text("Email"),
          ),
        ),
      ],
    );
  }

  // ================= RIGHT ACTIVITY =================

  Widget _activitySection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _activityHeader(),
          const SizedBox(height: 12),
          _activityInput(),
          const SizedBox(height: 12),
          _activityTabs(),
          const SizedBox(height: 16),
          _activityTimeline(),
        ],
      ),
    );
  }

  Widget _activityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Activity Log",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              "Track all interactions and system updates for this lead.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(
          width: 220,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search activity log...",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // ================= INPUT =================

  Widget _activityInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          TextField(
            controller: activityController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Log a call, note, or quick update...",
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.attach_file, size: 18, color: Colors.grey),
                  SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                ],
              ),
              ElevatedButton(
                onPressed: _postActivity,
                child: const Text("Post Activity"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _postActivity() {
    if (activityController.text.trim().isEmpty) return;

    setState(() {
      activities.insert(0, {
        "type": "note",
        "title": "Note Added",
        "user": "You",
        "time": "Just now",
        "date": "Today",
        "description": activityController.text.trim(),
      });
      activityController.clear();
    });
  }

  // ================= TABS =================

  Widget _activityTabs() {
    final tabs = ["All", "Calls", "Emails", "Notes", "System"];

    return Wrap(
      spacing: 8,
      children: tabs.map((t) {
        final isActive = selectedTab == t;

        return GestureDetector(
          onTap: () {
            setState(() => selectedTab = t);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= TIMELINE =================

  List<Map<String, dynamic>> get _filteredActivities {
    if (selectedTab == "All") return activities;

    return activities.where((a) {
      switch (selectedTab) {
        case "Calls":
          return a["type"] == "call";
        case "Emails":
          return a["type"] == "email";
        case "Notes":
          return a["type"] == "note";
        case "System":
          return a["type"] == "status";
        default:
          return true;
      }
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(
      List<Map<String, dynamic>> list) {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (var a in list) {
      map.putIfAbsent(a["date"], () => []);
      map[a["date"]]!.add(a);
    }
    return map;
  }

  Widget _activityTimeline() {
    final grouped = _groupByDate(_filteredActivities);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  entry.key,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              ...entry.value.map(_activityStep).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _activityStep(Map<String, dynamic> a) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                a["type"] == "call"
                    ? Icons.call
                    : a["type"] == "note"
                        ? Icons.edit
                        : Icons.sync,
                size: 14,
                color: Colors.blue,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a["type"] == "status"
                      ? "Status Change"
                      : a["title"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  a["description"] ??
                      "Status changed from ${a["from"]} to ${a["to"]}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  a["time"],
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= SHARED =================

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
