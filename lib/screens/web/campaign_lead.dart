import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class CampaignLeadsScreen extends StatefulWidget {
  const CampaignLeadsScreen({super.key});

  @override
  State<CampaignLeadsScreen> createState() =>
      _CampaignLeadsScreenState();
}

class _CampaignLeadsScreenState extends State<CampaignLeadsScreen> {
  final List<Lead> leads = demoLeads;

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 3,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _statsRow(),
              const SizedBox(height: 20),
              _filtersRow(),
              const SizedBox(height: 20),
              _tableCard(),
            ],
          ),
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
              "Campaigns > Q4 Renewal Drive > Leads",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 6),
            Text(
              "Q4 Renewal Drive Leads",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Add Lead"),
            ),
          ],
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
        _statCard("Total Leads", "2,540", "Target: 3,000"),
        _statCard("Contacted", "1,620", "64%"),
        _statCard("Qualified Leads", "342", "+21.1%"),
        _statCard("Avg. Call Duration", "4m 12s", "+30s vs Avg"),
      ],
    );
  }

  Widget _statCard(String title, String value, String subtitle) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search lead by name, phone or email...",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _dropdownButton("Status: All"),
        const SizedBox(width: 12),
        _dropdownButton("Telecaller: All"),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text("Export List"),
        ),
      ],
    );
  }

  Widget _dropdownButton(String text) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list),
      label: Text(text),
    );
  }

  // ================= TABLE =================

  Widget _tableCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...leads.map(_tableRow).toList(),
          const Divider(height: 1),
          _pagination(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("LEAD NAME")),
          Expanded(flex: 3, child: Text("CONTACT INFO")),
          Expanded(flex: 2, child: Text("CAMPAIGN STATUS")),
          Expanded(flex: 2, child: Text("ASSIGNED TELECALLER")),
          Expanded(flex: 2, child: Text("LAST ACTIVITY")),
        ],
      ),
    );
  }

  Widget _tableRow(Lead l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(l.company,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.phone),
                Text(l.email,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _statusChip(l.status),
          ),
          Expanded(
            flex: 2,
            child: Text(l.telecaller),
          ),
          Expanded(
            flex: 2,
            child: Text(l.lastActivity),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Interested":
        color = Colors.orange;
        break;
      case "Converted":
        color = Colors.green;
        break;
      case "Call Back":
        color = Colors.purple;
        break;
      case "New Lead":
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Showing 1 to 5 of 2,540 results"),
          Row(
            children: [
              Icon(Icons.chevron_left),
              SizedBox(width: 8),
              Text("1"),
              SizedBox(width: 8),
              Text("2"),
              SizedBox(width: 8),
              Text("3"),
              SizedBox(width: 8),
              Icon(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SHARED =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}

// ================= DEMO DATA =================

class Lead {
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final String telecaller;
  final String lastActivity;

  Lead({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.status,
    required this.telecaller,
    required this.lastActivity,
  });
}

final demoLeads = [
  Lead(
    name: "Sarah Miller",
    company: "Director, TechCorp",
    phone: "+1 (555) 123-4567",
    email: "sarah.m@techcorp.com",
    status: "Interested",
    telecaller: "Jane Cooper",
    lastActivity: "Today, 10:30 AM",
  ),
  Lead(
    name: "Michael Chen",
    company: "Manager, Solutions Inc.",
    phone: "+1 (555) 987-6543",
    email: "m.chen@solutions.inc",
    status: "New Lead",
    telecaller: "Unassigned",
    lastActivity: "Yesterday",
  ),
];
