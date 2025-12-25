import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkins_care/feature/reminders/presentation/pages/reminder.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../settings/presentation/pages/settings.dart';
import '../../../tremor/presentation/bloc/tremor_bloc.dart';
import '../../../tremor/presentation/bloc/tremor_event.dart';
import '../../../tremor/presentation/bloc/tremor_state.dart' show TremorState, EmergencyContactsLoaded;
import '../../../tremor/presentation/pages/tremor_monitor_page.dart';
import 'home_page_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isEmergencyMode = false;

  List<Widget> get _pages => [
    DashboardPage(onEmergencyPressed: _toggleEmergencyMode),
   ReminderPage(),
    const NotificationsPage(),
    _buildPageWithAppBar('Settings', Icons.settings, const SettingsPage()),
  ];

  final List<IconData> _iconList = [
    Icons.dashboard,
    Icons.remember_me,
    Icons.notifications,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Load emergency contacts and start tremor monitoring when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TremorBloc>().add(LoadEmergencyContacts());
      // Auto-start tremor monitoring in background
      context.read<TremorBloc>().add(StartTremorMonitoring());
    });
  }

  void _toggleEmergencyMode() {
    setState(() {
      _isEmergencyMode = !_isEmergencyMode;
    });

    if (_isEmergencyMode) {
      _showEmergencyOptions();
    }
  }

  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EmergencyOptionsSheet(
        onClose: () {
          setState(() {
            _isEmergencyMode = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    // Keep tremor monitoring running even when home screen disposes
    // Only stop when app is actually closed
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageWithAppBar(String title, IconData icon, Widget content) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark ? Colors.black : AppColors.primaryBlue,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _isEmergencyMode
          ? AppBar(
              backgroundColor: Colors.red[700],
              elevation: 4,
              title: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'EMERGENCY MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isEmergencyMode = false;
                    });
                  },
                ),
              ],
            )
          : null,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isEmergencyMode
            ? Colors.red[700]
            : AppColors.primaryBlue,
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: _isEmergencyMode
            ? _showEmergencyOptions
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TremorMonitorPage(),
                  ),
                );
              },
        child: Icon(
          _isEmergencyMode ? Icons.emergency : Icons.monitor_heart,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        notchSmoothness: NotchSmoothness.softEdge,
        backgroundColor: isDark ? Colors.grey[900] : AppColors.primaryBlue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}

class _EmergencyOptionsSheet extends StatelessWidget {
  final VoidCallback onClose;

  const _EmergencyOptionsSheet({required this.onClose});



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.emergency, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'EMERGENCY OPTIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Emergency Services Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _EmergencyOptionCard(
              icon: Icons.local_hospital,
              title: 'Emergency Services',
              subtitle: 'Video Call - Meeting ID: 888',
              onTap: (){}
            ),
          ),

          // Emergency Contacts from Tremor Feature
          BlocBuilder<TremorBloc, TremorState>(
            builder: (context, state) {
              if (state is EmergencyContactsLoaded &&
                  state.contacts.isNotEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Emergency Contacts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ...state.contacts.map(
                      (contact) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: _EmergencyOptionCard(
                          icon: contact.isPrimary ? Icons.star : Icons.person,
                          title: contact.name,
                          subtitle:
                              '${contact.relationship} - Video Call (888)',
                          onTap: (){

                          },
                          isPrimary: contact.isPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),

          // Manage Contacts Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _EmergencyOptionCard(
              icon: Icons.contacts,
              title: 'Manage Emergency Contacts',
              subtitle: 'Add or edit contacts',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TremorMonitorPage()),
                );
              },
              isOutlined: true,
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EmergencyOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isOutlined;

  const _EmergencyOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : (isPrimary ? Colors.yellow[700] : Colors.white),
          border: isOutlined ? Border.all(color: Colors.white, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOutlined
                    ? Colors.white.withOpacity(0.2)
                    : Colors.red[700]?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isOutlined ? Colors.white : Colors.red[700],
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOutlined ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isOutlined
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isOutlined ? Colors.white : Colors.black38,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
