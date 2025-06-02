import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_ui_style.dart';
import '../../widgets/admin_app_bar.dart';
import '../../widgets/admin_scaffold.dart';
import '../adminhome_screen.dart';
import 'user_profile_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedAge;  // Added a variable to store selected age
  bool _isLoading = false;

  // Updated to filter based on age
  Stream<QuerySnapshot<Map<String, dynamic>>> _getStudents() {
    final query = FirebaseFirestore.instance.collection('profiles');
    if (_selectedAge != null && _selectedAge!.isNotEmpty) {
      return query.where('age', isEqualTo: _selectedAge).snapshots();  // Filter by age
    } else {
      return _searchQuery.isEmpty
          ? query.snapshots()
          : query
              .where('studentName', isGreaterThanOrEqualTo: _searchQuery)
              .where('studentName', isLessThan: _searchQuery + 'z')
              .snapshots();
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    try {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance.collection('profiles').doc(studentId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleNavigation(int index) {
    if (index == 1) {
      // Already on user management screen
      return;
    }
    
    Navigator.pop(context);
    if (index == 0) {
      Navigator.pushNamed(context, '/adminHome');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/contentManagement');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/analytics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Student Management',
      selectedIndex: 1, // Users tab is selected
      onNavigate: _handleNavigation,
      body: Column(
        children: [
          Container(
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
            padding: const EdgeInsets.all(kSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Directory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: kSpacingSmall),
                Text(
                  'Manage and view all student profiles',
                  style: TextStyle(
                    color: secondaryColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: kSpacing),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: searchBar(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          hintText: 'Search students by name...',
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacing),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAge,
                            hint: Text("Age", style: TextStyle(color: secondaryColor)),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                            onChanged: (value) {
                              setState(() {
                                _selectedAge = value;
                              });
                            },
                            items: ['All Ages', '4', '5', '6']
                                .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem<String>(
                                          value: value == 'All Ages' ? null : value,
                                          child: Text(value),
                                        ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search,
                            size: 80, color: secondaryColor.withOpacity(0.3)),
                        const SizedBox(height: kSpacingSmall),
                        Text(
                          'No students found',
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(kSpacing),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: kSpacing),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                studentId: doc.id,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(kSpacing),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'avatar_${doc.id}',
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    child: Text(
                                      (data['studentName'] ?? '?')[0].toUpperCase(),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kSpacing),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['studentName'] ?? 'No name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Parent: ${data['parentName'] ?? 'No parent name'}',
                                        style: TextStyle(
                                          color: secondaryColor.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Age: ${data['age'] ?? 'N/A'}',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.visibility,
                                        color: primaryColor,
                                      ),
                                      tooltip: 'View Profile',
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(
                                            studentId: doc.id,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Delete Student',
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Student'),
                                          content: const Text(
                                            'Are you sure you want to delete this student? This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(color: secondaryColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteStudent(doc.id);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
