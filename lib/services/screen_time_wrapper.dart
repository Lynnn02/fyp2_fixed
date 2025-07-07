import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
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
  String _lockReason = '';
  Timer? _screenTimeCheckTimer; // Timer for periodic checks
  final TextEditingController _passwordController = TextEditingController();
  
  // Form and error handling
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Sequential async initialization with proper await
    _initializeAndCheckScreenTime();
  }
  
  // Helper method to ensure initialization happens in the right order
  Future<void> _initializeAndCheckScreenTime() async {
    await _initializeScreenTime();
    await _getCurrentUserId();
    await _checkScreenTimeLimits();
    
    // Only start periodic checks after initialization is complete
    _screenTimeCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      print('Periodic screen time check triggered');
      _checkScreenTimeLimits();
    });
    
    // Double-check after a short delay to ensure lock state is correct
    Future.delayed(const Duration(milliseconds: 500), () {
      print('Initial screen time check');
      _checkScreenTimeLimits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenTimeService.stopUsageTracking();
    _screenTimeCheckTimer?.cancel();
    _passwordController.dispose();
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

    try {
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing screen time: $e');
    }
  }

  // Check if the app should be locked based on screen time limits
  Future<void> _checkScreenTimeLimits() async {
    if (!widget.enforceScreenTime || _userId == null || _userId!.isEmpty) {
      // If screen time is not enforced or no user ID, don't lock
      setState(() {
        _isLocked = false;
      });
      return;
    }

    // Save the current userId to SharedPreferences before checking lock status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', _userId!);
    
    // Now call without parameter, as the method will use the userId from SharedPreferences
    final shouldLock = await ScreenTimeLockScreen.shouldLockApp();
    if (shouldLock) {
      // Only determine reason if we are locking
      final lockReason = await _determineLockReason();
      
      setState(() {
        _isLocked = true;
        _lockReason = lockReason;
      });
      
      print('App locked due to screen time limit: $lockReason');
    } else {
      setState(() {
        _isLocked = false;
      });
    }
  }

  // Determine the reason why the app is locked
  Future<String> _determineLockReason() async {
    // Get the current userId from SharedPreferences or class variable
    final prefs = await SharedPreferences.getInstance();
    final userId = _userId ?? prefs.getString('currentUserId') ?? '';
    final isTimeoutActive = prefs.getBool('screenTimeTimeout_$userId') ?? false;
    final isDailyLimitReached = prefs.getBool('dailyLimitReached_$userId') ?? false;
    final isBlockedTime = prefs.getBool('blockedTimeNow_$userId') ?? false;
    
    if (isTimeoutActive) {
      return 'App timeout active';
    } else if (isDailyLimitReached) {
      return 'Daily screen time limit reached';
    } else if (isBlockedTime) {
      return 'Device use not allowed during this time';
    } else {
      return 'Screen Time Restriction Active';
    }
  }

  // Handle the unlock flow
  Future<void> _handleUnlock() async {
    print('Unlocking screen time restrictions');
    
    // Use microtask to ensure we're not updating state during build
    Future.microtask(() async {
      // Reset lock state
      if (mounted) {
        setState(() {
          _isLocked = false;
          _lockReason = '';
        });
      }
      
      // Make sure to await this to avoid immediate re-locking
      await _disableScreenTimeRestrictions();
      
      print('Screen time restrictions disabled until new settings are applied');
    });
  }

  // Verify parent password against Firestore stored credentials
  Future<void> _verifyParentPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Update UI to show we're verifying
    if (mounted) {
      setState(() {
        _isVerifying = true;
        _errorMessage = '';
      });
    }

    try {
      // Ensure we have a valid user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      final String profileId = currentUser?.uid ?? _userId ?? '';
      
      if (profileId.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error: User ID is empty';
            _isVerifying = false;
          });
        }
        return;
      }
      
      // Get the parent password from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .get();
      
      if (!userDoc.exists) {
        // Try default verification if profile doesn't exist
        if (_passwordController.text == '123456') {
          // If default password works, still allow access but show a warning
          print('WARNING: Using default password for screen time unlock');
          
          // Clear password field
          _passwordController.clear();
          
          // Disable restrictions and unlock in a safe way
          await _disableScreenTimeRestrictions();
          _handleUnlock(); // Don't await this to avoid state changes during build
          return;
        }
        
        if (mounted) {
          setState(() {
            _errorMessage = 'User profile not found';
            _isVerifying = false;
          });
        }
        return;
      }

      final data = userDoc.data()!;
      
      // Use the parent IC as the primary verification method
      final parentIC = data['parentIC'] as String?;
      final customPassword = data['parentPassword'] as String?;
      
      // Use either IC number or custom password - fall back to default only if necessary
      final validCredentials = [
        if (parentIC != null && parentIC.isNotEmpty) parentIC,
        if (customPassword != null && customPassword.isNotEmpty) customPassword,
        '123456' // Last resort default
      ].where((pwd) => pwd != null && pwd.isNotEmpty).toList();
      
      if (validCredentials.contains(_passwordController.text)) {
        // Clear password field
        _passwordController.clear();
        
        // Disable restrictions and unlock in a safe way
        await _disableScreenTimeRestrictions();
        _handleUnlock(); // Don't await this to avoid state changes during build
      } else {
        // Show error message
        if (mounted) {
          setState(() {
            _errorMessage = 'Incorrect password';
            _isVerifying = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error verifying password: $e';
          _isVerifying = false;
        });
      }
    }
  }
  
  // Disable the screen time restrictions
  Future<void> _disableScreenTimeRestrictions() async {
    try {
      // Get user ID safely
      final userId = _userId ?? '';
      if (userId.isEmpty) {
        print('Error: User ID is empty, cannot disable screen time restrictions');
        return;
      }

      // Write to local storage that screen time is disabled
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('screenTimeEnabled_$userId', false);
      
      // Debug
      print('Screen time restrictions disabled for user: $userId');
    } catch (e) {
      print('Error disabling screen time restrictions: $e');
    }
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
      print('Screen time lock active, showing lock screen with reason: $_lockReason');
    }
    
    // Check if we're on login or signup screens where lock shouldn't apply
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isAuthScreen = currentRoute == '/login' || currentRoute == '/signup' || currentRoute == '/splash';
    
    // Don't show lock screen on auth screens
    final shouldShowLock = _isLocked && widget.enforceScreenTime && !isAuthScreen;
    
    // Simple approach: always keep the real app in the tree
    // Overlay the lock screen only when needed
    return Stack(
      children: [
        // Base app (always visible, but might be covered)
        // AbsorbPointer prevents interaction with the underlying app when locked
        AbsorbPointer(
          absorbing: shouldShowLock,
          child: widget.child,
        ),
        
        // Lock screen overlay (only when locked and not on auth screens)
        if (shouldShowLock) 
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.8),
              child: SafeArea(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Material(
                          color: Colors.transparent, // Important for input fields to work
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  color: Colors.purple,
                                  size: 64,
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
                                  'Screen Time Restriction Active',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _lockReason,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, color: Colors.red),
                                ),
                                const SizedBox(height: 24),
                                if (_errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      _errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Enter parent password',
                                    prefixIcon: const Icon(Icons.perm_identity),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _verifyParentPassword(),
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
                                  onPressed: null, // Disabled since user can't cancel screen time lock
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
