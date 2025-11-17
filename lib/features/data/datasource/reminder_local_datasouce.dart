import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/initialize_dependency.dart';

class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders() async {
    final box = reminderBox;
    final list = box.values.cast<ReminderModel>().toList();

    return List<ReminderModel>.from(list);
  }

  Future<void> addReminder(ReminderModel model) async {
    final box = reminderBox;
    await box.put(model.id, model);
  }

  Future<void> deleteReminder(String id) async {
    final box = reminderBox;
    await box.delete(id);
  }
}
