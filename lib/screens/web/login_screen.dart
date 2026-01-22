import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:truecaller/screens/web/forgot_password.dart';

class LoginWebScreen extends StatefulWidget {
  const LoginWebScreen({super.key});

  @override
  State<LoginWebScreen> createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends State<LoginWebScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController(text: "admin@test.com");
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;

  // 🔹 Backend base URL
  static const String baseUrl = "http://localhost:3000";

  // 🔹 Role → Route mapping (CONFIG, not logic)
  final Map<String, String> roleRoutes = {
    "admin": "/admin-dashboard",
    "agent": "/agent-dashboard",
  };

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
            child: _loginCard(),
          ),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _logo(),
            const SizedBox(height: 16),
            const Text(
              "Telecallers Admin",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please enter your details to sign in",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _inputLabel("Email Address"),
            _emailField(),
            const SizedBox(height: 16),
            _inputLabel("Password"),
            _passwordField(),
            const SizedBox(height: 12),
            _optionsRow(),
            const SizedBox(height: 20),
            _signInButton(),
            const SizedBox(height: 16),
            _supportText(),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue,
      child: Icon(Icons.headset_mic, color: Colors.white, size: 28),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        hintText: "email@example.com",
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Email is required";
        if (!v.contains("@")) return "Enter a valid email";
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: "••••••••",
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => obscurePassword = !obscurePassword);
          },
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Password is required";
        if (v.length < 6) return "Minimum 6 characters";
        return null;
      },
    );
  }

  Widget _optionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (v) {
                setState(() => rememberMe = v ?? false);
              },
            ),
            const Text("Remember Me"),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ForgotPasswordWebScreen(),
              ),
            );
          },
          child: const Text("Forgot Password?"),
        ),
      ],
    );
  }

  Widget _signInButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text("Sign In →"),
      ),
    );
  }

  Widget _supportText() {
    return const Text(
      "Technical issues? Contact Support",
      style: TextStyle(color: Colors.grey),
    );
  }

  // ================= LOGIN LOGIC =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final user = data["user"];
        final role = user["role"];

        final route = roleRoutes[role];
        if (route == null) {
          _showError("Unauthorized role");
          return;
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, route);
      } else {
        _showError(data["message"] ?? "Login failed");
      }
    } catch (_) {
      _showError("Server not reachable");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
      ],
    );
  }

  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F1FF), Colors.white],
      ),
    );
  }
}
