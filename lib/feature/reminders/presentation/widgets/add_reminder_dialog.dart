import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_event.dart';
import '../bloc/reminder_bloc.dart';

class AddReminderDialog extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderDialog({super.key, this.reminder});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'medication';
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isRecurring = false;
  String? _recurringPattern;

  final List<Map<String, dynamic>> _reminderTypes = [
    {'value': 'medication', 'label': 'Medication', 'icon': Icons.medication},
    {'value': 'exercise', 'label': 'Exercise', 'icon': Icons.fitness_center},
    {'value': 'appointment', 'label': 'Appointment', 'icon': Icons.event},
    {'value': 'custom', 'label': 'Custom', 'icon': Icons.notifications},
  ];

  final List<String> _recurringOptions = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
      _selectedType = widget.reminder!.type;
      _selectedDateTime = widget.reminder!.dateTime;
      _isRecurring = widget.reminder!.isRecurring;
      _recurringPattern = widget.reminder!.recurringPattern;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: IntrinsicHeight(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_alert,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.reminder == null
                                ? 'Add Reminder'
                                : 'Edit Reminder',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.headlineLarge?.color,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter reminder title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter description (optional)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Selection
                    Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reminderTypes.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 6),
                              Text(type['label'] as String),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                () => _selectedType = type['value'] as String,
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Date & Time
                    Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(_selectedDateTime),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recurring
                    Row(
                      children: [
                        Checkbox(
                          value: _isRecurring,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value ?? false;
                              if (!_isRecurring) _recurringPattern = null;
                            });
                          },
                        ),
                        Text(
                          'Recurring Reminder',
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),

                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _recurringOptions.map((option) {
                          final isSelected = _recurringPattern == option;
                          return ChoiceChip(
                            label: Text(option.toUpperCase()),
                            selected: isSelected,
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              setState(
                                () => _recurringPattern = selected
                                    ? option
                                    : null,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Buttons
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 12,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveReminder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.reminder == null ? 'Add' : 'Update',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      if (_isRecurring && _recurringPattern == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a recurring pattern'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reminder = Reminder(
        id:
            widget.reminder?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        type: _selectedType,
        isRecurring: _isRecurring,
        recurringPattern: _recurringPattern,
        isCompleted: widget.reminder?.isCompleted ?? false,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
      );

      if (widget.reminder == null) {
        context.read<ReminderBloc>().add(AddReminder(reminder));
      } else {
        context.read<ReminderBloc>().add(UpdateReminder(reminder));
      }

      Navigator.pop(context);
    }
  }
}
