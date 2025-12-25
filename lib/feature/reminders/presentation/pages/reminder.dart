import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/entities/reminder_state.dart';
import '../bloc/reminder_bloc.dart';
import '../widgets/add_reminder_dialog.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReminderBloc>().add(LoadReminders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : AppColors.primaryBlue,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.notifications_active, color: Colors.white),
        ),
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<ReminderBloc>().add(LoadReminders());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocConsumer<ReminderBloc, ReminderState>(
        listener: (context, state) {
          if (state is ReminderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReminderOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReminderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reminders',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          if (state is ReminderLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildReminderList(
                  context,
                  state.upcomingReminders,
                  'No upcoming reminders',
                  Icons.event_available,
                ),
                _buildReminderList(
                  context,
                  state.completedReminders,
                  'No completed reminders',
                  Icons.check_circle_outline,
                ),
              ],
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => _showAddReminderDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Reminder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    List<Reminder> reminders,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(context, reminder);
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final isOverdue = reminder.dateTime.isBefore(now) && !reminder.isCompleted;

    final typeIcons = {
      'medication': Icons.medication,
      'exercise': Icons.fitness_center,
      'appointment': Icons.event,
      'custom': Icons.notifications,
    };

    final typeColors = {
      'medication': const Color(0xFF4ECDC4),
      'exercise': const Color(0xFFFF6B6B),
      'appointment': AppColors.primaryBlue,
      'custom': const Color(0xFFFFBE0B),
    };

    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColors[reminder.type]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcons[reminder.type],
                    color: typeColors[reminder.type],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: typeColors[reminder.type],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: reminder.isCompleted,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    context.read<ReminderBloc>().add(
                      ToggleReminderComplete(reminder.id),
                    );
                  },
                ),
              ],
            ),
            if (reminder.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isOverdue
                      ? Colors.red
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(reminder.dateTime),
                  style: TextStyle(
                    fontSize: 13,
                    color: isOverdue
                        ? Colors.red
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (reminder.isRecurring) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.repeat, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    reminder.recurringPattern ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first reminder',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ReminderBloc>(),
        child: const AddReminderDialog(),
      ),
    );
  }
}
