import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;
  const EditUserScreen({super.key, required this.userId});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  Uint8List? _profileImageBytes;
  bool isActive = true;

  // ================= CONTROLLERS =================
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final roleController = TextEditingController();
  final teamController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ================= LOAD USER =================
  Future<void> _loadUser() async {
    final res = await http.get(
      Uri.parse("http://localhost:3000/web/users/${widget.userId}"),
    );

    final json = jsonDecode(res.body);
    final data = json["data"];

    setState(() {
      nameController.text = data["name"] ?? "";
      emailController.text = data["email"] ?? "";
      phoneController.text = data["phone"] ?? "";
      roleController.text = data["role"] ?? "";
      teamController.text = data["team"] ?? "";
      isActive = data["accepting_calls"] == 1;
    });
  }

  // ================= IMAGE PICK =================
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

  // ================= SAVE =================
  Future<void> _saveChanges() async {
    final request = http.MultipartRequest(
      "PUT",
      Uri.parse("http://localhost:3000/web/users/${widget.userId}"),
    );

    request.fields.addAll({
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "role": roleController.text,
      "team": teamController.text,
      "status": isActive ? "Active" : "Inactive",
      if (passwordController.text.isNotEmpty)
        "password": passwordController.text,
    });

    if (_profileImageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "profile_image",
          _profileImageBytes!,
          filename: "profile.png",
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 320, child: _leftProfileCard()),
                const SizedBox(width: 24),
                Expanded(child: _rightContent()),
              ],
            ),
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
            Text("Dashboard / Users / Edit Profile",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 8),
            Text("Edit User Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Save Changes",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ================= LEFT =================
  Widget _leftProfileCard() {
    return _card(
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
                    child: Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: isActive,
            title: const Text("Active User"),
            onChanged: (v) => setState(() => isActive = v),
          ),
        ],
      ),
    );
  }

  // ================= RIGHT =================
  Widget _rightContent() {
    return Column(
      children: [
        _card(
          title: "Personal Information",
          child: Column(
            children: [
              _input("Full Name", nameController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _input("Email", emailController)),
                  const SizedBox(width: 16),
                  Expanded(child: _input("Phone", phoneController)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          title: "Organization",
          child: Column(
            children: [
              _input("Role", roleController),
              const SizedBox(height: 12),
              _input("Team", teamController),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          title: "Security",
          child: _input("New Password", passwordController, obscure: true),
        ),
      ],
    );
  }

  // ================= SHARED =================
  Widget _card({Widget? child, String? title}) {
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
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          if (title != null) const SizedBox(height: 16),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
