import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/ReminderProvider.dart';
import '../../../../Models/Reminder.dart';
import '../../../../core/Reusable_component/notification_handler.dart';

class ScheduledPage extends StatefulWidget {
  static const String routeName = "scheduled";
  const ScheduledPage({super.key});

  @override
  State<ScheduledPage> createState() => _ScheduledPageState();
}

class _ScheduledPageState extends State<ScheduledPage> {
  List<int> selectedDays = [];
  int selectedFrequency = 1;
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _nameController = TextEditingController();

  final List<String> dayKeys = [
    "mon", "tue", "wed", "thu", "fri", "sat", "sun"
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final formattedTime = localizations.formatTimeOfDay(selectedTime, alwaysUse24HourFormat: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("medicationReminder".tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "enterMedName".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "medName".tr(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "selectDay".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dayKeys.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedDays.contains(index);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          selectedDays.remove(index);
                        } else {
                          selectedDays.add(index);
                        }
                      }),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? ColorManger.green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            dayKeys[index].tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? ColorManger.white : ColorManger.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Frequency",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedFrequency,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Once a day")),
                      DropdownMenuItem(value: 2, child: Text("Twice a day (Every 12 hours)")),
                      DropdownMenuItem(value: 3, child: Text("Three times a day (Every 8 hours)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedFrequency = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "First Dose Time",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: ColorManger.green,
                        ),
                      ),
                      const Icon(Icons.alarm_add, color: ColorManger.green, size: 30),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManger.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    String medName = _nameController.text.trim();
                    if (medName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("noName".tr()), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select at least one day"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    List<int> notificationIds = [];
                    int baseId = now.millisecondsSinceEpoch ~/ 1000;
                    
                    for (int dayIndex in selectedDays) {
                      int targetWeekday = dayIndex + 1;
                      int currentWeekday = now.weekday;
                      
                      for (int freq = 0; freq < selectedFrequency; freq++) {
                        int hourOffset = freq * (24 ~/ selectedFrequency);
                        int targetHour = (selectedTime.hour + hourOffset) % 24;
                        int dayOffset = (selectedTime.hour + hourOffset) ~/ 24;

                        int daysToAdd = targetWeekday - currentWeekday + dayOffset;
                        if (daysToAdd < 0 || (daysToAdd == 0 && (now.hour > targetHour || (now.hour == targetHour && now.minute >= selectedTime.minute)))) {
                          daysToAdd += 7;
                        }
                        
                        DateTime scheduledDate = DateTime(
                          now.year, now.month, now.day + daysToAdd,
                          targetHour, selectedTime.minute,
                        );

                        int nId = baseId++;
                        notificationIds.add(nId);

                        await NotificationHandler.scheduleNotification(
                          id: nId,
                          title: "Medication Reminder: $medName",
                          body: "It's time for your dose!",
                          scheduledDate: scheduledDate,
                        );
                      }
                    }

                    Reminder newReminder = Reminder(
                      id: DateTime.now().toIso8601String(),
                      medName: medName,
                      selectedDays: selectedDays,
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      frequency: selectedFrequency,
                      notificationIds: notificationIds,
                    );

                    Provider.of<ReminderProvider>(context, listen: false).addReminder(newReminder);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "setReminder".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorManger.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}