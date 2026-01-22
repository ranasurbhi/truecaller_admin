import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class AddUserWebScreen extends StatefulWidget {
  const AddUserWebScreen({super.key});

  @override
  State<AddUserWebScreen> createState() => _AddUserWebScreenState();
}

class _AddUserWebScreenState extends State<AddUserWebScreen> {
  static const String apiUrl = "http://localhost:3000/web/users";

  Uint8List? _profileImageBytes;
  String? _profileImageName;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();
  final teamController = TextEditingController();
  final dojController = TextEditingController();

  bool isSubmitting = false;

  /* ================= IMAGE PICK ================= */

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.single.bytes!;
        _profileImageName = result.files.single.name;
      });
    }
  }

  /* ================= SUBMIT ================= */

  Future<void> _submitUser() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError("Name, Email and Password are required");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final request =
          http.MultipartRequest("POST", Uri.parse(apiUrl));

      request.fields["name"] = nameController.text.trim();
      request.fields["email"] = emailController.text.trim();
      request.fields["password"] = passwordController.text;
      request.fields["phone"] = phoneController.text.trim();
      request.fields["role"] =
          roleController.text.trim().isEmpty ? "agent" : roleController.text.trim();
      request.fields["team"] = teamController.text.trim();

      if (dojController.text.trim().isNotEmpty) {
        request.fields["date_of_joining"] = dojController.text.trim();
      }

      if (_profileImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "profile_image",
            _profileImageBytes!,
            filename: _profileImageName ?? "profile.png",
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode == 200 && json["success"] == true) {
        _showSuccess();
        _clearForm();
      } else {
        _showError(json["message"] ?? "Failed to add user");
      }
    } catch (e) {
      _showError("Server error");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  /* ================= HELPERS ================= */

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("User added successfully"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    roleController.clear();
    teamController.clear();
    dojController.clear();
    setState(() {
      _profileImageBytes = null;
      _profileImageName = null;
    });
  }

  /* ================= UI ================= */

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
            const SizedBox(height: 20),
            _formCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Team Members > Add New",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 8),
        Text("Add New User Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        SizedBox(height: 4),
        Text(
          "Create a new user and assign role and team.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _formCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _profileSection(),
            _divider(),
            _personalDetails(),
            _divider(),
            _roleSection(),
            const SizedBox(height: 24),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _profileSection() {
    return Row(
      children: [
        _sectionInfo("Profile Picture", "Upload user photo."),
        const SizedBox(width: 24),
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _profileImageBytes != null
                  ? MemoryImage(_profileImageBytes!)
                  : null,
              child: _profileImageBytes == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: _pickProfileImage,
              child: Container(
                width: 280,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _profileImageName ?? "Click to upload image",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _personalDetails() {
    return Row(
      children: [
        _sectionInfo("Personal Details", "Basic user information."),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _row(nameController, emailController, "Full Name", "Email"),
              const SizedBox(height: 12),
              _row(phoneController, passwordController,
                  "Phone", "Password", obscureSecond: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleSection() {
    return Row(
      children: [
        _sectionInfo("Role & Assignment", "Role and team."),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _input("Role (admin / agent)", roleController),
              const SizedBox(height: 12),
              _row(teamController, dojController,
                  "Team", "Date of Joining (YYYY-MM-DD)"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionInfo(String t, String d) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(d, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _row(
    TextEditingController a,
    TextEditingController b,
    String la,
    String lb, {
    bool obscureSecond = false,
  }) {
    return Row(
      children: [
        Expanded(child: _input(la, a)),
        const SizedBox(width: 16),
        Expanded(child: _input(lb, b, obscure: obscureSecond)),
      ],
    );
  }

  Widget _input(String label, TextEditingController c,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(),
      );

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(onPressed: _clearForm, child: const Text("Cancel")),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitUser,
          child: const Text("Add User"),
        ),
      ],
    );
  }
}
