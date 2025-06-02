import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_ui_style.dart'; 
import '../../widgets/custom_button.dart'; 

class UserProfileScreen extends StatefulWidget {
  final String studentId;

  const UserProfileScreen({super.key, required this.studentId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance
          .collection('profiles') // Profiles collection in Firestore
          .doc(widget.studentId)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        title: Text('Student Profile', style: headerTextStyle),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('profiles')
            .doc(widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student not found'));
          }

          final data = snapshot.data!.data()!;

          if (!_isEditing) {
            _studentNameController.text = data['studentName'] ?? '';
            _studentICController.text = data['studentIC'] ?? '';
            _parentNameController.text = data['parentName'] ?? '';
            _parentPhoneController.text = data['parentPhone'] ?? '';
            _parentICController.text = data['parentIC'] ?? '';
            _parentAddressController.text = data['parentAddress'] ?? '';
            _ageController.text = data['age'] ?? '';
            _genderController.text = data['gender'] ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacingLarge),
                      Hero(
                        tag: 'avatar_${widget.studentId}',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            (data['studentName'] ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpacing),
                      Text(
                        data['studentName'] ?? 'No name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpacingSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cake,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Age: ${data['age'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: kSpacing),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data['gender'] ?? 'N/A',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpacingLarge),
                    ],
                  ),
                ),

                // Profile Form
                Padding(
                  padding: const EdgeInsets.all(kSpacing),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Student Information'),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _studentNameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Student Name',
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _studentICController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Student IC',
                            prefixIcon: Icon(Icons.badge_outlined, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacingLarge),

                        _buildSectionHeader('Parent Information'),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _parentNameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Parent Name',
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _parentPhoneController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Parent Phone',
                            prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _parentICController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Parent IC',
                            prefixIcon: Icon(Icons.badge_outlined, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacing),
                        TextFormField(
                          controller: _parentAddressController,
                          enabled: _isEditing,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Parent Address',
                            prefixIcon: Icon(Icons.home_outlined, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: kSpacingLarge),

                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: kSpacing),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _updateProfile,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Changes'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kSpacing),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: primaryColor,
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
}
