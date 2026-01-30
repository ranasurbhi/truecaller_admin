import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class LeadActivityScreen extends StatefulWidget {
  const LeadActivityScreen({super.key});

  @override
  State<LeadActivityScreen> createState() => _LeadActivityScreenState();
}

class _LeadActivityScreenState extends State<LeadActivityScreen> {
  static const String baseUrl = "http://localhost:3000";

  // ================= STATE =================
  late int leadId;
  final int currentUserId = 1; // 🔥 ADMIN USER ID
  bool loading = true;

  String selectedTab = "All";
  final TextEditingController activityController = TextEditingController();

  Map<String, dynamic> lead = {};
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      leadId = args["leadId"];
      _loadLeadData();
    });
  }

  // ================= API =================
  Future<void> _loadLeadData() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/web/leads/$leadId/activity"),
      );

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        setState(() {
          lead = json["data"]["lead"];
          activities = List<Map<String, dynamic>>.from(
            json["data"]["activities"],
          );
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Lead activity load error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _postActivity() async {
    if (activityController.text.trim().isEmpty) return;

    await http.post(
      Uri.parse("$baseUrl/web/leads/$leadId/activity"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "type": "note",
        "title": "Note Added",
        "description": activityController.text.trim(),
        "user_id": currentUserId, // 🔥 FIXED
      }),
    );

    activityController.clear();
    _loadLeadData();
  }


  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 2,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
            child: Text(
              lead["name"][0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lead["name"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _pill(lead["status"]),
          const Divider(height: 30),
          _infoRow(Icons.phone, lead["phone"] ?? "-"),
          _infoRow(Icons.email, lead["email"] ?? "-"),
        ],
      ),
    );
  }

  // ================= RIGHT =================
  Widget _activitySection() {
    return Column(
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
    );
  }

  Widget _activityHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Activity Log",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        Text(
          "Track all interactions for this lead",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

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
              hintText: "Log a note...",
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _postActivity,
              child: const Text("Post Activity"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================
  Widget _activityTabs() {
    final tabs = ["All", "Calls", "Emails", "Notes", "System"];

    return Wrap(
      spacing: 8,
      children: tabs.map((t) {
        final active = selectedTab == t;
        return ChoiceChip(
          label: Text(t),
          selected: active,
          onSelected: (_) => setState(() => selectedTab = t),
        );
      }).toList(),
    );
  }

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

  Widget _activityTimeline() {
    return Column(
      children: _filteredActivities.map(_activityCard).toList(),
    );
  }

  Widget _activityCard(Map<String, dynamic> a) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a["title"] ?? "Activity",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(a["description"] ?? ""),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              a["user_name"], // 🔥 FROM JOIN
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              a["created_at"].toString(),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );
}

  // ================= SHARED =================
  Widget _pill(String text) {
    return Chip(label: Text(text));
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
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
