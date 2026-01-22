import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

/* ================= MODEL ================= */

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String email;
  final String joiningDate;
  final String status;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.joiningDate,
    required this.status,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      joiningDate: json['joiningDate'] ?? '—',
      status: json['status'] ?? 'Offline',
    );
  }
}

/* ================= SCREEN ================= */

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  static const String baseUrl = "http://localhost:3000";

  bool _loading = true;

  String _selectedRole = "All Roles";
  String _selectedStatus = "Active";
  String _search = "";

  List<TeamMember> members = [];

  int totalMembers = 0;
  int activeMembers = 0;
  int avgPerformance = 0;

  final Map<String, Color> _statcolor = {
    'Active': Colors.green,
    'Offline': Colors.deepPurple,
    'Break': Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadStats(); // optional
  }

  /* ================= API ================= */

  Future<void> _loadMembers() async {
    try {
      setState(() => _loading = true);

      final uri = Uri.parse("$baseUrl/web/users").replace(
        queryParameters: {
          if (_search.isNotEmpty) "search": _search,
          if (_selectedRole != "All Roles") "role": _selectedRole,
          "status": _selectedStatus,
        },
      );

      final res = await http.get(uri);
      final body = jsonDecode(res.body);

      final List list = body['data'] ?? [];

      setState(() {
        members = list.map((e) => TeamMember.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint("LOAD MEMBERS ERROR: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/web/users/stats"));
      final json = jsonDecode(res.body)['data'];

      setState(() {
        totalMembers = json['totalMembers'] ?? 0;
        activeMembers = json['activeMembers'] ?? 0;
        avgPerformance = json['avgPerformance'] ?? 0;
      });
    } catch (_) {
      // Stats are optional — do NOT block UI
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _statsRow(),
              const SizedBox(height: 20),
              _filtersRow(),
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _membersTable(),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Team Members",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text(
              "Manage your telecalling team, view performance, and edit profiles.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/add-user'),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add New Member",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /* ================= STATS ================= */

  Widget _statsRow() {
    return Wrap(
      spacing: 16,
      children: [
        _StatCard("Total Members", totalMembers.toString()),
        _StatCard("Active Now", activeMembers.toString()),
        _StatCard("Avg Performance", "$avgPerformance%"),
      ],
    );
  }

  /* ================= FILTERS ================= */

  Widget _filtersRow() {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) {
              _search = v;
              _loadMembers();
            },
          ),
        ),
      ],
    );
  }

  /* ================= TABLE ================= */

  Widget _membersTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Member")),
        DataColumn(label: Text("Role")),
        DataColumn(label: Text("Email")),
        DataColumn(label: Text("Joining")),
        DataColumn(label: Text("Status")),
      ],
      rows: members.map((m) {
        final color = _statcolor[m.status] ?? Colors.grey;
        return DataRow(
          cells: [
            DataCell(
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/edit-user',
                  arguments: m.id,
                ),
                child: Text(m.name),
              ),
            ),
            DataCell(Text(m.role)),
            DataCell(Text(m.email)),
            DataCell(Text(m.joiningDate)),
            DataCell(Text(m.status,
                style: TextStyle(color: color))),
          ],
        );
      }).toList(),
    );
  }
}

/* ================= STAT CARD ================= */

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
