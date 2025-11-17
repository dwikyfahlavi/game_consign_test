import 'package:game_consign_test/features/data/models/reminder_model.dart';

class ReminderState {
  final List<ReminderModel> reminders;
  final bool loading;

  ReminderState({required this.reminders, required this.loading});

  ReminderState copyWith({List<ReminderModel>? reminders, bool? loading}) =>
      ReminderState(
        reminders: reminders ?? this.reminders,
        loading: loading ?? this.loading,
      );
}
