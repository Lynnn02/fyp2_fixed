import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

/// Helper class to manage screen time settings and checks
/// This can be used from anywhere in the app
class ScreenTimeManager {
  /// Check if the app should be locked based on current settings
  static Future<bool> shouldLockApp() async {
    return ScreenTimeLockScreen.shouldLockApp();
  }
  
  /// Track screen time usage (call this periodically)
  static Future<void> trackUsage() async {
    return ScreenTimeLockScreen.trackScreenTimeUsage();
  }
  
  /// Set up screen time settings
  static Future<void> setupScreenTime({
    required bool enabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required List<bool> allowedDays,
    required double maxHoursPerDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screenTimeEnabled', enabled);
    await prefs.setInt('startHour', startHour);
    await prefs.setInt('startMinute', startMinute);
    await prefs.setInt('endHour', endHour);
    await prefs.setInt('endMinute', endMinute);
    await prefs.setString('allowedDays', allowedDays.map((allowed) => allowed ? '1' : '0').join(','));
    await prefs.setDouble('maxHoursPerDay', maxHoursPerDay);
  }
  
  /// Get current screen time settings
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('screenTimeEnabled') ?? false;
    final startHour = prefs.getInt('startHour') ?? 8;
    final startMinute = prefs.getInt('startMinute') ?? 0;
    final endHour = prefs.getInt('endHour') ?? 20;
    final endMinute = prefs.getInt('endMinute') ?? 0;
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    
    return {
      'enabled': enabled,
      'startTime': TimeOfDay(hour: startHour, minute: startMinute),
      'endTime': TimeOfDay(hour: endHour, minute: endMinute),
      'allowedDays': allowedDays,
      'maxHoursPerDay': maxHoursPerDay,
      'usedMinutesToday': usedMinutesToday,
    };
  }
}

class ScreenTimeLockScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onUnlock;

  const ScreenTimeLockScreen({
    Key? key, 
    required this.userId,
    required this.onUnlock,
  }) : super(key: key);
  
  /// Static method to check if the app should be locked based on screen time settings
  /// Returns true if the app should be locked, false otherwise
  static Future<bool> shouldLockApp() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    // If screen time is not enabled, app should not be locked
    if (!screenTimeEnabled) {
      print('Screen time not enabled, not locking');
      return false;
    }
    
    // Check for override first
    final overrideUntilStr = prefs.getString('screenTimeOverrideUntil');
    if (overrideUntilStr != null && overrideUntilStr.isNotEmpty) {
      try {
        final overrideUntil = DateTime.parse(overrideUntilStr);
        final now = DateTime.now();
        
        if (now.isBefore(overrideUntil)) {
          // Override is still active, don't lock the app
          print('Screen time override active until ${DateFormat('HH:mm').format(overrideUntil)}');
          return false;
        } else {
          // Override has expired, clear it
          await prefs.remove('screenTimeOverrideUntil');
          print('Screen time override has expired');
        }
      } catch (e) {
        // Invalid override time format, clear it
        await prefs.remove('screenTimeOverrideUntil');
        print('Invalid screen time override format: $e');
      }
    }
    
    // Check if we're within allowed hours
    final startHour = prefs.getInt('startHour') ?? 8;
    final startMinute = prefs.getInt('startMinute') ?? 0;
    final endHour = prefs.getInt('endHour') ?? 20;
    final endMinute = prefs.getInt('endMinute') ?? 0;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Convert to minutes for easier comparison
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    
    print('Time check: current=$currentMinutes, allowed=$startMinutes-$endMinutes');
    
    // Check if current time is outside allowed hours
    if (currentMinutes < startMinutes || currentMinutes > endMinutes) {
      print('Outside allowed hours: current=$currentMinutes, allowed=$startMinutes-$endMinutes');
      return true; // Lock the app - outside allowed hours
    }
    
    // Check if today is an allowed day
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    if (allowedDays.length > dayOfWeek && !allowedDays[dayOfWeek]) {
      print('Not allowed on day ${dayOfWeek}');
      return true; // Lock the app - not an allowed day
    }
    
    // Check restricted time periods
    final restrictedPeriodsJson = prefs.getString('restrictedPeriods') ?? '[]';
    if (restrictedPeriodsJson.isNotEmpty && restrictedPeriodsJson != '[]') {
      try {
        final List<dynamic> restrictedPeriods = jsonDecode(restrictedPeriodsJson);
        for (final period in restrictedPeriods) {
          final startHour = period['startHour'] as int;
          final startMinute = period['startMinute'] as int;
          final endHour = period['endHour'] as int;
          final endMinute = period['endMinute'] as int;
          
          final restrictedStartMinutes = startHour * 60 + startMinute;
          final restrictedEndMinutes = endHour * 60 + endMinute;
          
          // Check if current time is within a restricted period
          if (currentMinutes >= restrictedStartMinutes && currentMinutes <= restrictedEndMinutes) {
            print('In restricted period: $restrictedStartMinutes-$restrictedEndMinutes');
            return true;
          }
        }
      } catch (e) {
        print('Error parsing restricted periods: $e');
      }
    }
    
    // Check if daily time limit is reached
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      print('Daily limit reached: used=$usedMinutesToday, max=$maxMinutesPerDay');
      return true; // Lock the app - daily limit reached
    }
    
    // Update the last active time for tracking usage
    final lastActiveDate = prefs.getString('lastActiveDate') ?? '';
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // If it's a new day, reset the used time
    if (lastActiveDate != today) {
      await prefs.setInt('screenTimeUsedToday', 0);
      await prefs.setString('lastActiveDate', today);
    }
    
    // If we get here, the app shouldn't be locked
    return false;
  }
  
  /// Static method to track screen time usage
  /// Should be called periodically while the app is in use
  static Future<void> trackScreenTimeUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    if (!screenTimeEnabled) return;
    
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final lastActiveDate = prefs.getString('lastActiveDate') ?? '';
    
    // If it's a new day, reset the used time
    if (lastActiveDate != today) {
      await prefs.setInt('screenTimeUsedToday', 0);
      await prefs.setString('lastActiveDate', today);
      return;
    }
    
    // Increment used time (1 minute)
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    await prefs.setInt('screenTimeUsedToday', usedMinutesToday + 1);
    await prefs.setString('lastActiveDate', today);
    
    print('Screen time used today: ${usedMinutesToday + 1} minutes');
  }

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
  Timer? _screenTimeTracker;
  Timer? _lockChecker;
  
  @override
  void initState() {
    super.initState();
    _determineLockReason();
    
    // Set up a timer to track screen time usage (every minute)
    _screenTimeTracker = Timer.periodic(const Duration(minutes: 1), (timer) {
      ScreenTimeLockScreen.trackScreenTimeUsage();
    });
    
    // Set up a timer to check if the app should be locked (every 30 seconds)
    _lockChecker = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final shouldLock = await ScreenTimeLockScreen.shouldLockApp();
      if (shouldLock) {
        // If the app should be locked but we're on the lock screen, update the reason
        _determineLockReason();
      }
    });
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    _screenTimeTracker?.cancel();
    _lockChecker?.cancel();
    super.dispose();
  }
  
  Future<void> _determineLockReason() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    // Check for override first
    final overrideUntilStr = prefs.getString('screenTimeOverrideUntil');
    if (overrideUntilStr != null && overrideUntilStr.isNotEmpty) {
      try {
        final overrideUntil = DateTime.parse(overrideUntilStr);
        final now = DateTime.now();
        
        if (now.isBefore(overrideUntil)) {
          // Override is still active, unlock the app
          print('Screen time override active until ${DateFormat('HH:mm').format(overrideUntil)}');
          widget.onUnlock();
          return;
        } else {
          // Override has expired, clear it
          await prefs.remove('screenTimeOverrideUntil');
          print('Screen time override has expired');
        }
      } catch (e) {
        // Invalid override time format, clear it
        await prefs.remove('screenTimeOverrideUntil');
        print('Invalid screen time override format: $e');
      }
    }
    
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
    
    // Check restricted time periods
    final restrictedPeriodsJson = prefs.getString('restrictedPeriods') ?? '[]';
    if (restrictedPeriodsJson.isNotEmpty && restrictedPeriodsJson != '[]') {
      try {
        final List<dynamic> restrictedPeriods = jsonDecode(restrictedPeriodsJson);
        for (final period in restrictedPeriods) {
          final startHour = period['startHour'] as int;
          final startMinute = period['startMinute'] as int;
          final endHour = period['endHour'] as int;
          final endMinute = period['endMinute'] as int;
          
          final restrictedStartMinutes = startHour * 60 + startMinute;
          final restrictedEndMinutes = endHour * 60 + endMinute;
          
          // Check if current time is within a restricted period
          if (currentMinutes >= restrictedStartMinutes && currentMinutes <= restrictedEndMinutes) {
            print('In restricted period: $restrictedStartMinutes-$restrictedEndMinutes');
            
            // Format the restricted period times for display
            final restrictedStartTime = TimeOfDay(hour: startHour, minute: startMinute);
            final restrictedEndTime = TimeOfDay(hour: endHour, minute: endMinute);
            
            setState(() {
              _lockReason = 'App is locked during restricted hours (${_formatTime(restrictedStartTime)} - ${_formatTime(restrictedEndTime)}).';
              _nextAvailableTime = DateTime(
                now.year,
                now.month,
                now.day,
                endHour,
                endMinute,
              );
            });
            return;
          }
        }
      } catch (e) {
        print('Error parsing restricted periods: $e');
      }
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
    
    // If we get here, the app should be unlocked
    widget.onUnlock();
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
                          'Please enter your parent IC Number to unlock',
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
                              hintText: 'Enter parent password',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your IC number ';
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
