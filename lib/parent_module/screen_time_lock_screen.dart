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
    // Get current settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Check if screen time is enabled
    final enabled = prefs.getBool('screenTimeEnabled') ?? false;
    print('Screen time enabled: $enabled');
    
    if (!enabled) {
      print('Screen time not enabled');
      return false;
    }
    
    // Store current user ID in SharedPreferences for redundancy
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await prefs.setString('currentUserId', currentUser.uid);
      print('Stored current user ID in SharedPreferences: ${currentUser.uid}');
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
    
    // Check if within allowed hours
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
    
    print('Current time: ${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')} ($currentMinutes min)');
    print('Allowed hours: $startHour:${startMinute.toString().padLeft(2, '0')}-$endHour:${endMinute.toString().padLeft(2, '0')} ($startMinutes-$endMinutes min)');
    
    if (currentMinutes < startMinutes || currentMinutes > endMinutes) {
      print('LOCK REASON: Outside allowed hours');
      return true; // Lock the app - outside allowed hours
    }
    
    // Check if today is an allowed day
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    print('Day of week: $dayOfWeek');
    print('Allowed days: $allowedDaysString');
    
    if (allowedDays.length > dayOfWeek && !allowedDays[dayOfWeek]) {
      print('LOCK REASON: Not allowed on this day');
      return true; // Lock the app - not an allowed day
    }
    
    // Check restricted time periods
    final restrictedPeriodsJson = prefs.getString('restrictedPeriods') ?? '[]';
    print('Restricted periods: $restrictedPeriodsJson');
    
    if (restrictedPeriodsJson.isNotEmpty && restrictedPeriodsJson != '[]') {
      try {
        final List<dynamic> restrictedPeriods = jsonDecode(restrictedPeriodsJson);
        print('Number of restricted periods: ${restrictedPeriods.length}');
        
        // Dump raw period data for debugging
        print('Raw periods data: $restrictedPeriods');
        
        for (final period in restrictedPeriods) {
          // Handle different possible formats
          int periodStartHour;
          int periodStartMinute;
          int periodEndHour;
          int periodEndMinute;
          
          // First try direct parsing as integers
          try {
            periodStartHour = period['startHour'] is int ? period['startHour'] : int.parse(period['startHour'].toString());
            periodStartMinute = period['startMinute'] is int ? period['startMinute'] : int.parse(period['startMinute'].toString());
            periodEndHour = period['endHour'] is int ? period['endHour'] : int.parse(period['endHour'].toString());
            periodEndMinute = period['endMinute'] is int ? period['endMinute'] : int.parse(period['endMinute'].toString());
          } catch (e) {
            // Alternate format might be a TimeOfDay serialized as a string like "06:00"
            try {
              if (period['startTime'] != null && period['endTime'] != null) {
                final startParts = period['startTime'].toString().split(':');
                final endParts = period['endTime'].toString().split(':');
                
                periodStartHour = int.parse(startParts[0]);
                periodStartMinute = int.parse(startParts[1]);
                periodEndHour = int.parse(endParts[0]);
                periodEndMinute = int.parse(endParts[1]);
              } else {
                print('Invalid period format: $period');
                continue; // Skip this period
              }
            } catch (e2) {
              print('Could not parse period in any format: $e2');
              continue; // Skip this period
            }
          }
          
          final restrictedStartMinutes = periodStartHour * 60 + periodStartMinute;
          final restrictedEndMinutes = periodEndHour * 60 + periodEndMinute;
          
          print('Checking restricted period: $periodStartHour:${periodStartMinute.toString().padLeft(2, '0')}-$periodEndHour:${periodEndMinute.toString().padLeft(2, '0')}');
          print('Current minutes: $currentMinutes, Restricted: $restrictedStartMinutes - $restrictedEndMinutes');
          
          // Check if current time falls within the restricted period
          if (currentMinutes >= restrictedStartMinutes && currentMinutes <= restrictedEndMinutes) {
            print('LOCK REASON: In restricted period $periodStartHour:${periodStartMinute.toString().padLeft(2, '0')} - $periodEndHour:${periodEndMinute.toString().padLeft(2, '0')}');
            return true; // Lock the app - in restricted period
          }
        }
      } catch (e) {
        print('Error parsing restricted periods: $e');
      }
    }
    
    // Check if daily limit is reached
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    print('Used time today: $usedMinutesToday / $maxMinutesPerDay minutes');
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      print('LOCK REASON: Daily time limit reached');
      return true; // Lock the app - daily limit reached
    }
    
    // All checks passed, app should not be locked
    print('All checks passed, app should not be locked');
    print('=================================');
    return false;
  }
  
  /// Static method to track screen time usage
  /// Should be called periodically while the app is in use
  static Future<void> trackScreenTimeUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    if (!screenTimeEnabled) return; // Don't track if screen time is disabled
    
    // Get the last active date
    final lastActiveDateStr = prefs.getString('screenTimeLastActiveDate');
    final today = DateTime.now().toIso8601String().split('T')[0]; // Just get YYYY-MM-DD part
    
    if (lastActiveDateStr != today) {
      // New day, reset the counter
      await prefs.setInt('screenTimeUsedToday', 0);
      await prefs.setString('screenTimeLastActiveDate', today);
      print('New day detected, reset screen time counter');
    } else {
      // Same day, increment the counter (1 minute)
      final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
      await prefs.setInt('screenTimeUsedToday', usedMinutesToday + 1);
      
      // Log every 5 minutes
      if (usedMinutesToday % 5 == 0) {
        print('Screen time used today: $usedMinutesToday minutes');
      }
    }
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
  String _lockDetails = '';
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
    
    print('\n===== SCREEN TIME LOCK DEBUG INFO =====');
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    print('Screen time enabled: $screenTimeEnabled');
    
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
        _lockDetails = 'Please ask a parent to unlock the app.';
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
    
    // Add debug information for time checks
    print('Current time: ${_formatTime(currentTime)} ($currentMinutes minutes)');
    print('Allowed hours: ${_formatTime(startTime)} - ${_formatTime(endTime)} ($startMinutes-$endMinutes minutes)');
    
    // Check if current time is outside allowed hours
    if (currentMinutes < startMinutes) {
      // Too early
      print('LOCK REASON: Too early - outside allowed hours');
      final nextAvailable = DateTime(
        now.year, 
        now.month, 
        now.day, 
        startTime.hour, 
        startTime.minute,
      );
      
      setState(() {
        _lockReason = 'App is locked until ${_formatTime(startTime)}.';
        _lockDetails = 'The app will be available at ${_formatTime(startTime)}.';
        _nextAvailableTime = nextAvailable;
      });
      return;
    } else if (currentMinutes > endMinutes) {
      // Too late
      print('LOCK REASON: Too late - outside allowed hours');
      final nextAvailable = DateTime(
        now.year, 
        now.month, 
        now.day + 1, // Next day
        startTime.hour, 
        startTime.minute,
      );
      
      setState(() {
        _lockReason = 'App is locked for today.';
        _lockDetails = 'Available again tomorrow at ${_formatTime(startTime)}.';
        _nextAvailableTime = nextAvailable;
      });
      return;
    }
    
    // Check if today is an allowed day
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    // Add debug information for day checks
    print('Day of week: $dayOfWeek (${_getDayName(dayOfWeek)})');
    print('Allowed days: $allowedDaysString');
    print('Is today allowed? ${allowedDays.length > dayOfWeek && allowedDays[dayOfWeek]}');
    
    if (allowedDays.length > dayOfWeek && !allowedDays[dayOfWeek]) {
      print('LOCK REASON: Not allowed on this day');
      setState(() {
        _lockReason = 'App is not available on ${_getDayName(dayOfWeek)}.';
        _lockDetails = 'The app is only available on: ${allowedDays.asMap().entries.where((e) => e.value).map((e) => _getDayName(e.key)).join(', ')}.';
      });
      return;
    }
    
    // Check restricted time periods
    final restrictedPeriodsJson = prefs.getString('restrictedPeriods') ?? '[]';
    
    // Add debug information for restricted periods
    print('Restricted periods: $restrictedPeriodsJson');
    
    if (restrictedPeriodsJson.isNotEmpty && restrictedPeriodsJson != '[]') {
      try {
        final List<dynamic> restrictedPeriods = jsonDecode(restrictedPeriodsJson);
        print('Number of restricted periods: ${restrictedPeriods.length}');
        
        for (final period in restrictedPeriods) {
          final startHour = period['startHour'] as int;
          final startMinute = period['startMinute'] as int;
          final endHour = period['endHour'] as int;
          final endMinute = period['endMinute'] as int;
          
          final restrictedStartMinutes = startHour * 60 + startMinute;
          final restrictedEndMinutes = endHour * 60 + endMinute;
          
          // Format the restricted period times for display
          final restrictedStartTime = TimeOfDay(hour: startHour, minute: startMinute);
          final restrictedEndTime = TimeOfDay(hour: endHour, minute: endMinute);
          
          print('Checking restricted period: ${_formatTime(restrictedStartTime)} - ${_formatTime(restrictedEndTime)}');
          
          if (currentMinutes >= restrictedStartMinutes && currentMinutes <= restrictedEndMinutes) {
            print('LOCK REASON: In restricted period');
            setState(() {
              _lockReason = 'App is locked during restricted hours.';
              _lockDetails = 'Current restricted period: ${_formatTime(restrictedStartTime)} - ${_formatTime(restrictedEndTime)}';
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
    
    // Add debug information for daily limit
    print('Used minutes today: $usedMinutesToday / $maxMinutesPerDay');
    print('Daily limit: ${maxHoursPerDay.toStringAsFixed(1)} hours');
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      print('LOCK REASON: Daily time limit reached');
      setState(() {
        _lockReason = 'Daily screen time limit reached.';
        _lockDetails = 'Used today: ${(usedMinutesToday / 60).toStringAsFixed(1)} hours\nLimit: ${maxHoursPerDay.toStringAsFixed(1)} hours';
      });
      return;
    }
    
    print('No lock reason detected but lock screen is showing!');
    print('====================================');
    
    // If we get here, the app should be unlocked
    widget.onUnlock();
  }

  // Format TimeOfDay to a readable string (e.g., "8:05 AM")
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
  
  // Get the day name from a day of week index
  String _getDayName(int dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
  }
  
  // Verify the parent password to unlock the app
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
        // In a real app, you'd want to properly secure this
        if (_passwordController.text == '123456') {
          _unlockApp(minutes: 60); // Unlock for 60 minutes
          return;
        }
        
        // Check stored passwords/credentials from Firestore
        final List<dynamic> validCredentials = parentProfileDoc.data()?['parentPassword'] ?? [];
        
        if (validCredentials.contains(_passwordController.text)) {
          _unlockApp(minutes: 60); // Unlock for 60 minutes
        } else {
          setState(() {
            _errorMessage = 'Incorrect password';
            _isVerifying = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User profile not found';
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
  
  // Show unlock options dialog
  Future<void> _showUnlockOptions() async {
    setState(() => _isVerifying = false);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer_10),
              title: const Text('10 Minutes'),
              onTap: () {
                Navigator.of(context).pop();
                _unlockApp(minutes: 10);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('30 Minutes'),
              onTap: () {
                Navigator.of(context).pop();
                _unlockApp(minutes: 30);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('1 Hour'),
              onTap: () {
                Navigator.of(context).pop();
                _unlockApp(minutes: 60);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight),
              title: const Text('Until End of Day'),
              onTap: () {
                Navigator.of(context).pop();
                _unlockApp(untilEndOfDay: true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Unlock the app for a specified duration
  Future<void> _unlockApp({int minutes = 0, bool untilEndOfDay = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Set the override until time
    if (untilEndOfDay) {
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      await prefs.setString('screenTimeOverrideUntil', endOfDay.toIso8601String());
    } else if (minutes > 0) {
      final overrideUntil = now.add(Duration(minutes: minutes));
      await prefs.setString('screenTimeOverrideUntil', overrideUntil.toIso8601String());
    }
    
    // Use Future.delayed to ensure we're not calling onUnlock during build
    // This prevents the "setState() or markNeedsBuild() called during build" assertion error
    Future.microtask(() {
      // Unlock the app
      widget.onUnlock();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Don't use MaterialApp inside another MaterialApp
    // This prevents the Directionality error
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade300,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Spacer
                  const Spacer(flex: 1),
                  
                  // Lock Icon and Title
                  const Icon(
                    Icons.lock_clock,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screen Time Limit',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lock Reason Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _lockReason,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lockDetails,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        if (_nextAvailableTime != null) ...[  
                          const SizedBox(height: 16),
                          Text(
                            'Available again: ${DateFormat('EEEE, MMM d, h:mm a').format(_nextAvailableTime!)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Middle Spacer
                  const Spacer(flex: 1),
                  
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
                          'Please enter your parent password to unlock',
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
                  
                  // Bottom Spacer
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
