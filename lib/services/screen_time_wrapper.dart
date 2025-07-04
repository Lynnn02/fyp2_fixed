import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    
    // Add periodic timer to check screen time limits more frequently
    _screenTimeCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      print('Periodic screen time check triggered');
      _checkScreenTimeLimits();
    });
    
    // Run an immediate check when the app starts
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
      
      // Use an overlay to ensure the lock screen is shown on top of everything else
      return Stack(
        children: [
          // The original app remains underneath
          Opacity(
            opacity: 0.3, // Dim the main app
            child: IgnorePointer(
              ignoring: true, // Prevent interaction with the main app
              child: widget.child,
            ),
          ),
          // The lock screen covers everything
          // Use a Directionality widget instead of MaterialApp to avoid conflicts
          Directionality(
            textDirection: TextDirection.ltr,
            child: ScreenTimeLockScreen(
              userId: _userId ?? '',
              onUnlock: _handleUnlock,
            ),
          ),
        ],
      );
    }

    return widget.child;
  }
}
