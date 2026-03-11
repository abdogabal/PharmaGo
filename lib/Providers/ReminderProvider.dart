import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Reminder.dart';
import '../core/Reusable_component/notification_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderProvider extends ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  ReminderProvider() {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson != null) {
      final List<dynamic> decoded = json.decode(remindersJson);
      _reminders = decoded.map((item) => Reminder.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_reminders.map((r) => r.toMap()).toList());
    await prefs.setString('reminders', encoded);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      // Cancel all notifications array securely
      for (var nId in reminder.notificationIds) {
        await FlutterLocalNotificationsPlugin().cancel(nId);
      }
      
      _reminders.removeAt(index);
      await _saveReminders();
      notifyListeners();
    }
  }
}
