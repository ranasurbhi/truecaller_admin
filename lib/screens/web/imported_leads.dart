import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class ImportedLeadsWebScreen extends StatefulWidget {
  const ImportedLeadsWebScreen({
    super.key,
    required this.importedLeads,
  });

  final List<Map<String, dynamic>> importedLeads;

  @override
  State<ImportedLeadsWebScreen> createState() =>
      _ImportedLeadsWebScreenState();
}

class _ImportedLeadsWebScreenState
    extends State<ImportedLeadsWebScreen> {
  final Set<int> selectedRows = {};

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 5,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 16),
            _filtersRow(),
            const SizedBox(height: 16),
            _tableCard(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Imported Leads",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage, search, and edit all your imported lead data in one place.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text("Export CSV"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.upload),
              label: const Text("Import New Leads"),
            ),
          ],
        ),
      ],
    );
  }

  // ================= FILTERS =================

  Widget _filtersRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by name, email, or phone...",
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _filterButton("All Campaigns"),
            const SizedBox(width: 8),
            _filterButton("Import Date: All"),
            const SizedBox(width: 8),
            _filterButton("Status: All"),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: const Text("Source: CSV Import"),
              onDeleted: () {},
            ),
            TextButton(onPressed: () {}, child: const Text("Clear all")),
          ],
        ),
      ],
    );
  }

  Widget _filterButton(String text) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.expand_more),
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
          ...widget.importedLeads
              .asMap()
              .entries
              .map(_tableRow)
              .toList(),
          const Divider(height: 1),
          _pagination(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Checkbox(
            value: selectedRows.length ==
                widget.importedLeads.length,
            onChanged: (v) {
              setState(() {
                v == true
                    ? selectedRows.addAll(
                        List.generate(
                            widget.importedLeads.length, (i) => i),
                      )
                    : selectedRows.clear();
              });
            },
          ),
          const Expanded(flex: 2, child: Text("NAME")),
          const Expanded(child: Text("STATUS")),
          const Expanded(child: Text("PHONE NUMBER")),
          const Expanded(child: Text("EMAIL")),
          const Expanded(child: Text("CAMPAIGN")),
          const Expanded(child: Text("IMPORT DATE")),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _tableRow(MapEntry<int, Map<String, dynamic>> entry) {
    final index = entry.key;
    final lead = entry.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          Checkbox(
            value: selectedRows.contains(index),
            onChanged: (v) {
              setState(() {
                v == true
                    ? selectedRows.add(index)
                    : selectedRows.remove(index);
              });
            },
          ),

          // NAME + AVATAR
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    (lead["Full Name"] ?? "U")[0],
                  ),
                ),
                const SizedBox(width: 8),
                Text(lead["Full Name"] ?? ""),
              ],
            ),
          ),

          Expanded(child: _statusChip(lead["status"])),
          Expanded(child: Text(lead["Phone Number"] ?? "")),
          Expanded(child: Text(lead["Email"] ?? "")),
          const Expanded(child: Text("—")),
          Expanded(child: Text(lead["importDate"])),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  // ================= PAGINATION =================

  Widget _pagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Showing 1 to 10 of results"),
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

  // ================= STATUS =================

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Active":
        color = Colors.green;
        break;
      case "Pending":
        color = Colors.orange;
        break;
      case "Do Not Call":
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color, fontSize: 12),
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
