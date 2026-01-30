import 'package:flutter/material.dart';
import 'package:truecaller/models/team_member.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/screens/web/edit_user.dart';
import 'package:truecaller/services/api_service.dart';

class TeamMembersScreen extends StatefulWidget {
  TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  String _selectedRole = "All Roles";

  String _selectedStatus = "Active";

  List<TeamMember> members = [];
  bool loading = true;
  Map<String, int> stats = {};

  final _statcolor = {
    'Active': Colors.green,
    'Break': Colors.amber,
    'Offline': Colors.deepPurple,
  };
  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final data = await ApiService.fetchTeamMembers();

      debugPrint("TEAM MEMBERS RAW: $data");

      setState(() {
        members = (data["users"] as List)
            .map((e) => TeamMember.fromJson(e))
            .toList();

        stats = {
          "total": int.parse(data["stats"]["total"].toString()),
          "active": int.parse(data["stats"]["active"].toString()),
          "inactive": int.parse(data["stats"]["inactive"].toString()),
        };

        loading = false;
      });
    } catch (e) {
      debugPrint("TeamMembers error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return WebLayout(
      selectedIndex: 1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _filtersRow(context),
            ),
            const SizedBox(height: 16),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
          onPressed: () => Navigator.pushReplacementNamed(context, '/add-user'),
          label: const Text(
            "Add New Member",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ================= STATS =================
  Widget _statsRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          title: "Total Members",
          value: stats["total"]?.toString() ?? "0",
          subtitle: "All users",
        ),
        _StatCard(
          title: "Active Now",
          value: stats["active"]?.toString() ?? "0",
          subtitle: "Online",
        ),
        _StatCard(
          title: "Inactive",
          value: stats["inactive"]?.toString() ?? "0",
          subtitle: "Offline",
        ),
      ],
    );
  }

  // ================= FILTERS =================
  Widget _filtersRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;

    if (isSmall) {
      /// 🔹 Mobile / small width → STACKED
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_searchField(), const SizedBox(height: 12), _rightFilters()],
      );
    }

    /// 🔹 Desktop / large width → SINGLE ROW
    return Row(
      children: [
        SizedBox(width: 260, child: _searchField()),
        const Spacer(),
        _rightFilters(),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by name, email or role...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _rightFilters() {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: _dropdown(_selectedRole, [
            "All Roles",
            "Telecaller",
            "Manager",
          ], (val) => setState(() => _selectedRole = val)),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: _dropdown(_selectedStatus, [
            "Active",
            "Inactive",
          ], (val) => setState(() => _selectedStatus = val)),
        ),
        const SizedBox(width: 8),
        IconButton(onPressed: () {}, icon: const Icon(Icons.grid_view)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
      ],
    );
  }

  Widget _dropdown(
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        value: value,
        isDense: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
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
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text("Member")),
            DataColumn(label: Text("Role")),
            DataColumn(label: Text("Contact")),
            DataColumn(label: Text("Date of Joining")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Action")),
          ],
          rows: members.map((member) {
            return DataRow(
              cells: [
                DataCell(
                  GestureDetector(
                    child: Text(member.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUserScreen(userId: member.id),
                        ),
                      );
                    },
                  ),
                ),
                DataCell(Text(member.role)),
                DataCell(Text(member.email)),
                DataCell(Text(member.joiningDate)),
                DataCell(
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _statcolor[member.status]!.shade100,
                    ),
                    child: Text(
                      member.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: _statcolor[member.status],
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const DataCell(Icon(Icons.more_vert)),
              ],
            );
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
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
