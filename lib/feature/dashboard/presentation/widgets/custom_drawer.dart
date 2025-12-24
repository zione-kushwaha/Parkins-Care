import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/utils/utils/size_extension.dart';
import '../../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../../core/theme/bloc/theme_event.dart';
import '../../../../../core/theme/bloc/theme_state.dart';
import 'drawer_header.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          buildDrawerHeader(context),
          SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavigationItem(
                  context,
                  icon: Icons.message_rounded,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedbackDialog(context);
                  },
                ),
                _buildNavigationItem(
                  context,
                  icon: Icons.share_rounded,
                  title: 'Share App',
                  subtitle: 'Share with friends',
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _shareApp();
                  },
                ),
                _buildNavigationItem(
                  context,
                  icon: Icons.star_rounded,
                  title: 'Rate App',
                  subtitle: 'Rate us on Play Store',
                  iconColor: Colors.amber,
                  onTap: () {
                    Navigator.pop(context);
                    SnackBarUtils.showSuccess(
                      context,
                      'Rate feature coming soon!',
                    );
                  },
                ),
                // Theme Toggle
                _buildThemeToggleItem(context),

                // More Options Section
                _buildNavigationItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'Learn more about the app',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                Divider(height: context.containerHight24),

                // Logout Section
                _buildLogoutItem(context),
              ],
            ),
          ),

          // Footer
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildThemeToggleItem(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          title: Text(
            isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Toggle app theme',
            style: TextStyle(fontSize: 12),
          ),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
            activeColor: AppColors.primaryBlue,
          ),
          onTap: () {
            context.read<ThemeBloc>().add(ThemeToggled());
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        );
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 24),
      ),
      title: const Text(
        'Logout',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      ),
      subtitle: const Text(
        'Sign out of your account',
        style: TextStyle(fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        _showLogoutDialog(context);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

Widget _buildDrawerFooter(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          '@ParkinCare',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: .5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'For your infinity success',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
          ),
        ),
      ],
    ),
  );
}

void _shareApp() {
  const String appName = 'ParkinCare';
  const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.infinityacademy.app';
  const String message =
      'Check out $appName - Your ultimate study companion!\\n\\n'
      'Download now: $playStoreUrl';

  Share.share(message, subject: 'Share $appName');
}

void _showFeedbackDialog(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: authBloc,
      child: _FeedbackDialog(scaffoldMessenger: scaffoldMessenger),
    ),
  );
}

class _FeedbackDialog extends StatefulWidget {
  final ScaffoldMessengerState scaffoldMessenger;

  const _FeedbackDialog({required this.scaffoldMessenger});

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Please enter your feedback');
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }

      final user = authState.user;
      final feedbackData = {
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Store feedback under user's document: feedbacks/{userId}/suggestions/{autoId}
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(user.id)
          .collection('suggestions')
          .add(feedbackData);

      // Also store user info in the parent document if it doesn't exist
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(user.id)
          .set({
            'userId': user.id,
            'userName': user.name,
            'userEmail': user.email,
            'lastFeedbackAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);

        // Show success snackbar using the passed messenger
        widget.scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Feedback sent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        SnackBarUtils.showError(
          context,
          'Failed to submit feedback: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.message_rounded, color: AppColors.primaryBlue),
          SizedBox(width: 8),
          Text('Send Feedback'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We would love to hear from you! Share your feedback, suggestions, or report issues.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your feedback here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
      content: const Text('Are you sure you want to logout from your account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
