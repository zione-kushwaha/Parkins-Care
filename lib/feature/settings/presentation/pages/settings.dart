import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

import '/core/utils/status_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return StatusOverlay.statusBarOverlay(
      context: context,
      child: CustomScrollView(
        slivers: [
          // Settings Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Appearance Section
                _buildSectionHeader('Appearance'),
                _buildThemeToggle(),
                const Divider(height: 1),

                const SizedBox(height: 20),

                // Notifications Section
                _buildSectionHeader('Notifications'),
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications for new answers',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound',
                  subtitle: 'Play sound for notifications',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),

                const SizedBox(height: 20),

                // Language & Region
                _buildSectionHeader('Language & Region'),
                _buildTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  onTap: () => _showLanguageDialog(),
                ),
                const Divider(height: 1),

                const SizedBox(height: 20),

                // Data & Storage
                _buildSectionHeader('Data & Storage'),

                const Divider(height: 1, indent: 72),
                _buildTile(
                  icon: Icons.delete_outline,
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  onTap: () => _showClearCacheDialog(),
                ),
                const Divider(height: 1),

                const SizedBox(height: 20),

                // About Section
                _buildSectionHeader('About'),
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
                const Divider(height: 1, indent: 72),
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _launchURL('https://yourprivacypolicy.com'),
                ),
                const Divider(height: 1, indent: 72),
                _buildTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _launchURL('https://yourterms.com'),
                ),
                const Divider(height: 1, indent: 72),
                _buildTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  onTap: () => _launchURL('mailto:support@yourapp.com'),
                ),
                const Divider(height: 1),

                const SizedBox(height: 20),

                // Danger Zone
                _buildSectionHeader('Account', color: Colors.red),
                _buildTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  titleColor: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 40),

                // Footer
                Text(
                  'Parkin Care © 2025',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Make your life easier with Parkin Care',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color ?? AppColors.primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;

        return Container(
          color: Theme.of(context).cardColor,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primaryBlue,
              ),
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              isDarkMode ? 'Enabled' : 'Disabled',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeBloc>().add(ThemeToggled());
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
            onTap: () {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (titleColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: titleColor ?? AppColors.primaryBlue),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildLanguageOption('English')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,

      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppColors.primaryBlue,
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data and free up storage space. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Parkin Care',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, color: Colors.white, size: 40),
      ),
      children: [
        const Text(
          'Parkin Care is an app designed to help students manage their learning journey efficiently and enjoyably.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Developed with ❤️ for people',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
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
        content: const Text(
          'Are you sure you want to logout from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // context.read<AuthBloc>().add(SignOut());
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }
}
