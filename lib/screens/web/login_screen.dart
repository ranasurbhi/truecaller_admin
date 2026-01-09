import 'package:flutter/material.dart';
import 'package:truecaller/screens/web/forgot_password.dart';

class LoginWebScreen extends StatefulWidget {
  const LoginWebScreen({super.key});

  @override
  State<LoginWebScreen> createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends State<LoginWebScreen> {
  // ================= FORM STATE =================

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(
    text: "admin@telecall.com",
  );
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;
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
            child: _loginCard(),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

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

            // EMAIL
            _inputLabel("Email Address"),
            _emailField(),
            const SizedBox(height: 16),

            // PASSWORD
            _inputLabel("Password"),
            _passwordField(),
            const SizedBox(height: 12),

            // REMEMBER + FORGOT
            _optionsRow(),
            const SizedBox(height: 20),

            // SIGN IN
            _signInButton(),

            const SizedBox(height: 16),
            _supportText(),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
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
        hintText: "admin@telecall.com",
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Email is required";
        }
        if (!v.contains("@")) {
          return "Enter a valid email";
        }
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
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() => obscurePassword = !obscurePassword);
          },
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Password is required";
        }
        if (v.length < 6) {
          return "Minimum 6 characters";
        }
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
    return RichText(
      text: const TextSpan(
        style: TextStyle(color: Colors.grey),
        children: [
          TextSpan(text: "Technical issues? "),
          TextSpan(
            text: "Contact Support",
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔹 Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final email = emailController.text;
    final password = passwordController.text;

    // 🔹 TEMP LOGIN CHECK (replace with API)
    if (email == "admin@telecall.com" && password == "admin123") {
      // Navigate to dashboard
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/");
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
    }

    setState(() => isLoading = false);
  }

  // ================= STYLES =================

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
