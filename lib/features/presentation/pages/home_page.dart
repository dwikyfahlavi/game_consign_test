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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // modern appbar with elevation and subtle bottom blur effect
      appBar: AppBar(
        title: const Text('Reminders'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),
      // subtle gradient background for a modern look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state.reminders.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  reminderBloc.add(LoadRemindersEvent());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: state.reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final r = state.reminders[idx];

                    return Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        reminderBloc.add(DeleteReminderEvent(r.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Reminder deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // If your bloc supports undo, you can dispatch an event here.
                                // Otherwise re-load reminders to refresh the UI
                                reminderBloc.add(LoadRemindersEvent());
                              },
                            ),
                          ),
                        );
                      },
                      child: _ReminderCard(reminder: r),
                    );
                  },
                ),
              );
            },
          ),
        ),
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
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'checkloc',
            onPressed: () => reminderBloc.add(CheckLocationEvent()),
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // simple illustrative icon for empty state
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(
                Icons.notifications_off,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: style.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first reminder. You can set time-based or location-based reminders.',
              style: style.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final dynamic reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitleFor(reminder);
    final leadingIcon = _leadingIconFor(reminder);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // potential place to open detail or edit
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(leadingIcon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed:
                    () => reminderBloc.add(DeleteReminderEvent(reminder.id)),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _leadingIconFor(dynamic r) {
    if (r.scheduledAt != null) return Icons.access_time;
    if (r.latitude != null && r.longitude != null) return Icons.place;
    return Icons.note;
  }

  String _subtitleFor(dynamic r) {
    if (r.scheduledAt != null) {
      // simple, readable formatted time; adapt to your Reminder model's DateTime
      final dt =
          r.scheduledAt is DateTime
              ? r.scheduledAt.toLocal().toString().split('.').first
              : r.scheduledAt.toString();
      return 'At $dt';
    }
    if (r.latitude != null && r.longitude != null) {
      return 'Location: ${r.latitude.toStringAsFixed(4)}, ${r.longitude.toStringAsFixed(4)} • ${r.radiusMeters ?? '-'} m';
    }
    return r.note ?? '';
  }
}
