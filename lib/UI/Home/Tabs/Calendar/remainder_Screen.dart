import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import '../../../../core/Reusable_component/notification_handler.dart';

class ScheduledPage extends StatefulWidget {
  static const String routeName = "scheduled";
  const ScheduledPage({super.key});

  @override
  State<ScheduledPage> createState() => _ScheduledPageState();
}

class _ScheduledPageState extends State<ScheduledPage> {
  int selectedDayIndex = 2;
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
                    bool isSelected = selectedDayIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDayIndex = index),
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
                "reminderTime".tr(),
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

                    final scheduledDate = DateTime.now();

                    await NotificationHandler.scheduleNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: "Medication Reminder: $medName",
                      body: "It's time for your dose!",
                      scheduledDate: scheduledDate,
                    );

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