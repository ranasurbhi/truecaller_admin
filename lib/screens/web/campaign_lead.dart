import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';
import 'package:truecaller/services/api_service2.dart';
import 'package:truecaller/screens/web/leads_activity_log.dart';

class CampaignLeadsScreen extends StatefulWidget {
  final int campaignId;
  final String campaignName;

  const CampaignLeadsScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
  });

  @override
  State<CampaignLeadsScreen> createState() => _CampaignLeadsScreenState();
}

class _CampaignLeadsScreenState extends State<CampaignLeadsScreen> {
  List<Lead> leads = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Call the API service
      final List<dynamic> leadList = await ApiService2.getLeadsByCampaign(widget.campaignId);
      print("LEADS RESPONSE: $leadList"); // Debug print

      // Convert each item to Lead model
      final List<Lead> fetchedLeads = leadList.map<Lead>((l) {
        return Lead(
          id: int.parse(l['id'].toString()),
          name: l['name']?.toString() ?? 'NA',
          company: l['company']?.toString() ?? '',
          phone: l['phone']?.toString() ?? '',
          email: l['email']?.toString() ?? '',
          status: l['status']?.toString() ?? 'New Lead',
          telecaller: l['telecaller']?.toString() ?? 'Unassigned',
          lastActivity: l['last_activity']?.toString() ?? '',
        );
      }).toList();

      setState(() {
        leads = fetchedLeads;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error =
        "Error fetching leads. Make sure API URL and campaign ID are correct.\n$e";
        loading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 2,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : leads.isEmpty
          ? const Center(
          child: Text("No leads available for this campaign."))
          : SingleChildScrollView(
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
          children: [
            Text(
              "Campaigns > ${widget.campaignName} > Leads",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "${widget.campaignName} Leads",
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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
        _statCard("Total Leads", "${leads.length}", "Target: -"),
        _statCard("Contacted", "-", "-"),
        _statCard("Qualified Leads", "-", "-"),
        _statCard("Avg. Call Duration", "-", "-"),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeadActivityScreen(
              leadId: l.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
            Expanded(flex: 2, child: _statusChip(l.status)),
            Expanded(flex: 2, child: Text(l.telecaller)),
            Expanded(flex: 2, child: Text(l.lastActivity)),
          ],
        ),
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
          Text("Showing 1 to X of X results"),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}

// ================= LEAD MODEL =================
class Lead {
  final int id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final String telecaller;
  final String lastActivity;

  Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.status,
    required this.telecaller,
    required this.lastActivity,
  });
}
