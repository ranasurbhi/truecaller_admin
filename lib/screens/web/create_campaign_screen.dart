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
  static const String baseUrl = "http://localhost:3000";

  final campaignNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final demographicCtrl = TextEditingController();
  final tagCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> agents = [];
  final Set<int> selectedAgentIds = {};
  final Set<String> selectedTags = {};

  bool loadingAgents = true;
  String selectedStatus = "draft";

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  /* ================= FETCH AGENTS ================= */

  Future<void> fetchAgents() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/web/agents"),
      );

      final json = jsonDecode(res.body);

      setState(() {
        agents = List<Map<String, dynamic>>.from(json["data"]);
        loadingAgents = false;
      });
    } catch (e) {
      loadingAgents = false;
    }
  }

  /* ================= CREATE CAMPAIGN ================= */

  Future<void> createCampaign() async {
    if (campaignNameCtrl.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Required fields missing")),
      );
      return;
    }

    final payload = {
      "campaign_name": campaignNameCtrl.text.trim(),
      "description": descriptionCtrl.text.trim(),
      "demographics": demographicCtrl.text.trim(),
      "start_date": startDate!.toIso8601String().split("T")[0],
      "end_date": endDate!.toIso8601String().split("T")[0],
      "status": selectedStatus,
      "agent_ids": selectedAgentIds.toList(),
      "tags": selectedTags.toList(),
    };

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/campaigns"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final jsonResp = jsonDecode(res.body);

      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          jsonResp["success"] == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Campaign Created"),
            content: const Text("Campaign created successfully"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        campaignNameCtrl.clear();
        descriptionCtrl.clear();
        demographicCtrl.clear();
        tagCtrl.clear();
        selectedTags.clear();
        selectedAgentIds.clear();
        selectedStatus = "draft";
        startDate = null;
        endDate = null;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create campaign")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Campaign",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),

            _textField("Campaign Name *", campaignNameCtrl),
            const SizedBox(height: 16),

            _textField("Description", descriptionCtrl, maxLines: 3),
            const SizedBox(height: 16),

            _textField("Demographics", demographicCtrl),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _datePicker("Start Date", startDate,
                    (d) => setState(() => startDate = d))),
                const SizedBox(width: 16),
                Expanded(child: _datePicker("End Date", endDate,
                    (d) => setState(() => endDate = d))),
              ],
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: "Status"),
              items: const [
                DropdownMenuItem(value: "draft", child: Text("Draft")),
                DropdownMenuItem(value: "active", child: Text("Active")),
                DropdownMenuItem(value: "completed", child: Text("Completed")),
              ],
              onChanged: (v) => setState(() => selectedStatus = v!),
            ),

            const SizedBox(height: 24),

            const Text(
              "Assign Telecallers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            loadingAgents
                ? const CircularProgressIndicator()
                : Column(
                    children: agents.map((a) {
                      return CheckboxListTile(
                        value: selectedAgentIds.contains(a["id"]),
                        title: Text(a["name"]),
                        onChanged: (v) {
                          setState(() {
                            v == true
                                ? selectedAgentIds.add(a["id"])
                                : selectedAgentIds.remove(a["id"]);
                          });
                        },
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),

            const Text(
              "Tags",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            Wrap(
              spacing: 8,
              children: [
                for (final tag in selectedTags)
                  Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => selectedTags.remove(tag)),
                  ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: tagCtrl,
                    decoration:
                        const InputDecoration(hintText: "Add tag & Enter"),
                    onSubmitted: (v) {
                      if (v.isNotEmpty) {
                        setState(() {
                          selectedTags.add(v);
                          tagCtrl.clear();
                        });
                      }
                    },
                  ),
                )
              ],
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: createCampaign,
                child: const Text("Save Campaign"),
              ),
            )
          ],
        ),
      ),
    );
  }

  /* ================= HELPERS ================= */

  Widget _textField(String label, TextEditingController c,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _datePicker(
      String label, DateTime? value, Function(DateTime) onPick) {
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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          value == null
              ? "Select"
              : value.toIso8601String().split("T")[0],
        ),
      ),
    );
  }
}
