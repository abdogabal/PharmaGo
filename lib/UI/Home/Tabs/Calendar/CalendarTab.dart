import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/ReminderProvider.dart';

class MedicationListScreen extends StatelessWidget {
  static const String routeName = "medicationList";

  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("medicines".tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ReminderProvider>(
          builder: (context, provider, child) {
            final items = provider.reminders;
            if (items.isEmpty) {
              return Center(child: Text("No reminders set".tr()));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final reminder = items[index];
                      final isAm = reminder.hour < 12;
                      final displayHour = reminder.hour == 0 ? 12 : (reminder.hour > 12 ? reminder.hour - 12 : reminder.hour);
                      final timeString = '${displayHour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')} ${isAm ? "AM" : "PM"}';
                      final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                      String daysStr = reminder.selectedDays.map((d) => dayNames[d]).join(', ');
                      String freqStr = reminder.frequency == 1 ? "Once daily" : (reminder.frequency == 2 ? "Twice daily" : "3 times daily");
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.medication, color: Colors.teal, size: 40),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.medName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Days: $daysStr",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  Text(
                                    "Starting at $timeString • $freqStr",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                provider.deleteReminder(reminder.id);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.pushNamed(context, "scheduled");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}