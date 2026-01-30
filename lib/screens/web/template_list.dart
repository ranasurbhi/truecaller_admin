import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() =>
      _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState extends State<MessageTemplatesScreen> {
  static const String baseUrl = "http://localhost:3000";

  bool loading = true;
  List<Map<String, dynamic>> templates = [];
  String selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  /* ================= API ================= */

  Future<void> _loadTemplates() async {
    try {
      final res =
          await http.get(Uri.parse("$baseUrl/api/message-templates"));

      final data = jsonDecode(res.body);

      setState(() {
        templates = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("Load templates error: $e");
      setState(() => loading = false);
    }
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _filtersRow(),
            const SizedBox(height: 16),
            loading
                ? const Center(child: CircularProgressIndicator())
                : _tableCard(),
          ],
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
            Text(
              "Message Templates",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and send communication templates",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, "/create-template");
          },
          icon: const Icon(Icons.add),
          label: const Text("Create Template"),
        ),
      ],
    );
  }

  /* ================= FILTERS ================= */

  Widget _filtersRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search templates...",
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _statusPill("All"),
          const SizedBox(width: 6),
          _statusPill("Active"),
          const SizedBox(width: 6),
          _statusPill("Draft"),
        ],
      ),
    );
  }

  Widget _statusPill(String value) {
    final active = selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  /* ================= TABLE ================= */

  Widget _tableCard() {
    if (templates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text("No templates found")),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...templates.map(_tableRow),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("NAME")),
          Expanded(flex: 4, child: Text("MESSAGE")),
          Expanded(flex: 2, child: Text("CREATED")),
          Expanded(flex: 1, child: Text("ACTIONS")),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              t["name"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              t["message"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateTime.parse(t["created_at"])
                  .toLocal()
                  .toString()
                  .split(".")[0],
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _openActions(t),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= ACTIONS ================= */

  void _openActions(Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text("Send Message"),
            onTap: () {
              Navigator.pop(context);
              _openSendDialog(t);
            },
          ),
        ],
      ),
    );
  }

  /* ================= SEND MESSAGE FLOW ================= */

  void _openSendDialog(Map<String, dynamic> template) {
    final phoneCtrl = TextEditingController();

    final List<dynamic> vars =
        template["variables"] is String
            ? jsonDecode(template["variables"])
            : (template["variables"] ?? []);

    final controllers = {
      for (var v in vars) v: TextEditingController()
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Send Message"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: "Phone (with country code)",
                    hintText: "919999999999",
                  ),
                ),
                const SizedBox(height: 12),
                ...vars.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: controllers[v],
                      decoration: InputDecoration(labelText: v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendMessage(
                templateId: template["id"],
                phone: phoneCtrl.text.trim(),
                values: vars.map((v) => controllers[v]!.text).toList(),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage({
    required int templateId,
    required String phone,
    required List<String> values,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/message-templates/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "templateId": templateId,
          "phoneNumber": phone,
          "values": values,
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true && data["whatsappUrl"] != null) {
        html.window.open(data["whatsappUrl"], "_blank");
      } else {
        _showError("Failed to send message");
      }
    } catch (e) {
      debugPrint("Send message error: $e");
      _showError("Something went wrong");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= SHARED ================= */

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
