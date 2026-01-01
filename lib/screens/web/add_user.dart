import 'dart:convert';
import 'dart:typed_data';

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

  Uint8List? _profileImageBytes;
  String? _profileImageName;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController teamController = TextEditingController();
  final TextEditingController dojController = TextEditingController();

  // --------------------
  // IMAGE PICKER
  // --------------------
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.single.bytes;
        _profileImageName = result.files.single.name;
      });
    }
  }


  Future<void> _submitUser() async {
    try {
      final uri = Uri.parse("http://YOUR_BACKEND_IP:3000/admin/add-user");

      final request = http.MultipartRequest("POST", uri);

      request.fields.addAll({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text.trim(),
        "role": roleController.text.trim(),
        "team": teamController.text.trim(),
        "date_of_joining": dojController.text.trim(),
      });

      if (_profileImageBytes != null && _profileImageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "profile_image",
            _profileImageBytes!,
            filename: _profileImageName,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added successfully")),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $responseBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
            _formCard(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Text(
      "Add Team Member",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _profileSection(),
            const SizedBox(height: 24),
            _personalDetailsSection(),
            const SizedBox(height: 24),
            _roleAssignmentSection(),
            const SizedBox(height: 32),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _profileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage:
          _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
          child: _profileImageBytes == null
              ? const Icon(Icons.person, size: 36)
              : null,
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Upload Profile Image"),
        ),
      ],
    );
  }

  Widget _personalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("Full Name", "e.g. Sarah", controller: nameController),
        _inputField("Email Address", "sarah@email.com",
            controller: emailController),
        _inputField("Phone Number", "+91...", controller: phoneController),
        _inputField(
          "Password",
          "••••••••",
          controller: passwordController,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _roleAssignmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("Role", "Admin / Agent", controller: roleController),
        _inputField("Team", "Optional", controller: teamController),
        _inputField("Date of Joining", "YYYY-MM-DD",
            controller: dojController),
      ],
    );
  }

  Widget _inputField(
      String label,
      String hint, {
        TextEditingController? controller,
        bool obscureText = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _clearForm,
          child: const Text("Clear"),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _submitUser,
          icon: const Icon(Icons.check),
          label: const Text("Add User"),
        ),
      ],
    );
  }
}
