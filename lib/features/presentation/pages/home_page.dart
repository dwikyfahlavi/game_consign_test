import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_bloc.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_event.dart';
import 'package:game_consign_test/features/presentation/bloc/reminder/reminder_state.dart';
import 'package:game_consign_test/features/presentation/pages/add_reminder_page.dart';
import 'package:game_consign_test/initialize_dependency.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => reminderBloc..add(LoadRemindersEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.reminders.isEmpty) {
            return const Center(child: Text('No reminders yet'));
          }
          return ListView.builder(
            itemCount: state.reminders.length,
            itemBuilder: (context, idx) {
              final r = state.reminders[idx];
              return ListTile(
                title: Text(r.title),
                subtitle: Text(_subtitleFor(r)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => reminderBloc.add(DeleteReminderEvent(r.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderPage()),
              );
              reminderBloc.add(LoadRemindersEvent());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'checkloc',
            onPressed: () => reminderBloc.add(CheckLocationEvent()),
            icon: const Icon(Icons.my_location),
            label: const Text('Check location'),
          ),
        ],
      ),
    );
  }

  String _subtitleFor(r) {
    if (r.scheduledAt != null) return 'At ${r.scheduledAt}';
    if (r.latitude != null && r.longitude != null) {
      return 'Location: ${r.latitude}, ${r.longitude} (radius ${r.radiusMeters}m)';
    }
    return r.note;
  }
}
