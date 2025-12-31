import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddUserWebScreen extends StatefulWidget {
  const AddUserWebScreen({super.key});

  @override
  State<AddUserWebScreen> createState() => _AddUserWebScreenState();
}

class _AddUserWebScreenState extends State<AddUserWebScreen> {
  int selectedIndex = 1; // default active item
  final List<Map<String, dynamic>> sidebarItems = [
    {"icon": Icons.dashboard, "title": "Dashboard"},
    {"icon": Icons.people, "title": "Team Members"},
    {"icon": Icons.campaign, "title": "Campaigns"},
    {"icon": Icons.bar_chart, "title": "Reports"},
    {"icon": Icons.settings, "title": "Settings"},
  ];
  Uint8List? _profileImageBytes;
  String? _profileImageName;

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // IMPORTANT for web
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Row(
        children: [
          /// 🔹 SIDEBAR
          sidebar(),

          /// 🔹 MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Breadcrumb
                    Row(
                      children: const [
                        Text(
                          "Team Members",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text("Add New", style: TextStyle(fontSize: 12)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Title
                    const Text(
                      "Add New User Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Enter details to create a new account for a telecaller, assign roles and teams.",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    /// FORM CARD
                    Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
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
                              profileSection(),
                              divider(),
                              personalDetailsSection(),
                              divider(),
                              roleAssignmentSection(),
                              const SizedBox(height: 20),
                              actionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebar() {
    return Container(
      width: 230,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TOP BRANDING (MISSING PART)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: const Text(
                    "TA",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TeleAdmin",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Manager Panel",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          const SizedBox(height: 8),

          /// 🔹 MENU LIST (SCROLLABLE)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final item = sidebarItems[index];
                final bool isActive = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.blue.shade50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item["icon"],
                          size: 18,
                          color: isActive ? Colors.blue : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item["title"],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? Colors.blue
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 FOOTER USER (BOTTOM)
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                CircleAvatar(radius: 14),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alex Morgan", style: TextStyle(fontSize: 12)),
                    SizedBox(height: 2),
                    Text(
                      "alex@teleadmin.com",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 700;

        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileText(),
                  const SizedBox(height: 12),
                  _profileActions(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _profileText()),
                  const SizedBox(width: 24),
                  _profileActions(),
                ],
              );
      },
    );
  }

  Widget _profileText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Profile Picture", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text(
          "Upload a photo to identify the user in the system.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _profileActions() {
  return Row(
    children: [
      /// PROFILE PREVIEW
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
          image: _profileImageBytes != null
              ? DecorationImage(
                  image: MemoryImage(_profileImageBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _profileImageBytes == null
            ? const Icon(Icons.person, size: 40, color: Colors.grey)
            : null,
      ),

      const SizedBox(width: 20),

      /// UPLOAD BOX
      InkWell(
        onTap: _pickProfileImage, // 👈 ACTUAL UPLOAD
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.shade200,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload, color: Colors.blue),
              const SizedBox(height: 4),
              Text(
                _profileImageName ?? "Click to upload or drag and drop",
                style: const TextStyle(fontSize: 12, color: Colors.blue),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                "SVG, PNG, JPG or GIF (max. 800×800px)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


  Widget personalDetailsSection() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// 🔹 LEFT INFO COLUMN
      sectionInfo(
        "Personal Details",
        "Basic identification information for the new user account.",
      ),

      const SizedBox(width: 24),

      /// 🔹 RIGHT FORM COLUMN
      Expanded(
        flex: 6,
        child: Column(
          children: [
            /// Row 1: Full Name + Email
            Row(
              children: [
                Expanded(
                  child: inputField(
                    "Full Name",
                    "e.g. Sarah Jenkins",
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: inputField(
                    "Email Address",
                    "sarah@example.com",
                    prefixIcon: Icons.email_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Row 2: Phone + Password
            Row(
              children: [
                Expanded(
                  child: inputField(
                    "Phone Number",
                    "+1 (555) 000-0000",
                    prefixIcon: Icons.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: inputField(
                    "Password",
                    "••••••••",
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget roleAssignmentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionInfo(
          "Role & Assignment",
          "Define the user's responsibilities, access level, and team placement.",
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              inputField("Assign Role", "Select a role..."),
              const SizedBox(height: 12),
              rowInputs(
                "Team Assignment (Optional)",
                "Date of Joining (Optional)",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sectionInfo(String title, String desc) {
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

  Widget rowInputs(String a, String b) {
    return Row(
      children: [
        Expanded(child: inputField(a, "e.g. $a")),
        const SizedBox(width: 16),
        Expanded(child: inputField(b, "e.g. $b")),
      ],
    );
  }

  Widget inputField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool obscureText = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: Colors.grey.shade200),
    );
  }

  Widget actionButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      /// CANCEL BUTTON
      OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          "Cancel",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),

      const SizedBox(width: 12),

      /// ADD USER BUTTON
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.check, size: 18),
        label: const Text(
          "Add User",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ],
  );
}

  
}
