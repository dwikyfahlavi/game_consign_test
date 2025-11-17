import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String note;

  @HiveField(3)
  DateTime? scheduledAt;

  @HiveField(4)
  double? latitude;

  @HiveField(5)
  double? longitude;

  @HiveField(6)
  double radiusMeters;

  ReminderModel({
    required this.id,
    required this.title,
    required this.note,
    this.scheduledAt,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100,
  });
}
