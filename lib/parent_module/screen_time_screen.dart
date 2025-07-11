import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../parent_module/screen_time_lock_screen.dart';

class ScreenTimeScreen extends StatefulWidget {
  final String childId;

  const ScreenTimeScreen({Key? key, required this.childId}) : super(key: key);

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  bool _isLoading = true;
  bool _screenTimeEnabled = true;
  double _maxHoursPerDay = 2.0;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  List<bool> _allowedDays = List.filled(7, true); // Sun, Mon, Tue, Wed, Thu, Fri, Sat
  
  // Restricted time periods - each period has startHour, startMinute, endHour, endMinute
  List<Map<String, int>> _restrictedPeriods = [];
  
  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  
  @override
  void initState() {
    super.initState();
    _loadScreenTimeSettings();
  }
  
  Future<void> _loadScreenTimeSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Get the current user's ID or use the provided childId
      final currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? widget.childId;
      
      // Get screen time settings from Firestore
      final settingsDoc = await FirebaseFirestore.instance
          .collection('screenTimeSettings')
          .doc(userId)
          .get();
      
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        setState(() {
          _screenTimeEnabled = data['enabled'] ?? true;
          _maxHoursPerDay = (data['maxHoursPerDay'] ?? 2.0).toDouble();
          
          // Parse start time
          final startHour = data['startHour'] ?? 8;
          final startMinute = data['startMinute'] ?? 0;
          _startTime = TimeOfDay(hour: startHour, minute: startMinute);
          
          // Parse end time
          final endHour = data['endHour'] ?? 20;
          final endMinute = data['endMinute'] ?? 0;
          _endTime = TimeOfDay(hour: endHour, minute: endMinute);
          
          // Parse allowed days
          final allowedDays = data['allowedDays'] as List<dynamic>?;
          if (allowedDays != null) {
            _allowedDays = allowedDays.map((day) => day as bool).toList();
          }
          
          // Parse restricted periods
          final restrictedPeriods = data['restrictedPeriods'] as List<dynamic>?;
          if (restrictedPeriods != null) {
            _restrictedPeriods = restrictedPeriods.map((period) {
              final periodMap = period as Map<String, dynamic>;
              return {
                'startHour': periodMap['startHour'] as int,
                'startMinute': periodMap['startMinute'] as int,
                'endHour': periodMap['endHour'] as int,
                'endMinute': periodMap['endMinute'] as int,
              };
            }).toList();
          }
        });
      }
      
      // Also load from SharedPreferences for local settings
      final prefs = await SharedPreferences.getInstance();
      final restrictedPeriodsJson = prefs.getString('restrictedPeriods');
      if (restrictedPeriodsJson != null && restrictedPeriodsJson.isNotEmpty) {
        try {
          final List<dynamic> periods = jsonDecode(restrictedPeriodsJson);
          setState(() {
            _restrictedPeriods = periods.map((period) {
              return {
                'startHour': period['startHour'] as int,
                'startMinute': period['startMinute'] as int,
                'endHour': period['endHour'] as int,
                'endMinute': period['endMinute'] as int,
              };
            }).toList();
          });
        } catch (e) {
          print('Error parsing restricted periods: $e');
        }
      }
    } catch (e) {
      print('Error loading screen time settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveScreenTimeSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Get the current user's ID or use the provided childId
      final currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? widget.childId;
      
      // Save settings to Firestore
      await FirebaseFirestore.instance
          .collection('screenTimeSettings')
          .doc(userId)
          .set({
        'enabled': _screenTimeEnabled,
        'maxHoursPerDay': _maxHoursPerDay,
        'startHour': _startTime.hour,
        'startMinute': _startTime.minute,
        'endHour': _endTime.hour,
        'endMinute': _endTime.minute,
        'allowedDays': _allowedDays,
        'restrictedPeriods': _restrictedPeriods,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Also save to shared preferences for quick access in the app
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('screenTimeEnabled', _screenTimeEnabled);
      await prefs.setDouble('maxHoursPerDay', _maxHoursPerDay);
      await prefs.setInt('startHour', _startTime.hour);
      await prefs.setInt('startMinute', _startTime.minute);
      await prefs.setInt('endHour', _endTime.hour);
      await prefs.setInt('endMinute', _endTime.minute);
      
      // Save allowed days as a string (comma-separated booleans)
      final allowedDaysString = _allowedDays.map((day) => day ? '1' : '0').join(',');
      await prefs.setString('allowedDays', allowedDaysString);
      
      // Save restricted periods as JSON string
      final restrictedPeriodsJson = jsonEncode(_restrictedPeriods);
      await prefs.setString('restrictedPeriods', restrictedPeriodsJson);
      
      // Set initial screen time usage for today if not already set
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastActiveDate = prefs.getString('lastActiveDate');
      
      if (lastActiveDate != today) {
        await prefs.setInt('screenTimeUsedToday', 0);
        await prefs.setString('lastActiveDate', today);
      }
      
      // Force the screen time manager to reload settings
      await ScreenTimeManager.trackUsage();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen time settings saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }
  
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }
  
  Future<void> _addRestrictedPeriod() async {
    TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Restricted Time Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('During this time period, the app will be locked even if it is within allowed hours.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Start: '),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          startTime = picked;
                        });
                      }
                    },
                    child: Text(_formatTimeOfDay(startTime)),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('End: '),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          endTime = picked;
                        });
                      }
                    },
                    child: Text(_formatTimeOfDay(endTime)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _restrictedPeriods.add({
                    'startHour': startTime.hour,
                    'startMinute': startTime.minute,
                    'endHour': endTime.hour,
                    'endMinute': endTime.minute,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _removeRestrictedPeriod(int index) {
    setState(() {
      _restrictedPeriods.removeAt(index);
    });
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();  // 5:08 PM
    return format.format(dt);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade700,
        title: const Text('Screen Time Settings', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildScreenTimeContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveScreenTimeSettings,
        backgroundColor: Colors.orange.shade700,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
      ),
    );
  }
  
  Widget _buildScreenTimeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable/Disable Screen Time
          _buildSectionCard(
            title: 'Screen Time Controls',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Enable Screen Time Limits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Turn on to enforce screen time limits',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _screenTimeEnabled,
                  activeColor: Colors.orange.shade700,
                  onChanged: (value) {
                    setState(() {
                      _screenTimeEnabled = value;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Daily Time Limit'),
                  subtitle: Text('${_maxHoursPerDay.toStringAsFixed(1)} hours per day'),
                  trailing: const Icon(Icons.timer),
                ),
                Slider(
                  value: _maxHoursPerDay,
                  min: 0.5,
                  max: 6.0,
                  divisions: 11,
                  label: '${_maxHoursPerDay.toStringAsFixed(1)} hours',
                  activeColor: Colors.orange.shade700,
                  onChanged: _screenTimeEnabled
                      ? (value) {
                          setState(() {
                            _maxHoursPerDay = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time Window Settings
          _buildSectionCard(
            title: 'Allowed Time Window',
            child: Column(
              children: [
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(_formatTimeOfDay(_startTime)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _screenTimeEnabled ? _selectStartTime : null,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(_formatTimeOfDay(_endTime)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _screenTimeEnabled ? _selectEndTime : null,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Restricted Time Periods
          _buildSectionCard(
            title: 'Restricted Time Periods',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Add specific time periods when the app should be locked, even during allowed hours. '
                    'Useful for meal times, homework time, etc.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                if (_restrictedPeriods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No restricted periods set', style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _restrictedPeriods.length,
                    itemBuilder: (context, index) {
                      final period = _restrictedPeriods[index];
                      final startTime = TimeOfDay(hour: period['startHour']!, minute: period['startMinute']!);
                      final endTime = TimeOfDay(hour: period['endHour']!, minute: period['endMinute']!);
                      
                      return ListTile(
                        leading: const Icon(Icons.block, color: Colors.red),
                        title: Text('Restricted Period ${index + 1}'),
                        subtitle: Text('${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeRestrictedPeriod(index),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addRestrictedPeriod,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Restricted Period'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Allowed Days Settings
          _buildSectionCard(
            title: 'Allowed Days',
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select days when the app can be used:'),
                ),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    return FilterChip(
                      label: Text(_dayNames[index]),
                      selected: _allowedDays[index],
                      onSelected: _screenTimeEnabled
                          ? (selected) {
                              setState(() {
                                _allowedDays[index] = selected;
                              });
                            }
                          : null,
                      selectedColor: Colors.orange.shade200,
                      checkmarkColor: Colors.orange.shade700,
                    );
                  }),
                ),
              ],
            ),
          ),
          
          
          // Lock Override
          _buildSectionCard(
            title: 'Lock Override',
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.orange.shade700),
                  title: const Text('Override Lock'),
                  subtitle: const Text(
                    'When screen time limits are reached, the app will be locked. Only a parent can unlock it with their password.',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show dialog to explain how to unlock
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Unlock Instructions'),
                        content: const Text(
                          'When the app is locked due to screen time limits, you can unlock it by:\n\n'
                          '1. Tap on "Unlock"\n'
                          '2. Enter your parent password (same as Parent Mode)\n'
                          '3. Choose to unlock for 15 minutes, 1 hour, or for the rest of the day',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('How to Unlock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Information card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'About Screen Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Screen time limits help children develop healthy digital habits. '
                  'The app will automatically lock when the daily time limit is reached '
                  'or when outside the allowed time window.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 80), // Extra space for the FAB
        ],
      ),
    );
  }
  
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
