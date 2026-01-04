// lib/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/dashboard_stats_model.dart';
import '../../utils/app_colors.dart';
import '../services/admin_api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_profile_screen.dart';
import 'manage_artists_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardContent(),
    const ManageArtistsScreen(),
    const ManageUsersScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Artist Hub Admin'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: AdminBottomNavigation(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Update the DashboardContent class in admin_dashboard_screen.dart
class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  DashboardStats _stats = DashboardStats(
    totalArtists: 0,
    totalCustomers: 0,
    pendingArtists: 0,
    totalBookings: 0,
    ongoingServices: 0,
    upcomingBookings: 0,
  );

  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final stats = await AdminApiService.getDashboardStats();
      final activities = await AdminApiService.getRecentActivities();

      setState(() {
        _stats = stats;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hello, Admin! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Artist Hub Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 40),
              const Center(child: CircularProgressIndicator()),
            ] else if (_hasError) ...[
              const SizedBox(height: 40),
              Column(
                children: [
                  Icon(Icons.error, size: 64, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load dashboard data',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 30),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Total Artists',
                    value: _stats.totalArtists.toString(),
                    icon: Icons.people,
                    color: AppColors.primaryColor,
                  ),
                  StatCard(
                    title: 'Total Customers',
                    value: _stats.totalCustomers.toString(),
                    icon: Icons.group,
                    color: AppColors.successColor,
                  ),
                  StatCard(
                    title: 'Pending Artists',
                    value: _stats.pendingArtists.toString(),
                    icon: Icons.pending,
                    color: AppColors.warningColor,
                  ),
                  StatCard(
                    title: 'Total Bookings',
                    value: _stats.totalBookings.toString(),
                    icon: Icons.event_note,
                    color: AppColors.gold,
                  ),
                  StatCard(
                    title: 'Ongoing Services',
                    value: _stats.ongoingServices.toString(),
                    icon: Icons.work,
                    color: AppColors.secondaryColor,
                  ),
                  StatCard(
                    title: 'Upcoming Bookings',
                    value: _stats.upcomingBookings.toString(),
                    icon: Icons.upcoming,
                    color: AppColors.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: _recentActivities.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No recent activities'),
                  ),
                )
                    : Column(
                  children: _recentActivities.map((activity) {
                    return _activityItem(
                      activity['title'],
                      activity['description'],
                      activity['time'],
                      _getIcon(activity['icon']),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityItem(String title, String description, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'event':
        return Icons.event;
      case 'update':
        return Icons.update;
      case 'add_circle':
        return Icons.add_circle;
      case 'power':
        return Icons.power;
      case 'waving_hand':
        return Icons.waving_hand;
      default:
        return Icons.notifications;
    }
  }
}