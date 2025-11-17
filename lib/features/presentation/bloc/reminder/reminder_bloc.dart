import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_consign_test/core/notification_service.dart';
import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_event.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_state.dart';
import 'package:game_consign_test/initialize_dependency.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final _uuid = const Uuid();

  ReminderBloc() : super(ReminderState(reminders: [], loading: false)) {
    on<LoadRemindersEvent>(_onLoad);
    on<AddReminderEvent>(_onAdd);
    on<DeleteReminderEvent>(_onDelete);
    on<CheckLocationEvent>(_onCheckLocation);
  }

  Future<void> _onLoad(
    LoadRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final list = await reminderLocalDataSource.getReminders();
    emit(state.copyWith(reminders: list, loading: false));
  }

  Future<void> _onAdd(
    AddReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final id = _uuid.v4();
    final model = ReminderModel(
      id: id,
      title: event.title,
      note: event.note,
      scheduledAt: event.scheduledAt,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusMeters: event.radiusMeters,
    );
    await reminderLocalDataSource.addReminder(model);

    // schedule notification for time-based reminders
    if (model.scheduledAt != null) {
      try {
        await _scheduleTimeNotification(model);
        emit(state.copyWith(loading: false));
      } catch (e) {
        if (e is PlatformException && e.code == "exact_alarms_not_permitted") {
          await NotificationService().openExactAlarmSettings();
          emit(state.copyWith(loading: false));
          return;
        }
      }
    }

    add(LoadRemindersEvent());
  }

  Future<void> _onDelete(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    await reminderLocalDataSource.deleteReminder(event.id);
    // you might want to cancel scheduled notifications by id mapping
    emit(state.copyWith(loading: false));
    add(LoadRemindersEvent());
  }

  Future<void> _onCheckLocation(
    CheckLocationEvent event,
    Emitter<ReminderState> emit,
  ) async {
    // Get current position
    emit(state.copyWith(loading: true));
    try {
      final hasPerm = await locationService.requestPermission();
      if (!hasPerm) return;
      final pos = await locationService.getCurrentPosition();
      final reminders =
          state.reminders
              .where((r) => r.latitude != null && r.longitude != null)
              .toList();
      for (var r in reminders) {
        final dist = locationService.distanceBetween(
          pos.latitude,
          pos.longitude,
          r.latitude!,
          r.longitude!,
        );
        if (dist <= r.radiusMeters) {
          await NotificationService().showNotification(
            id: r.id.hashCode,
            title: r.title,
            body: r.note,
          );
        }
      }
      emit(state.copyWith(loading: false));
    } catch (e) {
      print('Error checking location reminders: $e');
      emit(state.copyWith(loading: false));
      // ignore
    }
  }

  Future<void> _scheduleTimeNotification(ReminderModel model) async {
    if (model.scheduledAt == null) return;

    // initialize TZ once
    tz.initializeTimeZones();

    // if scheduled time already passed → schedule next day
    DateTime scheduleTime = model.scheduledAt!;
    if (scheduleTime.isBefore(DateTime.now())) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    try {
      await NotificationService().scheduleNotification(
        id: model.id.hashCode,
        title: model.title,
        body: model.note,
        scheduledDate: scheduleTime,
      );
    } catch (e) {
      // Android 13+ exact alarm restriction
      if (e is PlatformException && e.code == "exact_alarms_not_permitted") {
        // Open exact alarm settings so user can enable permission
        await NotificationService().openExactAlarmSettings();

        // You can also show a Snackbar, dialog, etc.
        print("Exact alarms not permitted. Redirecting to settings.");
      } else {
        // Unknown error
        print("Error scheduling notification: $e");
      }
    }
  }
}
