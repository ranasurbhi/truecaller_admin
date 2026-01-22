import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/models/team_member.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  static const String baseUrl = "http://localhost:3000";

  String _selectedRole = "All Roles";
  String _selectedStatus = "All";

  bool loading = true;
  List<TeamMember> members = [];

  final _statcolor = {
    'Active': Colors.green,
    'Break': Colors.amber,
    'Offline': Colors.deepPurple,
  };

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  // ================= API FETCH =================

  Future<void> _fetchTeamMembers() async {
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users"),
      );

      final decoded = jsonDecode(response.body);

      if (decoded['success'] != true) {
        throw Exception("Failed to load users");
      }

      final List list = decoded['data'];

      setState(() {
        members = list.map((e) {
          return TeamMember(
            name: e['name'] ?? '',
            role: e['role'] ?? 'Telecaller',
            email: e['email'] ?? '',
            joiningDate: e['date_of_joining'] != null
                ? e['date_of_joining'].toString()
                : '-',
            status: e['accepting_calls'] == 1 ? 'Active' : 'Offline',
          );
        }).toList();

        loading = false;
      });
    } catch (e) {
      debugPrint("Team members error: $e");
      setState(() => loading = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 20),
            _filtersCard(context),
            const SizedBox(height: 16),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              _membersTable(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Team Members",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // ================= STATS =================

  Widget _statsRow() {
    final total = members.length;
    final active =
        members.where((m) => m.status == 'Active').length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
            title: "Total Members",
            value: total.toString(),
            subtitle: "All users"),
        _StatCard(
            title: "Active Now",
            value: active.toString(),
            subtitle: "Online"),
      ],
    );
  }

  // ================= FILTERS =================

  Widget _filtersCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _filtersRow(context),
    );
  }

  Widget _filtersRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 260, child: _searchField()),
        const Spacer(),
        _dropdown(_selectedRole, ["All Roles", "agent", "admin"],
            (v) => setState(() => _selectedRole = v)),
        const SizedBox(width: 8),
        _dropdown(_selectedStatus, ["All", "Active", "Offline"],
            (v) => setState(() => _selectedStatus = v)),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by name or email",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _dropdown(
      String value, List<String> items, Function(String) onChanged) {
    return SizedBox(
      width: 140,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: value,
        isDense: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  // ================= TABLE =================

  Widget _membersTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text("Member")),
            DataColumn(label: Text("Role")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Joining Date")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Action")),
          ],
          rows: members.map((m) {
            return DataRow(cells: [
              DataCell(Text(m.name)),
              DataCell(Text(m.role)),
              DataCell(Text(m.email)),
              DataCell(Text(m.joiningDate)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _statcolor[m.status]!.shade100,
                  ),
                  child: Text(
                    m.status,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statcolor[m.status]),
                  ),
                ),
              ),
              const DataCell(Icon(Icons.more_vert)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// ================= STAT CARD =================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
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
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
