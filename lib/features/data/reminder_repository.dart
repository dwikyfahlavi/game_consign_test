import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/initialize_dependency.dart';

class ReminderRepository {
  ReminderRepository();

  Future<List<ReminderModel>> getAll() =>
      reminderLocalDataSource.getReminders();
  Future<void> create(ReminderModel model) =>
      reminderLocalDataSource.addReminder(model);
  Future<void> remove(String id) => reminderLocalDataSource.deleteReminder(id);
}
