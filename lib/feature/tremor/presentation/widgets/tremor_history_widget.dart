import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/tremor_reading.dart';
import '../bloc/tremor_bloc.dart';
import '../bloc/tremor_event.dart';
import '../bloc/tremor_state.dart';

class TremorHistoryWidget extends StatefulWidget {
  const TremorHistoryWidget({super.key});

  @override
  State<TremorHistoryWidget> createState() => _TremorHistoryWidgetState();
}

class _TremorHistoryWidgetState extends State<TremorHistoryWidget> {
  @override
  void initState() {
    super.initState();
    context.read<TremorBloc>().add(LoadTremorHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TremorBloc, TremorState>(
      builder: (context, state) {
        if (state is TremorHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TremorHistoryLoaded) {
          if (state.readings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tremor history',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start monitoring to record data',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TremorBloc>().add(LoadTremorHistory());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.readings.length,
              itemBuilder: (context, index) {
                final reading = state.readings[index];
                return _buildHistoryCard(context, reading, theme, isDark);
              },
            ),
          );
        }

        return const Center(child: Text('Load history to view'));
      },
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    TremorReading reading,
    ThemeData theme,
    bool isDark,
  ) {
    final color = _getSeverityColor(reading.severity);

    return Dismissible(
      key: Key(reading.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<TremorBloc>().add(DeleteTremorReading(reading.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.monitor_heart, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.severity.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(reading.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Magnitude',
                    reading.magnitude.toStringAsFixed(2),
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Frequency',
                    '${reading.frequency.toStringAsFixed(1)} Hz',
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(TremorSeverity severity) {
    switch (severity) {
      case TremorSeverity.none:
        return Colors.green;
      case TremorSeverity.mild:
        return Colors.yellow.shade700;
      case TremorSeverity.moderate:
        return Colors.orange;
      case TremorSeverity.severe:
        return Colors.red;
    }
  }
}
