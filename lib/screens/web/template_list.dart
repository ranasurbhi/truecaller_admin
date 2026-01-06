import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() =>
      _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState
    extends State<MessageTemplatesScreen> {
  // ================= STATE =================

  String selectedStatus = "All";
  String selectedType = "All";

  final List<Map<String, dynamic>> templates = [
    {
      "name": "Welcome Message V1",
      "type": "WhatsApp",
      "status": "Active",
      "content": "Hi {{name}}, thanks for joining us! We are excited to have you.",
      "date": "Oct 24, 2023",
    },
    {
      "name": "Follow-up SMS",
      "type": "SMS",
      "status": "Active",
      "content": "Just checking in regarding your interest in our services.",
      "date": "Oct 22, 2023",
    },
    {
      "name": "Payment Reminder",
      "type": "Email",
      "status": "Draft",
      "content": "This is a friendly reminder that your invoice is due.",
      "date": "Oct 20, 2023",
    },
    {
      "name": "Black Friday Promo",
      "type": "WhatsApp",
      "status": "Active",
      "content": "Exclusive 50% off just for you! Use code SALE50.",
      "date": "Oct 18, 2023",
    },
    {
      "name": "Feedback Request",
      "type": "SMS",
      "status": "Draft",
      "content": "How was your experience with our support team?",
      "date": "Oct 15, 2023",
    },
  ];

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 4,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              "Message Templates",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and organize all your communication scripts here.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {Navigator.pushNamed(context, "/create-template");},
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
                hintText: "Search by name or content...",
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _dropdownButton("All Types"),
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

  Widget _dropdownButton(String text) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list),
      label: Text(text),
    );
  }

  Widget _statusPill(String value) {
    final isSelected = selectedStatus == value;

    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = value);
      },
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
          Expanded(flex: 3, child: Text("TEMPLATE NAME")),
          Expanded(flex: 2, child: Text("TYPE")),
          Expanded(flex: 4, child: Text("CONTENT PREVIEW")),
          Expanded(flex: 2, child: Text("LAST MODIFIED")),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t["name"],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  t["status"],
                  style: TextStyle(
                    fontSize: 12,
                    color: t["status"] == "Active"
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _typeChip(t["type"])),
          Expanded(
            flex: 4,
            child: Text(
              t["content"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              t["date"],
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

  Widget _typeChip(String type) {
    Color color;
    switch (type) {
      case "WhatsApp":
        color = Colors.green;
        break;
      case "SMS":
        color = Colors.blue;
        break;
      case "Email":
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(type),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Showing 1 to 5 of 24 entries"),
          Row(
            children: [
              Icon(Icons.chevron_left),
              SizedBox(width: 6),
              Text("1"),
              SizedBox(width: 6),
              Text("2"),
              SizedBox(width: 6),
              Text("3"),
              SizedBox(width: 6),
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
