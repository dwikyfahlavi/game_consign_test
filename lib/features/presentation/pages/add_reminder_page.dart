import 'package:flutter/material.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_event.dart';
import 'package:game_consign_test/initialize_dependency.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  DateTime? _scheduledAt;
  double? _lat;
  double? _lon;
  double _radius = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    ).then((date) {
                      if (date == null) return;
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((time) {
                        if (time == null) return;
                        setState(() {
                          _scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      });
                    });
                  },
                  child: const Text('Pick time'),
                ),
                const SizedBox(width: 12),
                Text(
                  _scheduledAt != null ? _scheduledAt.toString() : 'No time',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ok = await locationService.requestPermission();
                    if (!ok) return;
                    final pos = await locationService.getCurrentPosition();
                    setState(() {
                      _lat = pos.latitude;
                      _lon = pos.longitude;
                    });
                  },
                  child: const Text('Use my location'),
                ),
                const SizedBox(width: 12),
                Text(_lat != null ? '$_lat, $_lon' : 'No location'),
              ],
            ),
            if (_lat != null) ...[
              const SizedBox(height: 8),
              Text('Radius: ${_radius.toInt()} m'),
              Slider(
                value: _radius,
                min: 10,
                max: 1000,
                onChanged: (v) => setState(() => _radius = v),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      reminderBloc.add(
                        AddReminderEvent(
                          title: _title.text.isEmpty ? 'Reminder' : _title.text,
                          note: _note.text,
                          scheduledAt: _scheduledAt,
                          latitude: _lat,
                          longitude: _lon,
                          radiusMeters: _radius,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






// End of project files