import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScreenTimeLockScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onUnlock;

  const ScreenTimeLockScreen({
    Key? key, 
    required this.userId,
    required this.onUnlock,
  }) : super(key: key);

  @override
  State<ScreenTimeLockScreen> createState() => _ScreenTimeLockScreenState();
}

class _ScreenTimeLockScreenState extends State<ScreenTimeLockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  String _errorMessage = '';
  String _lockReason = '';
  DateTime? _nextAvailableTime;
  
  @override
  void initState() {
    super.initState();
    _determineLockReason();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _determineLockReason() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    if (!screenTimeEnabled) {
      setState(() {
        _lockReason = 'App is currently locked by parent.';
      });
      return;
    }
    
    // Check if we're within allowed hours
    final startHour = prefs.getInt('startHour') ?? 8;
    final startMinute = prefs.getInt('startMinute') ?? 0;
    final endHour = prefs.getInt('endHour') ?? 20;
    final endMinute = prefs.getInt('endMinute') ?? 0;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startTime = TimeOfDay(hour: startHour, minute: startMinute);
    final endTime = TimeOfDay(hour: endHour, minute: endMinute);
    
    // Convert to minutes for easier comparison
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    // Check if current time is outside allowed hours
    if (currentMinutes < startMinutes) {
      // Too early
      final nextAvailable = DateTime(
        now.year, 
        now.month, 
        now.day, 
        startTime.hour, 
        startTime.minute,
      );
      
      setState(() {
        _lockReason = 'App is locked until ${_formatTime(startTime)}.';
        _nextAvailableTime = nextAvailable;
      });
      return;
    } else if (currentMinutes > endMinutes) {
      // Too late
      final nextAvailable = DateTime(
        now.year, 
        now.month, 
        now.day + 1, // Next day
        startTime.hour, 
        startTime.minute,
      );
      
      setState(() {
        _lockReason = 'App is locked for today. Available again tomorrow at ${_formatTime(startTime)}.';
        _nextAvailableTime = nextAvailable;
      });
      return;
    }
    
    // Check if today is an allowed day
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    if (!allowedDays[dayOfWeek]) {
      setState(() {
        _lockReason = 'App is not available on ${_getDayName(dayOfWeek)}.';
      });
      return;
    }
    
    // Check if daily time limit is reached
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      setState(() {
        _lockReason = 'Daily screen time limit (${maxHoursPerDay.toStringAsFixed(1)} hours) reached.';
      });
      return;
    }
    
    // If we get here, the app shouldn't be locked
    setState(() {
      _lockReason = 'App is locked by parent.';
    });
  }
  
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();  // 5:08 PM
    return format.format(dt);
  }
  
  String _getDayName(int dayOfWeek) {
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayNames[dayOfWeek];
  }
  
  Future<void> _verifyParentPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      // Get the current user's ID
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
          _unlockApp();
          return;
        }
        
        setState(() {
          _errorMessage = 'User profile not found';
          _isVerifying = false;
        });
        return;
      }

      final data = userDoc.data()!;
      
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
        _showUnlockOptions();
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
  
  void _showUnlockOptions() {
    setState(() => _isVerifying = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Options'),
        content: const Text('How long would you like to unlock the app for?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unlockApp(minutes: 15);
            },
            child: const Text('15 minutes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unlockApp(minutes: 60);
            },
            child: const Text('1 hour'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unlockApp(untilEndOfDay: true);
            },
            child: const Text('Rest of the day'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _unlockApp({int minutes = 0, bool untilEndOfDay = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (untilEndOfDay) {
      // Set an override until the end of the day
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      await prefs.setString('screenTimeOverrideUntil', endOfDay.toIso8601String());
    } else if (minutes > 0) {
      // Set a timed override
      final now = DateTime.now();
      final overrideUntil = now.add(Duration(minutes: minutes));
      await prefs.setString('screenTimeOverrideUntil', overrideUntil.toIso8601String());
    }
    
    // Call the onUnlock callback
    widget.onUnlock();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Lock Title
                  const Text(
                    'App Locked',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lock Reason
                  Text(
                    _lockReason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  // Next Available Time
                  if (_nextAvailableTime != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Available again: ${DateFormat('EEEE, MMM d, h:mm a').format(_nextAvailableTime!)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Parent Unlock Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Parent Unlock',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enter your parent IC number to unlock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              hintText: 'Enter parent IC number',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your IC number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyParentPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                : const Text('Unlock'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
