import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/screen_time_service.dart';
import '../children_module/screen_time_lock_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreenTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenTimeService.stopUsageTracking();
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

    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    _userId = currentUser?.uid;

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
    if (!widget.enforceScreenTime || _userId == null) {
      setState(() {
        _isLocked = false;
      });
      return;
    }

    // Check if screen time is enabled
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;

    if (!screenTimeEnabled) {
      setState(() {
        _isLocked = false;
      });
      return;
    }

    // Check if app should be locked
    final isLocked = await _screenTimeService.checkScreenTimeLimits();
    
    setState(() {
      _isLocked = isLocked;
    });
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLocked && widget.enforceScreenTime) {
      return ScreenTimeLockScreen(
        userId: _userId ?? '',
        onUnlock: _handleUnlock,
      );
    }

    return widget.child;
  }
}
