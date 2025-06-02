import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScreenTimeService {
  static final ScreenTimeService _instance = ScreenTimeService._internal();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._internal();
  
  // Timer to track usage
  Timer? _usageTimer;
  DateTime? _sessionStartTime;
  
  // Current status
  bool _isLocked = false;
  
  // Getters
  bool get isLocked => _isLocked;
  
  // Initialize the service
  Future<void> initialize() async {
    await _loadSettings();
    _startUsageTracking();
  }
  
  // Load screen time settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Reset daily usage if it's a new day
    final lastUsageDate = prefs.getString('screenTimeLastUsageDate');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (lastUsageDate != today) {
      // It's a new day, reset the counter
      await prefs.setInt('screenTimeUsedToday', 0);
      await prefs.setString('screenTimeLastUsageDate', today);
    }
    
    // Check if we need to lock the app
    await checkScreenTimeLimits();
  }
  
  // Start tracking screen time usage
  void _startUsageTracking() {
    // Cancel any existing timer
    _usageTimer?.cancel();
    
    // Record session start time
    _sessionStartTime = DateTime.now();
    
    // Start a new timer that updates usage every minute
    _usageTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateUsageTime();
      await checkScreenTimeLimits();
    });
  }
  
  // Stop tracking screen time usage
  void stopUsageTracking() {
    _usageTimer?.cancel();
    _usageTimer = null;
    
    // Update usage one last time
    _updateUsageTime();
  }
  
  // Update the usage time in SharedPreferences
  Future<void> _updateUsageTime() async {
    if (_sessionStartTime == null) return;
    
    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStartTime!);
    _sessionStartTime = now; // Reset for next interval
    
    // Update usage in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final newUsedMinutes = usedMinutesToday + sessionDuration.inMinutes;
    await prefs.setInt('screenTimeUsedToday', newUsedMinutes);
    
    // Also update in Firestore for parent monitoring
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final today = DateFormat('yyyy-MM-dd').format(now);
        await FirebaseFirestore.instance
            .collection('screenTimeUsage')
            .doc(currentUser.uid)
            .set({
          'lastUpdated': FieldValue.serverTimestamp(),
          'usageByDate': {
            today: newUsedMinutes,
          },
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating screen time usage in Firestore: $e');
    }
  }
  
  // Check if the app should be locked based on screen time limits
  Future<bool> checkScreenTimeLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeEnabled = prefs.getBool('screenTimeEnabled') ?? false;
    
    // If screen time is not enabled, app should not be locked
    if (!screenTimeEnabled) {
      _isLocked = false;
      return false;
    }
    
    // Check if there's an active override
    final overrideUntilString = prefs.getString('screenTimeOverrideUntil');
    if (overrideUntilString != null) {
      final overrideUntil = DateTime.parse(overrideUntilString);
      if (DateTime.now().isBefore(overrideUntil)) {
        // Override is still active
        _isLocked = false;
        return false;
      } else {
        // Override has expired, clear it
        await prefs.remove('screenTimeOverrideUntil');
      }
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
    if (currentMinutes < startMinutes || currentMinutes > endMinutes) {
      _isLocked = true;
      return true;
    }
    
    // Check if today is an allowed day
    final allowedDaysString = prefs.getString('allowedDays') ?? '1,1,1,1,1,1,1';
    final allowedDays = allowedDaysString.split(',').map((day) => day == '1').toList();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    if (!allowedDays[dayOfWeek]) {
      _isLocked = true;
      return true;
    }
    
    // Check if daily time limit is reached
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    if (usedMinutesToday >= maxMinutesPerDay) {
      _isLocked = true;
      return true;
    }
    
    // If we get here, the app shouldn't be locked
    _isLocked = false;
    return false;
  }
  
  // Get the remaining screen time for today
  Future<int> getRemainingMinutesToday() async {
    final prefs = await SharedPreferences.getInstance();
    final usedMinutesToday = prefs.getInt('screenTimeUsedToday') ?? 0;
    final maxHoursPerDay = prefs.getDouble('maxHoursPerDay') ?? 2.0;
    final maxMinutesPerDay = (maxHoursPerDay * 60).toInt();
    
    return maxMinutesPerDay - usedMinutesToday;
  }
  
  // Reset screen time usage for testing
  Future<void> resetUsageForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('screenTimeUsedToday', 0);
    await prefs.setString('screenTimeLastUsageDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }
  
  // Manually lock the app (for parent controls)
  Future<void> lockApp() async {
    _isLocked = true;
    
    // Stop tracking usage when locked
    _usageTimer?.cancel();
    _usageTimer = null;
  }
  
  // Manually unlock the app (for parent controls)
  Future<void> unlockApp({int minutes = 0, bool untilEndOfDay = false}) async {
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
    
    _isLocked = false;
    
    // Restart usage tracking
    _startUsageTracking();
  }
}
