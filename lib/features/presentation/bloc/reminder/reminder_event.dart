abstract class ReminderEvent {}

class LoadRemindersEvent extends ReminderEvent {}

class AddReminderEvent extends ReminderEvent {
  final String title;
  final String note;
  final DateTime? scheduledAt;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;

  AddReminderEvent({
    required this.title,
    required this.note,
    this.scheduledAt,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100,
  });
}

class DeleteReminderEvent extends ReminderEvent {
  final String id;
  DeleteReminderEvent(this.id);
}

class CheckLocationEvent extends ReminderEvent {}
