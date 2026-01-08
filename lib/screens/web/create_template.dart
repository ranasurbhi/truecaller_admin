import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/base_layout.dart';

class CreateWhatsappTemplateScreen extends StatefulWidget {
  const CreateWhatsappTemplateScreen({super.key});

  @override
  State<CreateWhatsappTemplateScreen> createState() =>
      _CreateWhatsappTemplateScreenState();
}

class _CreateWhatsappTemplateScreenState
    extends State<CreateWhatsappTemplateScreen> {
  // ================= CONTROLLERS =================

  final TextEditingController templateNameCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  // ================= FILE =================

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
      selectedIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _formSection()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _whatsappPreview()),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= LEFT FORM =================

  Widget _formSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _templateNameField(),
          const SizedBox(height: 16),
          _infoBox(),
          const SizedBox(height: 16),
          _headerAttachment(),
          const SizedBox(height: 20),
          _messageEditor(),
          const SizedBox(height: 16),
          _footerActions(),
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
              "Create New WhatsApp Template",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              "Design message templates for your telecallers.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _templateNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Template Name", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: templateNameCtrl,
          decoration: InputDecoration(
            hintText: "e.g., Welcome Message - Campaign A",
            isDense: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        "Using Dynamic Variables\n\n"
        "Insert variables like {{customer_name}} to personalize messages.",
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  // ================= HEADER ATTACHMENT (FIXED) =================

  Widget _headerAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Header Attachment (Optional)",
            style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickHeaderFile,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: headerFileName == null
                  ? const Text(
                      "Click to upload or drag and drop\n"
                      "JPG, PNG, PDF (Max 10MB)",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : Text(
                      headerFileName!,
                      style: const TextStyle(fontSize: 12),
                    ),
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
        headerFileBytes = result.files.single.bytes!;
        headerFileName = result.files.single.name;
      });
    }
  }

  // ================= MESSAGE EDITOR =================

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
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
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

  // ================= TEXT FORMATTING (WORKING) =================

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
            child: Text("Insert Variable",
                style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  void _wrapSelection(String wrapper) {
    final text = messageCtrl.text;
    final sel = messageCtrl.selection;

    if (!sel.isValid || sel.isCollapsed) return;

    final selected =
        text.substring(sel.start, sel.end);

    final newText = text.replaceRange(
      sel.start,
      sel.end,
      "$wrapper$selected$wrapper",
    );

    messageCtrl.text = newText;
    messageCtrl.selection = TextSelection.collapsed(
      offset: sel.start + selected.length + 2,
    );

    setState(() {});
  }

  void _insertVariable(String variable) {
    final text = messageCtrl.text;
    final sel = messageCtrl.selection;

    final newText =
        text.replaceRange(sel.start, sel.end, variable);

    messageCtrl.text = newText;
    messageCtrl.selection = TextSelection.collapsed(
      offset: sel.start + variable.length,
    );

    setState(() {});
  }

  Widget _footerActions() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text("Save Template"),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  // ================= RIGHT PREVIEW =================

  Widget _whatsappPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "WHATSAPP PREVIEW",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _phoneMockup(),
          ],
        ),
      ),
    );
  }

  Widget _phoneMockup() {
    return Container(
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
                    ? "Message preview will appear here..."
                    : messageCtrl.text,
                style: const TextStyle(fontSize: 12),
              ),
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
