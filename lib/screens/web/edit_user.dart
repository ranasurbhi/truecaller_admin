import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  static const String baseUrl = "http://localhost:3000";

  Uint8List? _profileImageBytes;
  bool isActive = true;
  bool loading = true;

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final teamCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /* ================= API ================= */

  Future<void> _loadUser() async {
    final res =
        await http.get(Uri.parse("$baseUrl/web/users/${widget.userId}"));
    final data = jsonDecode(res.body)['data'];

    setState(() {
      nameCtrl.text = data['name'] ?? '';
      emailCtrl.text = data['email'] ?? '';
      phoneCtrl.text = data['phone'] ?? '';
      roleCtrl.text = data['role'] ?? '';
      teamCtrl.text = data['team'] ?? '';
      isActive = data['status'] == "Active";
      loading = false;
    });
  }

  Future<void> _saveChanges() async {
    final req = http.MultipartRequest(
      "PUT",
      Uri.parse("$baseUrl/web/users/${widget.userId}"),
    );

    req.fields.addAll({
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "role": roleCtrl.text,
      "team": teamCtrl.text,
      "status": isActive ? "Active" : "Inactive",
    });

    if (_profileImageBytes != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          "profile_image",
          _profileImageBytes!,
          filename: "profile.png",
        ),
      );
    }

    await req.send();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/team-member');
    }
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.single.bytes!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1000) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 320, child: _leftProfileCard()),
                              const SizedBox(width: 24),
                              Expanded(child: _rightContent()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _leftProfileCard(),
                            const SizedBox(height: 24),
                            _rightContent(),
                          ],
                        );
                      },
                    ),
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
              "Dashboard / Users / Edit Profile",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Edit User Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              "Update user details, permissions, and security settings.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/team-member');
              },
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              label: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= LEFT PROFILE =================

  Widget _leftProfileCard() {
    return Column(
      children: [
        _card(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickProfileImage,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue,
                        child:
                            Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(nameCtrl.text,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(roleCtrl.text,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Chip(
                label: Text(isActive ? "Active" : "Inactive"),
                backgroundColor:
                    isActive ? const Color(0xFFE7F6EC) : Colors.grey.shade200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= RIGHT CONTENT =================

  Widget _rightContent() {
    return Column(
      children: [
        _personalInfoCard(),
        const SizedBox(height: 20),
        _organizationCard(),
        const SizedBox(height: 20),
        _securityCard(),
      ],
    );
  }

  // ================= CARDS =================

  Widget _personalInfoCard() {
    return _card(
      title: "Personal Information",
      icon: Icons.person_outline,
      child: Column(
        children: [
          _input("Full Name", nameCtrl),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _input("Email Address", emailCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _input("Phone Number", phoneCtrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _organizationCard() {
    return _card(
      title: "Organization Settings",
      icon: Icons.business,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _input("Assigned Role", roleCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _input("Reports To", TextEditingController())),
            ],
          ),
          const SizedBox(height: 12),
          _input("Team Assignment", teamCtrl),
        ],
      ),
    );
  }

  Widget _securityCard() {
    return _card(
      title: "Security",
      icon: Icons.lock_outline,
      child: Column(
        children: [
          SwitchListTile(
            value: isActive,
            onChanged: (v) => setState(() => isActive = v),
            title: const Text("Active User"),
          ),
        ],
      ),
    );
  }

  // ================= SHARED =================

  Widget _card({Widget? child, String? title, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              children: [
                if (icon != null)
                  Icon(icon, size: 18, color: Colors.blue),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          if (title != null) const SizedBox(height: 16),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          decoration: InputDecoration(
            isDense: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
