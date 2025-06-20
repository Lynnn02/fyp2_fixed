import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      print('Screen time not enforced or no user ID');
      setState(() {
        _isLocked = false;
      });
      return;
    }

    // Use the new shouldLockApp method from ScreenTimeLockScreen
    final isLocked = await ScreenTimeLockScreen.shouldLockApp();
    
    // Also track screen time usage
    await ScreenTimeLockScreen.trackScreenTimeUsage();
    
    print('Screen time check: should lock = $isLocked');
    
    // Force update the lock state regardless of previous state
    print('Setting lock state to: $isLocked (was: $_isLocked)');
    setState(() {
      _isLocked = isLocked;
    });
    
    // Add a delay and check again to ensure the lock is applied
    if (isLocked) {
      Future.delayed(const Duration(seconds: 1), () {
        print('Re-confirming lock state after delay');
        setState(() {
          _isLocked = true;
        });
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

    if (_isLocked && widget.enforceScreenTime) {
      print('Screen time lock active, showing lock screen');
      
      // Create a new MaterialApp with proper localizations for the lock screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        // Use a fresh theme instead of inheriting to avoid TextStyle inheritance issues
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Ensure text styles have consistent inheritance
          textTheme: const TextTheme().apply(bodyColor: Colors.black87, displayColor: Colors.black87),
        ),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        home: ScreenTimeLockScreen(
          userId: _userId ?? '',
          onUnlock: _handleUnlock,
        ),
      );
    }

    return widget.child;
  }
}
