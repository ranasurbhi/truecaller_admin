import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeadActivityScreen extends StatefulWidget {
  final int leadId;

  const LeadActivityScreen({super.key, required this.leadId});

  @override
  State<LeadActivityScreen> createState() => _LeadActivityScreenState();
}

class _LeadActivityScreenState extends State<LeadActivityScreen> {
  final String baseUrl = "http://192.168.0.105:3000";

  bool loading = true;
  String? error;

  String selectedTab = "All";
  final TextEditingController activityController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Map<String, dynamic>? lead;
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchLead(),
        _fetchActivities(),
      ]);
      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ================= LEAD =================

  Future<void> _fetchLead() async {
    final res = await http.get(Uri.parse("$baseUrl/leads/${widget.leadId}"));
    if (res.statusCode != 200) throw Exception("Failed to load lead");

    final decoded = jsonDecode(res.body);
    lead = decoded['data'];
  }

  // ================= ACTIVITIES =================

  Future<void> _fetchActivities() async {
    final res = await http.get(
      Uri.parse("$baseUrl/lead_activities?lead_id=${widget.leadId}"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load activities");
    }

    final decoded = jsonDecode(res.body);
    final List data = decoded['data'];

    activities = data.map<Map<String, dynamic>>((a) {
      final createdAt = DateTime.parse(a['created_at']);
      return {
        "id": a['id'],
        "type": a['type'] ?? 'note',
        "title": a['title'] ?? 'Activity',
        "description": a['description'] ?? '',
        "user": a['user'] ?? 'System',
        "time": DateFormat('h:mm a').format(createdAt),
        "date": _formatDate(createdAt),
        "created_at": createdAt,
        "from": a['from'] ?? '',
        "to": a['to'] ?? '',
      };
    }).toList();

    // Sort by date descending
    activities.sort((a, b) => b['created_at'].compareTo(a['created_at']));
  }

  Future<void> _postActivity() async {
    if (activityController.text.trim().isEmpty) return;

    final body = {
      "lead_id": widget.leadId,
      "type": "note",
      "title": "Note Added",
      "description": activityController.text.trim(),
      "user": "You",
    };

    final response = await http.post(
      Uri.parse("$baseUrl/lead_activities"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      activityController.clear();
      await _fetchActivities();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post activity')),
      );
    }
  }

  // ================= DATE =================

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return "Today";
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return "Yesterday";
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : LayoutBuilder(
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
    if (lead == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(lead!['name'][0]),
          ),
          const SizedBox(height: 10),
          Text(lead!['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            lead!['role'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pill("Score: ${lead!['score'] ?? 'N/A'}"),
              const SizedBox(width: 6),
              _pill(lead!['status'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _actionButtons(),
          const Divider(height: 30),
          _infoRow(Icons.phone, lead!['phone'] ?? ''),
          _infoRow(Icons.email, lead!['email'] ?? ''),
          _infoRow(Icons.location_on, lead!['location'] ?? ''),
          const Divider(height: 30),
          if (lead!['tags'] != null && (lead!['tags'] as List).isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (lead!['tags'] as List)
                  .map<Widget>((t) => Chip(label: Text(t.toString())))
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
            onPressed: () {
              // Handle call action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call functionality would go here')),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text("Call"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Handle email action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email functionality would go here')),
              );
            },
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
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search activity log...",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              setState(() {});
            },
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

  // ================= FILTERED ACTIVITIES =================

  List<Map<String, dynamic>> get _filteredActivities {
    List<Map<String, dynamic>> filtered = activities;

    // Apply tab filter
    if (selectedTab == "Calls") {
      filtered = filtered.where((a) => a["type"] == "call").toList();
    } else if (selectedTab == "Emails") {
      filtered = filtered.where((a) => a["type"] == "email").toList();
    } else if (selectedTab == "Notes") {
      filtered = filtered.where((a) => a["type"] == "note").toList();
    } else if (selectedTab == "System") {
      filtered = filtered.where((a) => a["type"] == "status").toList();
    }

    // Apply search filter
    if (searchController.text.isNotEmpty) {
      final searchTerm = searchController.text.toLowerCase();
      filtered = filtered.where((a) {
        return (a["title"]?.toString().toLowerCase().contains(searchTerm) ?? false) ||
            (a["description"]?.toString().toLowerCase().contains(searchTerm) ?? false) ||
            (a["user"]?.toString().toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    return filtered;
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

  // ================= TIMELINE =================

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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              backgroundColor: _getActivityColor(a["type"]).withOpacity(0.1),
              child: Icon(
                _getActivityIcon(a["type"]),
                size: 14,
                color: _getActivityColor(a["type"]),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      a["type"] == "status" ? "Status Change" : a["title"],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getActivityColor(a["type"]).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        a["type"].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getActivityColor(a["type"]),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  a["description"]?.isNotEmpty == true
                      ? a["description"]
                      : a["type"] == "status"
                      ? "Status changed from ${a["from"]} to ${a["to"]}"
                      : "No description",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      a["time"],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      a["user"],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= HELPER FUNCTIONS =================

  Color _getActivityColor(String type) {
    switch (type) {
      case 'call':
        return Colors.green;
      case 'email':
        return Colors.blue;
      case 'note':
        return Colors.orange;
      case 'status':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'call':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'note':
        return Icons.edit;
      case 'status':
        return Icons.sync;
      default:
        return Icons.info;
    }
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