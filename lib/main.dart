import 'package:flutter/material.dart';
import 'package:game_consign_test/core/notification_service.dart';
import 'package:game_consign_test/features/data/models/reminder_model.dart';
import 'package:game_consign_test/features/presentation/pages/home_page.dart';
import 'package:game_consign_test/initialize_dependency.dart';
import 'package:game_consign_test/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Hive.initFlutter();
  // Opens a Hive box (database) named 'wilmar_app'
  await Hive.openBox('wilmar_app');

  // Registers the custom EmployeeModel adapter
  Hive.registerAdapter(ReminderModelAdapter());

  await setupLocator();
  initializeLocator();
  await NotificationService().requestExactAlarmPermission();
  await NotificationService().requestNotificationPermission();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomePage(),
    );
  }
}
