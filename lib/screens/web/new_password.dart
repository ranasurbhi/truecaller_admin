import 'package:flutter/material.dart';

class SetNewPasswordWebScreen extends StatefulWidget {
  const SetNewPasswordWebScreen({super.key});

  @override
  State<SetNewPasswordWebScreen> createState() =>
      _SetNewPasswordWebScreenState();
}

class _SetNewPasswordWebScreenState
    extends State<SetNewPasswordWebScreen> {
  // ================= STATE =================

  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController =
      TextEditingController();
  final TextEditingController confirmController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  // ================= PASSWORD CHECKS =================

  bool get hasMinLength => passwordController.text.length >= 8;
  bool get hasNumber =>
      RegExp(r'\d').hasMatch(passwordController.text);
  bool get hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]')
          .hasMatch(passwordController.text);

  int get strengthScore =>
      [hasMinLength, hasNumber, hasSpecialChar]
          .where((e) => e)
          .length;

  double get strengthValue => strengthScore / 3;

  String get strengthLabel {
    switch (strengthScore) {
      case 3:
        return "STRONG";
      case 2:
        return "MEDIUM";
      default:
        return "WEAK";
    }
  }

  Color get strengthColor {
    switch (strengthScore) {
      case 3:
        return Colors.green;
      case 2:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

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
              "Set New Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            const Text(
              "Choose a strong password to secure your account and regain access.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _label("New Password"),
            _passwordField(),
            const SizedBox(height: 10),

            _strengthIndicator(),
            const SizedBox(height: 16),

            _label("Confirm New Password"),
            _confirmPasswordField(),
            const SizedBox(height: 24),

            _resetButton(),
            const SizedBox(height: 16),

            _backToLogin(),
            const SizedBox(height: 16),

            _expiryNote(),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.withOpacity(0.1),
      child: const Icon(Icons.lock,
          color: Colors.blue, size: 28),
    );
  }

  Widget _label(String text) {
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

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Min. 8 characters",
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() => obscurePassword = !obscurePassword);
          },
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Password is required";
        }
        if (strengthScore < 2) {
          return "Password is too weak";
        }
        return null;
      },
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: confirmController,
      obscureText: obscureConfirm,
      decoration: InputDecoration(
        hintText: "Re-type your password",
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          icon: Icon(
            obscureConfirm
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() => obscureConfirm = !obscureConfirm);
          },
        ),
      ),
      validator: (v) {
        if (v != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  Widget _strengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "STRENGTH: $strengthLabel",
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${(strengthValue * 100).toInt()}%",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: strengthValue,
          color: strengthColor,
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 8),
        _checkItem("8+ characters", hasMinLength),
        _checkItem("Special symbol", hasSpecialChar),
        _checkItem("One number", hasNumber),
      ],
    );
  }

  Widget _checkItem(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: ok ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _resetButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed:
            isLoading ? null : _handlePasswordReset,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text("Reset Password"),
      ),
    );
  }

  Widget _backToLogin() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Back to Login"),
    );
  }

  Widget _expiryNote() {
    return Row(
      children: const [
        Icon(Icons.info_outline,
            size: 14, color: Colors.grey),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            "This link will expire in 15 minutes. Ensure your password is unique and not used elsewhere.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ================= LOGIC =================

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔹 Simulated API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password reset successfully"),
      ),
    );

    Navigator.pop(context);
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
