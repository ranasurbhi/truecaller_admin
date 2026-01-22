import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/base_layout.dart';

class CreateWhatsappTemplateScreen extends StatefulWidget {
  const CreateWhatsappTemplateScreen({super.key});

  @override
  State<CreateWhatsappTemplateScreen> createState() =>
      _CreateWhatsappTemplateScreenState();
}

class _CreateWhatsappTemplateScreenState
    extends State<CreateWhatsappTemplateScreen> {
  // ================= CONFIG =================
  final String apiUrl =
      "http://127.0.0.1:3000/api/message-templates";

  // ================= CONTROLLERS =================
  final TextEditingController templateNameCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  // ================= STATE =================
  bool isSaving = false;

  // ================= FILE (NOT SENT YET) =================
  Uint8List? headerFileBytes;
  String? headerFileName;

  // ================= VARIABLES =================
  final List<String> variables = [
    "{{customer_name}}",
    "{{telecaller_name}}",
    "{{campaign_name}}",
  ];

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return WebLayout(
      selectedIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _formSection()),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: _previewSection()),
          ],
        ),
      ),
    );
  }

  // ================= FORM =================
  Widget _formSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _templateName(),
          const SizedBox(height: 16),
          _infoBox(),
          const SizedBox(height: 16),
          _headerAttachment(),
          const SizedBox(height: 20),
          _messageEditor(),
          const SizedBox(height: 20),
          _actions(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create WhatsApp Template",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Create reusable WhatsApp message templates.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  Widget _templateName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Template Name", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: templateNameCtrl,
          decoration: InputDecoration(
            hintText: "Welcome Message – Campaign A",
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Text(
        "Use variables like {{customer_name}} to personalize messages.",
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  // ================= FILE PICKER =================
  Widget _headerAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Header Attachment (optional)",
            style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickHeaderFile,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: headerFileName == null
                  ? const Text(
                      "Click to upload (JPG, PNG, PDF)",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : Text(headerFileName!,
                      style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickHeaderFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ["jpg", "png", "pdf"],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        headerFileBytes = result.files.single.bytes;
        headerFileName = result.files.single.name;
      });
    }
  }

  // ================= MESSAGE =================
  Widget _messageEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Message Content", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _editorToolbar(),
              const Divider(height: 1),
              TextField(
                controller: messageCtrl,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText:
                      "Hi {{customer_name}}, this is {{telecaller_name}}...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${messageCtrl.text.length} characters",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _editorToolbar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.format_bold, size: 18),
          onPressed: () => _wrapSelection("*"),
        ),
        IconButton(
          icon: const Icon(Icons.format_italic, size: 18),
          onPressed: () => _wrapSelection("_"),
        ),
        IconButton(
          icon: const Icon(Icons.strikethrough_s, size: 18),
          onPressed: () => _wrapSelection("~"),
        ),
        const VerticalDivider(),
        PopupMenuButton<String>(
          onSelected: _insertVariable,
          itemBuilder: (_) => variables
              .map((v) => PopupMenuItem(value: v, child: Text(v)))
              .toList(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child:
                Text("Insert Variable", style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  void _wrapSelection(String wrapper) {
    final sel = messageCtrl.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final text = messageCtrl.text;
    final selected = text.substring(sel.start, sel.end);

    messageCtrl.text =
        text.replaceRange(sel.start, sel.end, "$wrapper$selected$wrapper");

    messageCtrl.selection = TextSelection.collapsed(
      offset: sel.start + selected.length + 2,
    );
    setState(() {});
  }

  void _insertVariable(String v) {
    final sel = messageCtrl.selection;
    messageCtrl.text =
        messageCtrl.text.replaceRange(sel.start, sel.end, v);

    messageCtrl.selection =
        TextSelection.collapsed(offset: sel.start + v.length);
    setState(() {});
  }

  // ================= SAVE =================
  Widget _actions() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: isSaving ? null : _saveTemplate,
          child: isSaving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save Template"),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  Future<void> _saveTemplate() async {
    if (templateNameCtrl.text.trim().isEmpty ||
        messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and message required")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final usedVariables = variables
          .where((v) => messageCtrl.text.contains(v))
          .map((v) => v.replaceAll(RegExp(r"[{}]"), ""))
          .toList();

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": templateNameCtrl.text.trim(),
          "message": messageCtrl.text.trim(),
          "variables": usedVariables,
        }),
      );

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template created")),
        );
        Navigator.pop(context);
      } else {
        throw Exception();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save template")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  // ================= PREVIEW =================
  Widget _previewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text("WHATSAPP PREVIEW",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            width: 220,
            height: 420,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF075E54),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("JD  John Doe",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messageCtrl.text.isEmpty
                          ? "Message preview..."
                          : messageCtrl.text,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
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
