import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/background_container.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_auth_button.dart';
import '../widgets/custom_popup.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);
    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser?.uid;
      if (uid != null) {
        // Store user ID and email in SharedPreferences for reliable access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', uid);
        await prefs.setString('currentUserEmail', currentUser?.email ?? '');
        await prefs.setString('currentUserDisplayName', currentUser?.displayName ?? '');
        await prefs.setBool('isUserLoggedIn', true);
        print('Stored user credentials in SharedPreferences: User ID = $uid, Email = ${currentUser?.email}');
        
        final doc = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
        
        // If profile exists, also store the username
        if (doc.exists && doc.data() != null) {
          final username = doc.data()?['name'] as String? ?? '';
          await prefs.setString('currentUsername', username);
          print('Stored username in SharedPreferences: $username');
        }

        // If the user is an admin, redirect them to the Admin Home Screen
        if (_email.text.trim() == 'admin@gmail.com') {
          Navigator.pushReplacementNamed(context, '/adminHome');
        }
        // Check user profile and age (if needed for user flow)
        else if (doc.exists) {
          final age = int.tryParse(doc.data()?['age'] ?? '0') ?? 0;
          if (age == 4) {
            Navigator.pushReplacementNamed(context, '/module4');
          } else if (age == 5) {
            Navigator.pushReplacementNamed(context, '/module5');
          } else {
            Navigator.pushReplacementNamed(context, '/module6');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Wrong password provided.";
          break;
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
      }
      showThemePopup(context, message);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Store user ID and Google info in SharedPreferences
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser?.uid;
      
      if (uid != null) {
        // Store user credentials in SharedPreferences for reliable access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', uid);
        await prefs.setString('currentUserEmail', currentUser?.email ?? '');
        await prefs.setString('currentUserDisplayName', currentUser?.displayName ?? '');
        await prefs.setBool('isUserLoggedIn', true);
        print('Stored Google user credentials in SharedPreferences: User ID = $uid, Email = ${currentUser?.email}, Name = ${currentUser?.displayName}');
      }
      
      // Navigate to appropriate module based on profile
      final doc = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
      
      if (doc.exists) {
        final age = int.tryParse(doc.data()?['age'] ?? '0') ?? 0;
        if (age == 4) {
          Navigator.pushReplacementNamed(context, '/module4');
        } else if (age == 5) {
          Navigator.pushReplacementNamed(context, '/module5');
        } else {
          Navigator.pushReplacementNamed(context, '/module6');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      showThemePopup(context, "Google sign in failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundContainer(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset('assets/logo.png', width: 180),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _email,
                        label: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      _buildPasswordField(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton.login(
                          onPressed: _login,
                        ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black38, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.black38, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomAuthButton(
                        label: "Continue with Google",
                        onPressed: isLoading ? null : _loginWithGoogle,
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                ),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blue),
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0.7),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _password,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: const Icon(Icons.lock, color: Colors.blue),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0.7),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
    );
  }
}
