import 'dart:convert';
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
  // ================= CONFIG =================
  final String baseUrl = "http://localhost:3000/api/message-templates";

  // ================= STATE =================
  bool isLoading = true;
  String selectedStatus = "All";

  List<Map<String, dynamic>> templates = [];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  // ================= API =================
  Future<void> fetchTemplates() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        setState(() {
          templates = List<Map<String, dynamic>>.from(
            jsonDecode(res.body),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      isLoading = false;
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _filtersRow(),
                  const SizedBox(height: 16),
                  _tableCard(),
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
              "Message Templates",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and organize your message templates.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, "/create-template");
          },
          icon: const Icon(Icons.add),
          label: const Text("Create New Template"),
        ),
      ],
    );
  }

  // ================= FILTERS =================
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
        ],
      ),
    );
  }

  Widget _statusPill(String value) {
    final isSelected = selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
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
          ...templates.map(_tableRow).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("TEMPLATE NAME")),
          Expanded(flex: 2, child: Text("TYPE")),
          Expanded(flex: 4, child: Text("CONTENT PREVIEW")),
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
          const Expanded(
            flex: 2,
            child: Chip(label: Text("Generic")),
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
              t["created_at"]
                  .toString()
                  .split("T")
                  .first,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
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
