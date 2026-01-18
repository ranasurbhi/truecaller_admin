import 'package:flutter/material.dart';

class ForgotPasswordWebScreen extends StatefulWidget {
  const ForgotPasswordWebScreen({super.key});

  @override
  State<ForgotPasswordWebScreen> createState() =>
      _ForgotPasswordWebScreenState();
}

class _ForgotPasswordWebScreenState
    extends State<ForgotPasswordWebScreen> {
  // ================= STATE =================

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController =
      TextEditingController();

  bool isLoading = false;

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _backgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _card(),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _card() {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _icon(),
            const SizedBox(height: 16),

            const Text(
              "Forgot Password?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            const Text(
              "Enter the email address associated with your account and "
              "we'll send you a link to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _inputLabel("Email Address"),
            _emailField(),

            const SizedBox(height: 20),

            _sendButton(),

            const SizedBox(height: 16),

            _backToLogin(),

            const SizedBox(height: 16),

            _supportText(),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.withOpacity(0.1),
      child: const Icon(
        Icons.lock_reset,
        color: Colors.blue,
        size: 28,
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        hintText: "name@company.com",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Email is required";
        }
        if (!v.contains("@")) {
          return "Enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget _sendButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : _sendResetLink,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text("Send Reset Link"),
      ),
    );
  }

  Widget _backToLogin() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
      label: const Text("Back to Login"),
    );
  }

  Widget _supportText() {
    return const Text(
      "Admin Support: support@telecallers.com",
      style: TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  // ================= LOGIC =================

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔹 Simulated API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "If the email exists, a reset link has been sent.",
        ),
      ),
    );
  }

  // ================= STYLES =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
        ),
      ],
    );
  }

  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F1FF),
          Colors.white,
        ],
      ),
    );
  }
}
