import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/community_entities.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Doctor> _doctors = [
    Doctor(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialization: 'Neurologist - Parkinson\'s Specialist',
      phoneNumber: '+1 (555) 123-4567',
      email: 'dr.johnson@healthcare.com',
      location: 'New York Medical Center',
      rating: 4.8,
      experience: 15,
      availability: 'Mon-Fri, 9AM-5PM',
      isAvailable: true,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Michael Chen',
      specialization: 'Movement Disorder Specialist',
      phoneNumber: '+1 (555) 234-5678',
      email: 'dr.chen@healthcare.com',
      location: 'Boston Neurology Clinic',
      rating: 4.9,
      experience: 20,
      availability: 'Tue-Sat, 10AM-6PM',
      isAvailable: true,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Emily Rodriguez',
      specialization: 'Neurophysiologist',
      phoneNumber: '+1 (555) 345-6789',
      email: 'dr.rodriguez@healthcare.com',
      location: 'LA Health Institute',
      rating: 4.7,
      experience: 12,
      availability: 'Mon-Thu, 8AM-4PM',
      isAvailable: false,
    ),
    Doctor(
      id: '4',
      name: 'Dr. James Wilson',
      specialization: 'Geriatric Neurologist',
      phoneNumber: '+1 (555) 456-7890',
      email: 'dr.wilson@healthcare.com',
      location: 'Chicago Senior Care',
      rating: 4.6,
      experience: 18,
      availability: 'Wed-Sun, 11AM-7PM',
      isAvailable: true,
    ),
  ];

  final List<SupportGroup> _supportGroups = [
    SupportGroup(
      id: '1',
      name: 'Early Stage Parkinson\'s Support',
      description: 'A group for newly diagnosed individuals and their families',
      members: 45,
      category: 'Support',
      meetingTime: 'Every Tuesday, 6PM',
    ),
    SupportGroup(
      id: '2',
      name: 'Caregivers Connect',
      description: 'Support and resources for Parkinson\'s caregivers',
      members: 67,
      category: 'Caregiving',
      meetingTime: 'First Monday of month, 7PM',
    ),
    SupportGroup(
      id: '3',
      name: 'Exercise & Movement',
      description: 'Group exercise sessions tailored for Parkinson\'s',
      members: 89,
      category: 'Exercise',
      meetingTime: 'Mon, Wed, Fri, 9AM',
    ),
  ];

  final List<CommunityPost> _recentPosts = [
    CommunityPost(
      id: '1',
      authorId: 'user1',
      authorName: 'John D.',
      authorImage: '',
      content:
          'Just wanted to share my experience with the new tremor tracking feature. It\'s been really helpful in monitoring my symptoms!',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      likes: 23,
      comments: 5,
      tags: ['tremor', 'tracking'],
    ),
    CommunityPost(
      id: '2',
      authorId: 'user2',
      authorName: 'Maria S.',
      authorImage: '',
      content:
          'Does anyone have tips for managing medication side effects? Looking for advice.',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      likes: 15,
      comments: 12,
      tags: ['medication', 'advice'],
    ),
  ];

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

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.people, color: Colors.white, size: 26),
            SizedBox(width: 12),
            Text(
              'Community',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Doctors'),
            Tab(text: 'Support Groups'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsTab(theme, isDark),
          _buildSupportGroupsTab(theme, isDark),
          _buildCommunityTab(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.1),
                AppColors.primaryBlue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connect with Parkinson\'s specialists',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ..._doctors.map((doctor) => _buildDoctorCard(doctor, theme, isDark)),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor, ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, Colors.blue.shade300],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (doctor.isAvailable)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, doctor.location, theme.textTheme),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              doctor.availability,
              theme.textTheme,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text(
                  '${doctor.rating}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.work_outline,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  '${doctor.experience} years exp',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(doctor.phoneNumber),
                    icon: Icon(Icons.phone, size: 18),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendEmail(doctor.email),
                    icon: Icon(Icons.email, size: 18),
                    label: Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportGroupsTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.1),
                Colors.purple.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.groups, color: Colors.purple, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Join support groups and connect with others',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ..._supportGroups.map(
          (group) => _buildSupportGroupCard(group, theme, isDark),
        ),
      ],
    );
  }

  Widget _buildSupportGroupCard(
    SupportGroup group,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.groups, color: Colors.purple, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${group.members} members',
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
            SizedBox(height: 12),
            Text(
              group.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                SizedBox(width: 8),
                Text(
                  group.meetingTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request sent to join ${group.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Join Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.orange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.forum, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Share experiences and get support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ..._recentPosts.map((post) => _buildPostCard(post, theme, isDark)),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post, ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  child: Text(
                    post.authorName[0],
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        _getTimeAgo(post.timestamp),
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
            SizedBox(height: 12),
            Text(
              post.content,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
            if (post.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: post.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag', style: TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.thumb_up_outlined, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 4),
                Text('${post.likes}'),
                SizedBox(width: 24),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.comment_outlined, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 4),
                Text('${post.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
