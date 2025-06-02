import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final String studentId;

  const ProfileScreen({super.key, required this.studentId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  
  late TextEditingController _studentNameController;
  late TextEditingController _studentICController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _parentICController;
  late TextEditingController _parentAddressController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;

  @override
  void initState() {
    super.initState();
    _studentNameController = TextEditingController();
    _studentICController = TextEditingController();
    _parentNameController = TextEditingController();
    _parentPhoneController = TextEditingController();
    _parentICController = TextEditingController();
    _parentAddressController = TextEditingController();
    _ageController = TextEditingController();
    _genderController = TextEditingController();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentICController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentICController.dispose();
    _parentAddressController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic> data) {
    _studentNameController.text = data['studentName'] ?? '';
    _studentICController.text = data['studentIC'] ?? '';
    _parentNameController.text = data['parentName'] ?? '';
    _parentPhoneController.text = data['parentPhone'] ?? '';
    _parentICController.text = data['parentIC'] ?? '';
    _parentAddressController.text = data['parentAddress'] ?? '';
    _ageController.text = data['age']?.toString() ?? '';
    _genderController.text = data['gender'] ?? '';
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      
      // Get the current user's ID to ensure we're updating the correct profile
      final currentUser = FirebaseAuth.instance.currentUser;
      final String profileId = currentUser?.uid ?? widget.studentId;
      
      // Update the profile directly, matching the admin module approach
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .update({
        'studentName': _studentNameController.text.trim(),
        'studentIC': _studentICController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'parentPhone': _parentPhoneController.text.trim(),
        'parentIC': _parentICController.text.trim(),
        'parentAddress': _parentAddressController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _genderController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profile not found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your profile setup first',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Go to Profile Setup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.purple.shade700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.purple.shade700, width: 2),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileForm(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      (_studentNameController.text.isNotEmpty ? _studentNameController.text[0] : '?').toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _studentNameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(Icons.cake, 'Age: ${_ageController.text}'),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.person, 'Gender: ${_genderController.text}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Student Information
            _buildSectionHeader('Student Information'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentNameController,
              enabled: _isEditing,
              decoration: _buildInputDecoration('Student Name', Icons.person),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentICController,
              enabled: _isEditing,
              decoration: _buildInputDecoration('Student IC', Icons.badge),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    enabled: _isEditing,
                    decoration: _buildInputDecoration('Age', Icons.cake),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _genderController,
                    enabled: _isEditing,
                    decoration: _buildInputDecoration('Gender', Icons.person),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            
            // Parent Information
            _buildSectionHeader('Parent Information'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentNameController,
              enabled: _isEditing,
              decoration: _buildInputDecoration('Parent Name', Icons.person),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentPhoneController,
              enabled: _isEditing,
              decoration: _buildInputDecoration('Parent Phone', Icons.phone),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentICController,
              enabled: _isEditing,
              decoration: _buildInputDecoration('Parent IC', Icons.badge),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentAddressController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: _buildInputDecoration('Parent Address', Icons.home),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            
            // Save Button
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _updateProfile,
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always use the current user's ID to ensure we're getting the correct profile
    final currentUser = FirebaseAuth.instance.currentUser;
    final String profileId = currentUser?.uid ?? widget.studentId;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
        title: const Text('Child Profile', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('profiles')
              .doc(profileId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildProfileNotFound();
            }

            final data = snapshot.data!.data()!;
            _populateControllers(data);
            return _buildProfileForm(data);
          },
        ),
      ),
    );
  }
}
