import 'dart:convert';

class Reminder {
  final String id;
  final String medName;
  final List<int> selectedDays;
  final int hour;
  final int minute;
  final int frequency; 
  final List<int> notificationIds;

  Reminder({
    required this.id,
    required this.medName,
    required this.selectedDays,
    required this.hour,
    required this.minute,
    required this.frequency,
    required this.notificationIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medName': medName,
      'selectedDays': selectedDays,
      'hour': hour,
      'minute': minute,
      'frequency': frequency,
      'notificationIds': notificationIds,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      medName: map['medName'],
      selectedDays: List<int>.from(map['selectedDays'] ?? []),
      hour: map['hour'],
      minute: map['minute'],
      frequency: map['frequency'] ?? 1,
      notificationIds: List<int>.from(map['notificationIds'] ?? [(map['notificationId'] ?? 0)]),
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) =>
      Reminder.fromMap(json.decode(source));
}
