import 'package:game_consign_test/core/location_service.dart';
import 'package:game_consign_test/features/data/datasource/reminder_local_datasouce.dart';
import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/features/data/reminder_repository.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_bloc.dart';
import 'package:game_consign_test/service_locator.dart';
import 'package:hive/hive.dart';

late ReminderBloc reminderBloc;
late ReminderLocalDataSource reminderLocalDataSource;
late ReminderRepository reminderRepository;
late Box<ReminderModel> reminderBox;
late LocationService locationService;

void initializeLocator() {
  reminderBloc = getIt.get<ReminderBloc>();
  reminderLocalDataSource = getIt.get<ReminderLocalDataSource>();
  reminderRepository = getIt.get<ReminderRepository>();
  reminderBox = getIt.get<Box<ReminderModel>>();
  locationService = getIt.get<LocationService>();
}
