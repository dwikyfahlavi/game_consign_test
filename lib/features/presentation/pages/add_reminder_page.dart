import 'package:flutter/material.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_event.dart';
import 'package:game_consign_test/initialize_dependency.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  DateTime? _scheduledAt;
  double? _lat;
  double? _lon;
  double _radius = 100;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => child ?? const SizedBox.shrink(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime:
          _scheduledAt != null
              ? TimeOfDay.fromDateTime(_scheduledAt!)
              : TimeOfDay.now(),
    );
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
  }

  Future<void> _useMyLocation() async {
    final ok = await locationService.requestPermission();
    if (!ok) return;
    final pos = await locationService.getCurrentPosition();
    setState(() {
      _lat = pos.latitude;
      _lon = pos.longitude;
    });
  }

  String _formatDateTime() {
    if (_scheduledAt == null) return 'No time selected';
    final local = MaterialLocalizations.of(context);
    final date = local.formatFullDate(_scheduledAt!);
    final time = local.formatTimeOfDay(
      TimeOfDay.fromDateTime(_scheduledAt!),
      alwaysUse24HourFormat: false,
    );
    return '$date • $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _title,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon: const Icon(Icons.title),
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                _title.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed:
                                          () => setState(() => _title.clear()),
                                    )
                                    : null,
                          ),
                          onChanged: (_) => setState(() {}),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Enter a title'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _note,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            prefixIcon: Icon(Icons.note),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time),
                                label: const Text('Pick date & time'),
                                onPressed: _pickDateTime,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_formatDateTime())),
                            if (_scheduledAt != null)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _pickDateTime,
                              ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.my_location),
                                label: const Text('Use my location'),
                                onPressed: _useMyLocation,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _lat != null
                                    ? '${_lat!.toStringAsFixed(6)}, ${_lon!.toStringAsFixed(6)}'
                                    : 'No location',
                              ),
                            ),
                            if (_lat != null)
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _useMyLocation,
                              ),
                          ],
                        ),
                        if (_lat != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _radius,
                                  min: 10,
                                  max: 1000,
                                  divisions: 99,
                                  label: '${_radius.toInt()} m',
                                  onChanged: (v) => setState(() => _radius = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_radius.toInt()} m',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        reminderBloc.add(
                          AddReminderEvent(
                            title:
                                _title.text.isEmpty ? 'Reminder' : _title.text,
                            note: _note.text,
                            scheduledAt: _scheduledAt,
                            latitude: _lat,
                            longitude: _lon,
                            radiusMeters: _radius,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
