import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/background_container.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_popup.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _email = TextEditingController();

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      showThemePopup(context, "Reset link sent! Please check your email.");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // go back to login after popup
      });
    } on FirebaseAuthException catch (e) {
      showThemePopup(context, e.message ?? "Reset failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundContainer(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', width: 180),
                  const SizedBox(height: 20),
                  _buildTextField(_email, "Email", Icons.email),
                  CustomButton(
                    label: "RESET",
                    gradientColors: const [Colors.purple, Colors.deepPurple],
                    onPressed: _resetPassword,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
