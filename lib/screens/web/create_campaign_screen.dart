import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final campaignNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final demographicCtrl = TextEditingController();
  final tagCtrl = TextEditingController();
  final searchAgentCtrl = TextEditingController();
  final searchCampaignCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> agents = [];
  final Set<int> selectedAgentsIds = {};
  final Set<String> selectedTags = {"Finances", "Finance"};

  bool loadingAgents = true;

  String selectedStatus = "draft"; // Default status

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  // ---------------- FETCH AGENTS ----------------
  Future<void> fetchAgents() async {
    try {
      final res = await http.get(Uri.parse("http://192.168.0.105:3000/agents"));
      final jsonData = jsonDecode(res.body);

      if (jsonData is List) {
        setState(() {
          agents = List<Map<String, dynamic>>.from(jsonData);
          loadingAgents = false;
        });
      } else if (jsonData is Map && jsonData['data'] is List) {
        setState(() {
          agents = List<Map<String, dynamic>>.from(jsonData['data']);
          loadingAgents = false;
        });
      } else {
        print("Unexpected agents format: $jsonData");
        setState(() => loadingAgents = false);
      }
    } catch (e) {
      print("Error fetching agents: $e");
      setState(() => loadingAgents = false);
    }
  }

  // ---------------- CREATE CAMPAIGN ----------------
  Future<void> createCampaign() async {
    if (campaignNameCtrl.text.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final payload = {
      "campaign_name": campaignNameCtrl.text,
      "description": descriptionCtrl.text,
      "demographics": demographicCtrl.text,
      "tags": selectedTags.toList(),
      "agents": selectedAgentsIds.toList(),
      "start_date": startDate!.toIso8601String().split("T")[0],
      "end_date": endDate!.toIso8601String().split("T")[0],
      "status": selectedStatus,
    };

    try {
      final res = await http.post(
        Uri.parse("http://192.168.0.105:3000/campaigns"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final jsonResp = jsonDecode(res.body);

      // Accept 2xx status codes and both boolean/string true
      if (res.statusCode >= 200 && res.statusCode < 300 &&
          (jsonResp['success'] == true || jsonResp['success'] == "true")) {
        // Show dialog on success
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Campaign Created"),
            content: Text(
                "Campaign created successfully "),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        // Clear form
        campaignNameCtrl.clear();
        descriptionCtrl.clear();
        demographicCtrl.clear();
        tagCtrl.clear();
        selectedTags.clear();
        selectedAgentsIds.clear();
        selectedStatus = "draft";
        startDate = null;
        endDate = null;
        setState(() {});
      } else {
        print("Failed to create campaign: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create campaign")),
        );
      }
    } catch (e) {
      print("Error creating campaign: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating campaign")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 3, // Campaigns
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _campaignManagerHeader(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createCampaignHeader(),
                  const SizedBox(height: 32),
                  _divider(),
                  const SizedBox(height: 32),
                  _campaignDetails(),
                  const SizedBox(height: 32),
                  _divider(),
                  const SizedBox(height: 32),
                  _scheduleAndAudience(),
                  const SizedBox(height: 32),
                  _divider(),
                  const SizedBox(height: 32),
                  _assignAgents(),
                  const SizedBox(height: 32),
                  _divider(),
                  const SizedBox(height: 32),
                  _actions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI FUNCTIONS ----------------
  Widget _campaignManagerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Campaign Manager",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Campaigns",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text(
                    "Create New",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchCampaignCtrl,
                        decoration: const InputDecoration(
                          hintText: "Search for campaigns...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, size: 20),
                  color: Colors.grey[700],
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey[300], height: 1);

  Widget _createCampaignHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create New Campaign",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Define the parameters for your upcoming telecalling initiative.",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _campaignDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Campaign Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: campaignNameCtrl,
          decoration: InputDecoration(
            labelText: "Campaign Name *",
            hintText: "e.g. Q3 Renewal Drive",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: descriptionCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: "Description",
            hintText: "Enter detailed instructions, goals, and script hints for the team...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _scheduleAndAudience() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _schedule()),
        const SizedBox(width: 32),
        Expanded(child: _audience()),
      ],
    );
  }

  Widget _schedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Scheduling", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _dateField("Start Date", startDate, (d) => setState(() => startDate = d)),
        const SizedBox(height: 12),
        _dateField("End Date", endDate, (d) => setState(() => endDate = d)),
      ],
    );
  }

  Widget _audience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Target Audience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: demographicCtrl,
          decoration: InputDecoration(
            labelText: "Demographics",
            hintText: "e.g. Male, 25-40, Urban",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (var tag in selectedTags)
              Chip(
                label: Text(tag),
                onDeleted: () => setState(() => selectedTags.remove(tag)),
              ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: tagCtrl,
                decoration: const InputDecoration(hintText: "Type and press Enter"),
                onSubmitted: (v) {
                  if (v.isNotEmpty) {
                    setState(() {
                      selectedTags.add(v);
                      tagCtrl.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Status: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: "draft", child: Text("Draft")),
                DropdownMenuItem(value: "active", child: Text("Active")),
                DropdownMenuItem(value: "paused", child: Text("Paused")),
                DropdownMenuItem(value: "completed", child: Text("Completed")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => selectedStatus = val);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _assignAgents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Assign Telecallers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (loadingAgents)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: agents.map((agent) {
              final id = agent['id'] as int;
              final name = agent['name'] as String;
              return CheckboxListTile(
                value: selectedAgentsIds.contains(id),
                title: Text(name),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      selectedAgentsIds.add(id);
                    } else {
                      selectedAgentsIds.remove(id);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: createCampaign,
          child: const Text("Save Campaign"),
        ),
      ],
    );
  }

  Widget _dateField(String hint, DateTime? value, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value == null ? hint : value.toIso8601String().split("T")[0]),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
