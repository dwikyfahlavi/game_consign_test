import 'package:game_consign_test/core/location_service.dart';
import 'package:game_consign_test/features/data/datasource/reminder_local_datasouce.dart';
import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/features/data/reminder_repository.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Opens the database file named 'employees'
  final employeeBox = await Hive.openBox<ReminderModel>('reminders_box');
  // Makes the opened box available to the rest of the app
  getIt.registerSingleton<Box<ReminderModel>>(employeeBox);

  // Core
  getIt.registerSingleton<LocationService>(LocationService());

  // Data source
  getIt.registerSingleton<ReminderLocalDataSource>(ReminderLocalDataSource());

  // Repository
  getIt.registerSingleton<ReminderRepository>(ReminderRepository());

  // Bloc (factory so multiple providers can be created)
  getIt.registerSingleton<ReminderBloc>(ReminderBloc());
}
