import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  Uint8List? _profileImageBytes;
  bool isActive = true;

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
      child: SingleChildScrollView(
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
            OutlinedButton(onPressed: () {}, child: const Text("Cancel")),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () {}, child: const Text("Save Changes")),
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
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Sarah Jenkins",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                "Telecaller Agent",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Chip(
                    label: Text("Active"),
                    backgroundColor: Color(0xFFE7F6EC),
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                ],
              ),
              const Divider(height: 32),
              _infoRow("Joined", "Oct 24, 2023"),
              const SizedBox(height: 8),
              _infoRow("Last Login", "2 hours ago"),
            ],
          ),
        ),
        SizedBox(height: 10),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account Status",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Active User", style: TextStyle(fontSize: 13)),
                      const Text(
                        "User can login and perform actions",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.7, // 1.0 = default, try 0.7–0.9
                    child: Switch(
                      value: isActive,
                      onChanged: (v) {
                        setState(() => isActive = v);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                      Text(
                        "Permanently remove this user",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
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
          _input("Full Name", "Sarah Jenkins"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _input("Email Address", "sarah.jenkins@company.com"),
              ),
              const SizedBox(width: 16),
              Expanded(child: _input("Phone Number", "+1 (555) 000-1234")),
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
              Expanded(child: _input("Assigned Role", "Telecaller Agent")),
              const SizedBox(width: 16),
              Expanded(child: _input("Reports To", "Dwight Schrute")),
            ],
          ),
          const SizedBox(height: 12),
          _input("Team Assignment", "Sales - North Region"),
          const SizedBox(height: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Password (Last changed 3 months ago)"),
              TextButton(onPressed: () {}, child: const Text("Reset Password")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _input("New Password", "********", obscure: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _input("Confirm Password", "********", obscure: true),
              ),
            ],
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
                if (icon != null) Icon(icon, size: 18, color: Colors.blue),
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

  Widget _input(String label, String value, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: value,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String a, String b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: const TextStyle(color: Colors.grey)),
        Text(b),
      ],
    );
  }
}
