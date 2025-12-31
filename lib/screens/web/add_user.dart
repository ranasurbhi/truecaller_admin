import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class AddUserWebScreen extends StatefulWidget {
  const AddUserWebScreen({super.key});

  @override
  State<AddUserWebScreen> createState() => _AddUserWebScreenState();
}

class _AddUserWebScreenState extends State<AddUserWebScreen> {
  Uint8List? _profileImageBytes;
  String? _profileImageName;

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

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 1, // Team Members active
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_header(), const SizedBox(height: 20), _formCard()],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Team Members > Add New",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          "Add New User Account",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          "Enter details to create a new account for a telecaller, assign roles and teams.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= FORM CARD =================

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileSection(),
            _divider(),
            _personalDetailsSection(),
            _divider(),
            _roleAssignmentSection(),
            const SizedBox(height: 20),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE =================

  Widget _profileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Picture",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                "Upload a photo to identify the user in the system.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _profileActions(),
      ],
    );
  }

  Widget _profileActions() {
    return Row(
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
              _profileImageName ?? "Click to upload or drag and drop",
              style: const TextStyle(color: Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  // ================= PERSONAL DETAILS =================

  Widget _personalDetailsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionInfo(
          "Personal Details",
          "Basic identification information for the new user account.",
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _rowInputs("Full Name", "Email Address"),
              const SizedBox(height: 12),
              _rowInputs("Phone Number", "Password", obscureSecond: true),
            ],
          ),
        ),
      ],
    );
  }

  // ================= ROLE =================

  Widget _roleAssignmentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionInfo(
          "Role & Assignment",
          "Define the user's responsibilities, access level, and team placement.",
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _inputField("Assign Role", "Select a role..."),
              const SizedBox(height: 12),
              _rowInputs(
                "Team Assignment (Optional)",
                "Date of Joining (Optional)",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= SHARED =================

  Widget _sectionInfo(String title, String desc) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _rowInputs(String a, String b, {bool obscureSecond = false}) {
    return Row(
      children: [
        Expanded(child: _inputField(a, "e.g. $a")),
        const SizedBox(width: 16),
        Expanded(child: _inputField(b, "e.g. $b", obscureText: obscureSecond)),
      ],
    );
  }

  Widget _inputField(String label, String hint, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Divider(),
  );

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(onPressed: () {}, child: const Text("Cancel")),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check, size: 18),
          label: const Text("Add User"),
        ),
      ],
    );
  }
}
