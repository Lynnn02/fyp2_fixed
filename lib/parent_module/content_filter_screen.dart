import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/content_filter_service.dart';

class ContentFilterScreen extends StatefulWidget {
  final String childId;

  const ContentFilterScreen({Key? key, required this.childId}) : super(key: key);

  @override
  State<ContentFilterScreen> createState() => _ContentFilterScreenState();
}

class _ContentFilterScreenState extends State<ContentFilterScreen> {
  bool _isLoading = true;
  List<SubjectFilter> _subjects = [];
  Map<String, bool> _accessSettings = {};
  String _errorMessage = '';
  int _childAgeGroup = 4; // Default to age group 4
  
  @override
  void initState() {
    super.initState();
    _loadSubjectsAndSettings();
  }
  
  Future<void> _loadSubjectsAndSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the current user's ID or use the provided childId
      final currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? widget.childId;
      
      // First, determine the child's age group from their profile
      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .get();
      
      if (profileDoc.exists) {
        final data = profileDoc.data()!;
        final age = data['age'];
        if (age != null) {
          // Convert age to age group (4, 5, or 6)
          int ageInt = int.tryParse(age.toString()) ?? 4;
          if (ageInt <= 4) {
            _childAgeGroup = 4;
          } else if (ageInt == 5) {
            _childAgeGroup = 5;
          } else {
            _childAgeGroup = 6;
          }
        }
      }
      
      // Load all available subjects from Firestore
      final subjectsSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();
      
      final List<SubjectFilter> subjects = [];
      final Set<String> addedSubjectNames = {}; // Track subject names in lowercase to avoid duplicates
      
      for (var doc in subjectsSnapshot.docs) {
        final data = doc.data();
        final subjectModuleId = data['moduleId'] ?? 4;
        final subjectName = data['name'] ?? 'Unknown Subject';
        
        // Check for duplicates using case-insensitive comparison
        final lowerCaseName = subjectName.toLowerCase();
        
        // Only add subjects that exactly match the child's age group and aren't duplicates
        if (_childAgeGroup == subjectModuleId && !addedSubjectNames.contains(lowerCaseName)) {
          subjects.add(SubjectFilter(
            id: doc.id,
            name: subjectName,
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            ageGroup: subjectModuleId,
          ));
          
          // Add to the set of processed subject names
          addedSubjectNames.add(lowerCaseName);
        }
      }
      
      // Load user's content filter settings
      final settingsDoc = await FirebaseFirestore.instance
          .collection('contentFilters')
          .doc(userId)
          .get();
      
      Map<String, bool> accessSettings = {};
      
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        final Map<String, dynamic>? subjectAccess = data['subjectAccess'] as Map<String, dynamic>?;
        
        if (subjectAccess != null) {
          // Convert from Map<String, dynamic> to Map<String, bool>
          accessSettings = subjectAccess.map((key, value) => MapEntry(key, value as bool));
        }
      }
      
      // For any subject that doesn't have a setting yet, default to allowed (true)
      for (var subject in subjects) {
        if (!accessSettings.containsKey(subject.id)) {
          accessSettings[subject.id] = true;
        }
      }
      
      setState(() {
        _subjects = subjects;
        _accessSettings = accessSettings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading subjects: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the current user's ID or use the provided childId
      final currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? widget.childId;
      
      // Save settings to Firestore
      await FirebaseFirestore.instance
          .collection('contentFilters')
          .doc(userId)
          .set({
        'subjectAccess': _accessSettings,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Update ContentFilterService cache directly and also save to SharedPreferences
      final ContentFilterService filterService = ContentFilterService();
      filterService.clearCache(); // Force a refresh of the cache
      
      // Also update SharedPreferences directly to ensure immediate sync
      await _updateSharedPreferences(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content filter settings saved')),
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving settings: $e';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }
  
  void _toggleSubjectAccess(String subjectId, bool newValue) {
    setState(() {
      _accessSettings[subjectId] = newValue;
    });
  }
  
  /// Update SharedPreferences with the latest filter settings
  /// This ensures settings are immediately available offline
  Future<void> _updateSharedPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update each subject filter setting in SharedPreferences
      for (var entry in _accessSettings.entries) {
        final subjectId = entry.key;
        final isAllowed = entry.value;
        await prefs.setBool('contentFilter_$subjectId', isAllowed);
        
        // Find the corresponding subject to store by name as well
        final subject = _subjects.firstWhere(
          (subj) => subj.id == subjectId,
          orElse: () => SubjectFilter(
            id: subjectId, 
            name: '', 
            description: '',
            imageUrl: '',
            ageGroup: 0,
          ),
        );
        
        if (subject.name.isNotEmpty) {
          // Store by name as well for redundant checking
          await prefs.setBool('contentFilter_name_${subject.name}', isAllowed);
          print('Saved filter for "${subject.name}" (ID: $subjectId) = $isAllowed');
        }
      }
      
      // Save a timestamp for when filters were last updated
      await prefs.setString('contentFilter_lastUpdated', DateTime.now().toIso8601String());
      
      print('Content filter settings updated in SharedPreferences: ${_accessSettings.length} entries');
    } catch (e) {
      print('Error updating SharedPreferences: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        title: const Text('Content Filters', 
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSubjectsAndSettings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _buildContentFilterList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
      ),
    );
  }
  
  Widget _buildContentFilterList() {
    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No subjects found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Subjects will appear here once they are added by an admin',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Content Filter Controls',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use these controls to manage which subjects your child can access. '
                  'Turning off a subject will hide it from notes, video learning, and games.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing subjects for Age Group: $_childAgeGroup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subject List
          _buildSectionCard(
            title: 'Subject Access',
            child: Column(
              children: _subjects.map((subject) {
                final isEnabled = _accessSettings[subject.id] ?? true;
                
                return Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subject.description.isEmpty
                            ? 'Age Group: ${subject.ageGroup}'
                            : subject.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      secondary: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: subject.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  subject.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.book,
                                      color: Colors.blue.shade700,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.book,
                                color: Colors.blue.shade700,
                              ),
                      ),
                      value: isEnabled,
                      activeColor: Colors.blue.shade700,
                      onChanged: (value) {
                        _toggleSubjectAccess(subject.id, value);
                      },
                    ),
                    if (_subjects.last.id != subject.id)
                      const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 80), // Extra space for the FAB
        ],
      ),
    );
  }
  
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SubjectFilter {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int ageGroup;
  
  SubjectFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ageGroup,
  });
}
