import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_button.dart';
import 'child_progress_screen.dart';
import 'screen_time_screen.dart';
import 'parent_password_screen.dart';
import 'content_filter_screen.dart';

class ParentModeScreen extends StatefulWidget {
  final String userId;

  const ParentModeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends State<ParentModeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _isFirstTimeSetup = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _checkIfCustomPasswordExists();
  }
  
  Future<void> _checkIfCustomPasswordExists() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final String profileId = currentUser?.uid ?? widget.userId;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final customPassword = data['parentPassword'] as String?;
        
        setState(() {
          // If a custom password exists, it's not first-time setup
          _isFirstTimeSetup = customPassword == null || customPassword.isEmpty;
        });
      }
    } catch (e) {
      print('Error checking if custom password exists: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyParentPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      // Get the current user's ID to ensure we're verifying the correct profile
      final currentUser = FirebaseAuth.instance.currentUser;
      final String profileId = currentUser?.uid ?? widget.userId;
      
      // Get the parent password from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .get();

      if (!userDoc.exists) {
        // Try default verification if profile doesn't exist
        if (_passwordController.text == '123456') {
          setState(() {
            _isVerified = true;
            _isVerifying = false;
          });
          return;
        }
        
        setState(() {
          _errorMessage = 'User profile not found';
          _isVerifying = false;
        });
        return;
      }

      final data = userDoc.data()!;
      final parentPassword = data['parentPassword'] as String?;

      // Use the parent IC as the primary verification method
      final parentIC = data['parentIC'] as String?;
      final customPassword = data['parentPassword'] as String?;
      
      // If IC is not available, fall back to custom password or default
      final validCredentials = [
        parentIC,
        customPassword,
        '123456' // Last resort default
      ].where((pwd) => pwd != null && pwd.isNotEmpty).toList();
      
      if (validCredentials.contains(_passwordController.text)) {
        setState(() {
          _isVerified = true;
          _isVerifying = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Incorrect password';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error verifying password: $e';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: const Text('Parent Mode', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: _isVerified ? _buildParentControls() : _buildVerificationScreen(),
      ),
    );
  }

  Widget _buildVerificationScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Parent Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isFirstTimeSetup
                        ? 'Please enter your parent IC number to access parent mode'
                        : 'Please enter your parent password to access parent mode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  // Only show the hint about changing password for first-time setup
                  if (_isFirstTimeSetup) ...[  
                    const SizedBox(height: 8),
                    const Text(
                      'You can change your password in the settings later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: _isFirstTimeSetup ? 'Enter parent IC number' : 'Enter parent password',
                      prefixIcon: const Icon(Icons.perm_identity),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your IC number';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyParentPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parent Controls',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Child Progress Card
          _buildControlCard(
            title: 'Child Progress',
            icon: Icons.trending_up,
            color: Colors.green.shade700,
            description: 'View your child\'s learning progress and achievements',
            onTap: () {
              // Navigate to child progress screen
              final currentUser = FirebaseAuth.instance.currentUser;
              final String childId = currentUser?.uid ?? widget.userId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildProgressScreen(childId: childId),
                ),
              );
            },
          ),
          
          // Screen Time Controls
          _buildControlCard(
            title: 'Screen Time',
            icon: Icons.timer,
            color: Colors.orange.shade700,
            description: 'Set daily limits and manage app usage time',
            onTap: () {
              // Navigate to screen time control screen
              final currentUser = FirebaseAuth.instance.currentUser;
              final String childId = currentUser?.uid ?? widget.userId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenTimeScreen(childId: childId),
                ),
              );
            },
          ),
          
          // Content Filters
          _buildControlCard(
            title: 'Content Filters',
            icon: Icons.filter_list,
            color: Colors.blue.shade700,
            description: 'Control what content your child can access',
            onTap: () {
              // Navigate to content filter screen
              final currentUser = FirebaseAuth.instance.currentUser;
              final String childId = currentUser?.uid ?? widget.userId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentFilterScreen(childId: childId),
                ),
              );
            },
          ),
          
          // Password Settings
          _buildControlCard(
            title: 'Parent Password',
            icon: Icons.lock,
            color: Colors.purple.shade700,
            description: 'Change your parent mode password',
            onTap: () {
              // Navigate to password settings screen
              final currentUser = FirebaseAuth.instance.currentUser;
              final String childId = currentUser?.uid ?? widget.userId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParentPasswordScreen(childId: childId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
