import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Add timer import
import '../services/screen_time_service.dart';
import '../parent_module/screen_time_lock_screen.dart';

class ScreenTimeWrapper extends StatefulWidget {
  final Widget child;
  final bool enforceScreenTime;
  
  const ScreenTimeWrapper({
    Key? key,
    required this.child,
    this.enforceScreenTime = true,
  }) : super(key: key);

  @override
  State<ScreenTimeWrapper> createState() => _ScreenTimeWrapperState();
}

class _ScreenTimeWrapperState extends State<ScreenTimeWrapper> with WidgetsBindingObserver {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  bool _isLocked = false;
  bool _isInitialized = false;
  String? _userId;
  Timer? _screenTimeCheckTimer; // Timer for periodic checks

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreenTime();
    _getCurrentUserId();
    _checkScreenTimeLimits();
    _screenTimeCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      print('Periodic screen time check triggered');
      _checkScreenTimeLimits();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      print('Initial screen time check');
      _checkScreenTimeLimits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenTimeService.stopUsageTracking();
    // Cancel the timer when disposing
    _screenTimeCheckTimer?.cancel();
    super.dispose();
  }
  
  // Get the current user ID from Firebase or SharedPreferences
  Future<void> _getCurrentUserId() async {
    // Try to get user ID from Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      print('Got user ID from Firebase Auth: $_userId');
      
      // Save to SharedPreferences for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', _userId!);
      print('Saved current user ID to SharedPreferences: $_userId');
      return;
    }
    
    // If Firebase Auth fails, try SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('currentUserId');
    print('Got user ID from SharedPreferences: $_userId');
    
    // As a last resort, use a fixed ID to ensure lock still works
    if (_userId == null) {
      // Set a fixed user ID to ensure screen time works
      _userId = 'default_screen_time_user';
      await prefs.setString('currentUserId', _userId!);
      print('Set default user ID for screen time: $_userId');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, check screen time limits
      _checkScreenTimeLimits();
    } else if (state == AppLifecycleState.paused) {
      // App went to background, update usage time
      _screenTimeService.stopUsageTracking();
    }
  }

  Future<void> _initializeScreenTime() async {
    if (!widget.enforceScreenTime) {
      setState(() {
        _isInitialized = true;
        _isLocked = false;
      });
      return;
    }

    // Get current user ID - first try from FirebaseAuth, then try from SharedPreferences
    final currentUser = FirebaseAuth.instance.currentUser;
    _userId = currentUser?.uid;
    
    // If no user ID from Firebase Auth, check SharedPreferences
    if (_userId == null) {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('currentUserId');
      print('Getting userId from SharedPreferences: $_userId');
    }

    if (_userId == null) {
      // No user logged in, don't enforce screen time
      setState(() {
        _isInitialized = true;
        _isLocked = false;
      });
      return;
    }

    // Initialize the screen time service
    await _screenTimeService.initialize();
    await _checkScreenTimeLimits();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _checkScreenTimeLimits() async {
    // Even if _userId is null, try to get it from SharedPreferences again
    if (_userId == null) {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('currentUserId');
      print('Re-checking userId from SharedPreferences: $_userId');
    }
    
    if (!widget.enforceScreenTime || _userId == null) {
      print('Screen time not enforced or no user ID. enforceScreenTime=${widget.enforceScreenTime}, userId=$_userId');
      setState(() {
        _isLocked = false;
      });
      return;
    }
    
    // Now we have a valid user ID and screen time is enforced
    print('Screen time check for user: $_userId');

    // Debug check current settings
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('screenTimeEnabled');
    final maxHours = prefs.getDouble('maxHoursPerDay');
    final usedToday = prefs.getInt('screenTimeUsedToday');
    print('SCREEN TIME DEBUG: enabled=$enabled, maxHours=$maxHours, usedToday=$usedToday');
    
    // Use the new shouldLockApp method from ScreenTimeLockScreen
    final isLocked = await ScreenTimeLockScreen.shouldLockApp();
    
    // Always track screen time usage
    await ScreenTimeLockScreen.trackScreenTimeUsage();
    
    print('Screen time check: should lock = $isLocked');
    
    // If lock status changed, force rebuild UI immediately
    if (isLocked != _isLocked) {
      print('LOCK STATE CHANGED from $_isLocked to $isLocked - updating UI');
      // Use microtask to ensure UI updates immediately
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _isLocked = isLocked;
          });
        }
      });
    } else {
      // Update state even if it didn't change for consistency
      setState(() {
        _isLocked = isLocked;
      });
    }
    
    // Add a delay and double-check to ensure the lock is applied
    if (isLocked) {
      Future.delayed(const Duration(seconds: 1), () {
        print('Re-confirming lock state after delay');
        if (mounted) {
          setState(() {
            _isLocked = true;
          });
        }
      });
    }
  }

  void _handleUnlock() {
    setState(() {
      _isLocked = false;
    });
    _screenTimeService.initialize(); // Restart tracking
  }
  
  /// Permanently disable screen time restrictions until new settings are applied
  /// This allows the parent to unlock the app completely until they set new restrictions
  Future<void> _disableScreenTimeRestrictions() async {
    print('Disabling screen time restrictions');
    final prefs = await SharedPreferences.getInstance();
    
    // Set a permanent override by setting to false
    await prefs.setBool('screenTimeEnabled', false);
    
    // Clear any temporary overrides
    await prefs.remove('screenTimeOverrideUntil');
    
    print('Screen time restrictions disabled until new settings are applied');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Debug info
    print('SCREEN TIME BUILD: isLocked=$_isLocked, enforceScreenTime=${widget.enforceScreenTime}');

    if (_isLocked && widget.enforceScreenTime) {
      print('Screen time lock active, showing lock screen');
      
      // Create a proper lock screen with the correct context
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(
          child: _ParentAuthScreen(
            userId: _userId ?? '',
            onUnlock: () {
              // When unlocked, disable screen time until new settings are applied
              _disableScreenTimeRestrictions();
              _handleUnlock();
            },
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Parent authentication screen that matches the design of the parent mode
class _ParentAuthScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onUnlock;

  const _ParentAuthScreen({
    Key? key,
    required this.userId,
    required this.onUnlock,
  }) : super(key: key);

  @override
  State<_ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<_ParentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  String _errorMessage = '';
  String _lockReason = 'Screen time restrictions';

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
    
    // Check for time-based restrictions first
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentMinutes = currentHour * 60 + currentMinute;
    
    final startHour = prefs.getInt('startHour') ?? 8;
    final startMinute = prefs.getInt('startMinute') ?? 0;
    final endHour = prefs.getInt('endHour') ?? 20;
    final endMinute = prefs.getInt('endMinute') ?? 0;
    
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    
    // If current time is outside allowed hours
    if (currentMinutes < startMinutes || currentMinutes > endMinutes) {
      setState(() {
        _lockReason = 'Outside allowed hours (${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')})';
      });
      return;
    }
    
    // Check if daily limit is reached
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      setState(() {
        _lockReason = 'Daily screen time limit reached (${maxHoursPerDay.toStringAsFixed(1)} hours)';
      });
      return;
    }
  }

  Future<void> _verifyParentPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });
    
    try {
      // First check if we can get the parent user
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currentUser = auth.currentUser;
      final String profileId = currentUser?.uid ?? widget.userId;
      
      // Get parent password from Firestore
      final parentProfileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .get();
      
      if (parentProfileDoc.exists) {
        // For demo purposes, accept a hardcoded password or the one from the database
        if (_passwordController.text == '123456') {
          widget.onUnlock();
          return;
        }
        
        // Check stored passwords/credentials from Firestore
        final List<dynamic> validCredentials = parentProfileDoc.data()?['parentPassword'] ?? [];
        
        if (validCredentials.contains(_passwordController.text)) {
          widget.onUnlock();
        } else {
          setState(() {
            _errorMessage = 'Incorrect password';
            _isVerifying = false;
          });
        }
      } else {
        // If no profile found, accept default password for testing
        if (_passwordController.text == '123456') {
          widget.onUnlock();
          return;
        }
        
        setState(() {
          _errorMessage = 'User profile not found';
          _isVerifying = false;
        });
      }
    } catch (e) {
      // For testing, accept default password
      if (_passwordController.text == '123456') {
        widget.onUnlock();
        return;
      }
      
      setState(() {
        _errorMessage = 'Error verifying password: $e';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Stack(
        children: [
          // Original app dimmed in background
          Opacity(
            opacity: 0.1,
            child: Container(
              color: Colors.black,
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Screen Time Lock',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lock reason: $_lockReason',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Please enter parent password to unlock',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                hintText: 'Enter parent password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _verifyParentPassword(),
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
                                  : const Text('Unlock App'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlocking will disable screen time restrictions\nuntil new settings are applied.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
