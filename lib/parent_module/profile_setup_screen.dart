import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/background_container.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_popup.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _studentName = TextEditingController();
  final TextEditingController _parentName = TextEditingController();
  final TextEditingController _parentPhone = TextEditingController();
  final TextEditingController _parentAddress = TextEditingController();
  final TextEditingController _parentIC = TextEditingController();
  final TextEditingController _studentIC = TextEditingController();

  String? selectedAge;
  String? selectedGender;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> ageOptions = ['4', '5', '6'];
  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _studentName.dispose();
    _parentName.dispose();
    _parentPhone.dispose();
    _parentAddress.dispose();
    _parentIC.dispose();
    _studentIC.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName.text = prefs.getString('studentName') ?? '';
      _parentName.text = prefs.getString('parentName') ?? '';
      _parentPhone.text = prefs.getString('parentPhone') ?? '';
      _parentAddress.text = prefs.getString('parentAddress') ?? '';
      _parentIC.text = prefs.getString('parentIC') ?? '';
      _studentIC.text = prefs.getString('studentIC') ?? '';
      selectedAge = prefs.getString('age');
      selectedGender = prefs.getString('gender');
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentName', _studentName.text);
    await prefs.setString('parentName', _parentName.text);
    await prefs.setString('parentPhone', _parentPhone.text);
    await prefs.setString('parentAddress', _parentAddress.text);
    await prefs.setString('parentIC', _parentIC.text);
    await prefs.setString('studentIC', _studentIC.text);
    if (selectedAge != null) await prefs.setString('age', selectedAge!);
    if (selectedGender != null) await prefs.setString('gender', selectedGender!);
  }

  bool _validateIC(String ic) {
    return ic.length == 12 && int.tryParse(ic) != null;
  }

  bool _validatePhone(String phone) {
    return RegExp(r'^01[0-9]{8,9}$').hasMatch(phone);
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      showThemePopup(context, "User not logged in.");
      setState(() => _isLoading = false);
      return;
    }

    final profileData = {
      'studentName': _studentName.text.trim(),
      'age': selectedAge,
      'gender': selectedGender,
      'parentName': _parentName.text.trim(),
      'parentPhone': _parentPhone.text.trim(),
      'parentAddress': _parentAddress.text.trim(),
      'parentIC': _parentIC.text.trim(),
      'studentIC': _studentIC.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('profiles').doc(uid).set(profileData);
      await _clearSavedData();

      int age = int.parse(selectedAge!);
      if (age == 4) {
        Navigator.pushReplacementNamed(context, '/module4');
      } else if (age == 5) {
        Navigator.pushReplacementNamed(context, '/module5');
      } else {
        Navigator.pushReplacementNamed(context, '/module6');
      }
    } catch (e) {
      showThemePopup(context, "Failed to save profile. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
              child: Form(
                key: _formKey,
                onChanged: _saveFormData,
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 150),
                    const SizedBox(height: 12),
                    const Text(
                      "Set Up Your Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Student Information"),
                    _buildInputField(
                      _studentName,
                      "Student Name",
                      Icons.person,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter student name';
                        if (value!.length > 50) return 'Name is too long';
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    _buildInputField(
                      _studentIC,
                      "Student's IC Number",
                      Icons.perm_identity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter IC number';
                        if (!_validateIC(value!)) return 'Invalid IC format';
                        return null;
                      },
                    ),
                    _buildDropdownField("Age", ageOptions, selectedAge, (value) {
                      setState(() => selectedAge = value);
                      _saveFormData();
                    }),
                    _buildDropdownField("Gender", genderOptions, selectedGender, (value) {
                      setState(() => selectedGender = value);
                      _saveFormData();
                    }),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Parent Information"),
                    _buildInputField(
                      _parentName,
                      "Parent's Name",
                      Icons.account_circle,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter parent name';
                        if (value!.length > 50) return 'Name is too long';
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    _buildInputField(
                      _parentPhone,
                      "Parent's Phone",
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter phone number';
                        if (!_validatePhone(value!)) return 'Invalid phone format';
                        return null;
                      },
                    ),
                    _buildInputField(
                      _parentIC,
                      "Parent's IC Number",
                      Icons.perm_identity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter IC number';
                        if (!_validateIC(value!)) return 'Invalid IC format';
                        return null;
                      },
                    ),
                    _buildInputField(
                      _parentAddress,
                      "Parent's Address",
                      Icons.home,
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter address';
                        if (value!.length > 200) return 'Address is too long';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      CustomButton.submit(onPressed: _submitProfile),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    _saveFormData();
                  },
                )
              : null,
        ),
        validator: validator,
        onChanged: (value) => _saveFormData(),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(
          icon: Icon(label == "Age" ? Icons.cake : Icons.transgender),
          hintText: label,
          border: InputBorder.none,
        ),
        validator: (value) => value == null ? 'Please select $label' : null,
        onChanged: onChanged,
        items: options.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      ),
    );
  }
}
