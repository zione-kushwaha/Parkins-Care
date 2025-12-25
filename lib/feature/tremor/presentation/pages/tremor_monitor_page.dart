import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../data/services/tremor_api_service.dart';
import '../../domain/entities/tremor_reading.dart';
import '../bloc/tremor_bloc.dart';
import '../bloc/tremor_event.dart';
import '../bloc/tremor_state.dart';
import '../widgets/tremor_history_widget.dart';
import '../widgets/emergency_contacts_widget.dart';

class TremorMonitorPage extends StatefulWidget {
  const TremorMonitorPage({super.key});

  @override
  State<TremorMonitorPage> createState() => _TremorMonitorPageState();
}

class _TremorMonitorPageState extends State<TremorMonitorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          child: Icon(Icons.monitor_heart, color: Colors.white),
        ),
        title: const Text(
          'Tremor Monitor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Monitor'),
            Tab(text: 'History'),
            Tab(text: 'Contacts'),
          ],
        ),
      ),
      body: BlocConsumer<TremorBloc, TremorState>(
        listener: (context, state) {
          if (state is TremorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TremorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SOSTriggered) {
            _showSOSDialog(context, state.primaryContact?.phoneNumber);
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMonitorTab(context, state, theme, isDark),
              TremorHistoryWidget(),
              EmergencyContactsWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonitorTab(
    BuildContext context,
    TremorState state,
    ThemeData theme,
    bool isDark,
  ) {
    TremorReading? currentReading;
    if (state is TremorMonitoring) {
      currentReading = state.currentReading;
      _isMonitoring = state.isRecording;
    } else {
      _isMonitoring = false;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SOS Button
          _buildSOSButton(context, theme),
          const SizedBox(height: 24),

          // Monitoring Status
          _buildStatusCard(currentReading, theme, isDark),
          const SizedBox(height: 24),

          // Real-time Visualization
          if (currentReading != null) ...[
            _buildTremorVisualization(currentReading, theme, isDark),
            const SizedBox(height: 24),
            _buildTremorMetrics(currentReading, theme, isDark),
          ],

          const SizedBox(height: 32),

          // Control Buttons
          _buildControlButtons(context, currentReading),
        ],
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context, ThemeData theme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<TremorBloc>().add(TriggerSOS());
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emergency, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'EMERGENCY SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tap to call emergency contact',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    TremorReading? reading,
    ThemeData theme,
    bool isDark,
  ) {
    final severity = reading?.severity ?? TremorSeverity.none;
    final color = _getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isMonitoring
                      ? Icons.fiber_manual_record
                      : Icons.pause_circle,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isMonitoring ? 'Monitoring Active' : 'Monitoring Paused',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      severity.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reading != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: color),
                  const SizedBox(width: 12),
                  Text(
                    severity.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTremorVisualization(
    TremorReading reading,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TremorWavePainter(
          magnitude: reading.magnitude,
          frequency: reading.frequency,
          color: _getSeverityColor(reading.severity),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${reading.magnitude.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getSeverityColor(reading.severity),
                ),
              ),
              const Text(
                'Threshold Magnitude',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTremorMetrics(
    TremorReading reading,
    ThemeData theme,
    bool isDark,
  ) {
    final x = reading.accelerometerData['x']!;
    final y = reading.accelerometerData['y']!;
    final z = reading.accelerometerData['z']!;

    // Calculate total acceleration and velocity indicators
    final totalAcceleration = reading.magnitude;
    final velocity = (x.abs() + y.abs() + z.abs()) / 3;

    return Column(
      children: [
        // Title
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.1),
                AppColors.primaryBlue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.sensors, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Detailed Sensor Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Row 1: Magnitude and Frequency
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Magnitude',
                totalAcceleration.toStringAsFixed(3),
                Icons.show_chart,
                const Color(0xFFFF6B6B),
                theme,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Frequency',
                '${reading.frequency.toStringAsFixed(2)} Hz',
                Icons.graphic_eq,
                AppColors.primaryBlue,
                theme,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: X, Y, Z Axes
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'X-Axis',
                x.toStringAsFixed(3),
                Icons.arrow_forward,
                const Color(0xFF4ECDC4),
                theme,
                isDark,
                subtitle:
                    '${x >= 0 ? '+' : ''}${(x * 100).toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Y-Axis',
                y.toStringAsFixed(3),
                Icons.arrow_upward,
                const Color(0xFFFFBE0B),
                theme,
                isDark,
                subtitle:
                    '${y >= 0 ? '+' : ''}${(y * 100).toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Z-Axis',
                z.toStringAsFixed(3),
                Icons.vertical_align_center,
                const Color(0xFF9D4EDD),
                theme,
                isDark,
                subtitle:
                    '${z >= 0 ? '+' : ''}${(z * 100).toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Velocity and Peak Detection
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Avg Velocity',
                velocity.toStringAsFixed(3),
                Icons.speed,
                const Color(0xFF20B2AA),
                theme,
                isDark,
                subtitle: 'm/s²',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Severity',
                reading.severity.label,
                Icons.priority_high,
                _getSeverityColor(reading.severity),
                theme,
                isDark,
                subtitle: reading.severity.description.split(',')[0],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Additional Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sensor Information',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Sampling Rate', '50 Hz (20ms)', theme),
              _buildInfoRow('Parkinsonian Range', '3-7 Hz', theme),
              _buildInfoRow(
                'Current Range',
                reading.frequency >= 3 && reading.frequency <= 7
                    ? 'In Range ✓'
                    : 'Out of Range',
                theme,
                highlight: reading.frequency >= 3 && reading.frequency <= 7,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(TremorSeverity severity) {
    switch (severity) {
      case TremorSeverity.none:
        return const Color(0xFF4ECDC4);
      case TremorSeverity.mild:
        return const Color(0xFFFFBE0B);
      case TremorSeverity.moderate:
        return const Color(0xFFFF8C42);
      case TremorSeverity.severe:
        return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight
                  ? const Color(0xFF4ECDC4)
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, TremorReading? reading) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (_isMonitoring) {
              context.read<TremorBloc>().add(StopTremorMonitoring());
            } else {
              context.read<TremorBloc>().add(StartTremorMonitoring());
            }
          },
          icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
          label: Text(
            _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isMonitoring ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        if (reading != null && _isMonitoring) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              TremorApiService().sendTremorData(reading).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tremor data synced successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sync tremor data.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Saving and syncing to backend...'),
                    ],
                  ),
                  backgroundColor: AppColors.primaryBlue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save & Sync to Backend'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(
                  'Auto-syncing to: pleasing-guppy-hardy.ngrok-free.app',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showSOSDialog(BuildContext context, String? phoneNumber) {
    // Use default emergency number 888 if no contact configured
    final emergencyNumber = phoneNumber ?? '888';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency SOS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phoneNumber != null
                  ? 'Choose how to contact your emergency contact:'
                  : 'Emergency contact: $emergencyNumber (Default)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                emergencyNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Select an option:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),

          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Launch phone dialer
              // url_launcher package: launch('tel:$emergencyNumber');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $emergencyNumber...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.call),
            label: const Text('Phone Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class TremorWavePainter extends CustomPainter {
  final double magnitude;
  final double frequency;
  final Color color;

  TremorWavePainter({
    required this.magnitude,
    required this.frequency,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final amplitude = magnitude * 30;
    final wavelength = size.width / (frequency * 2);

    path.moveTo(0, size.height / 2);

    for (double x = 0; x < size.width; x += 1) {
      final y =
          size.height / 2 +
          amplitude * math.sin((x / wavelength) * 2 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TremorWavePainter oldDelegate) =>
      magnitude != oldDelegate.magnitude || frequency != oldDelegate.frequency;
}
