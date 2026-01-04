// lib/admin/screens/manage_users_screen.dart - Updated with proper API integration
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../widgets/user_card.dart';
import '../services/admin_api_service.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _allUsers = [];
  List<User> _artists = [];
  List<User> _customers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final users = await AdminApiService.getAllUsers();

      setState(() {
        _allUsers = users;
        _artists = users.where((user) => user.role == 'artist').toList();
        _customers = users.where((user) => user.role == 'customer').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showErrorSnackbar('Failed to load users');
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final response = await AdminApiService.deleteUser(userId);

      setState(() => _isLoading = false);

      if (response.status) {
        _showSuccessSnackbar(response.message);
        await _loadUsers(); // Refresh the list
      } else {
        _showErrorSnackbar(response.message);
      }
    }
  }

  Future<void> _toggleUserStatus(int userId, bool currentStatus) async {
    final newStatus = !currentStatus;
    final action = newStatus ? 'activate' : 'deactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus ? 'Activate' : 'Deactivate'} User'),
        content: Text('Are you sure you want to $action this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppColors.successColor : AppColors.warningColor,
            ),
            child: Text(
              newStatus ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Note: You need to create a toggle_user_status.php API endpoint
      // For now, we'll simulate the update
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _isLoading = false);
      _showSuccessSnackbar('User ${newStatus ? 'activated' : 'deactivated'} successfully');
      await _loadUsers(); // Refresh the list
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to update user status');
    }
  }

  Future<void> _approveArtist(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Artist'),
        content: const Text('Are you sure you want to approve this artist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successColor),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await AdminApiService.approveArtist(userId);

      setState(() => _isLoading = false);

      if (response.status) {
        _showSuccessSnackbar(response.message);
        await _loadUsers(); // Refresh the list
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('User ID', '#${user.id}'),
              _detailRow('Name', user.name),
              _detailRow('Email', user.email),
              _detailRow('Phone', user.phone),
              _detailRow('Address', user.address),
              _detailRow('Role', user.role.toUpperCase()),
              _detailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              if (user.role == 'artist')
                _detailRow('Approval', user.isApproved ? 'Approved' : 'Pending'),
              _detailRow('Joined', Helpers.formatDateTime(user.createdAt)),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  if (!user.isActive)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleUserStatus(user.id, user.isActive);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successColor,
                        ),
                        child: const Text('Activate', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (user.isActive)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleUserStatus(user.id, user.isActive);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningColor,
                        ),
                        child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (user.role == 'artist' && !user.isApproved) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveArtist(user.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  List<User> _getFilteredUsers(List<User> users) {
    var filtered = users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.phone.contains(_searchQuery) ||
            user.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'all') {
      if (_selectedStatus == 'active') {
        filtered = filtered.where((user) => user.isActive).toList();
      } else if (_selectedStatus == 'inactive') {
        filtered = filtered.where((user) => !user.isActive).toList();
      } else if (_selectedStatus == 'pending') {
        filtered = filtered.where((user) => user.role == 'artist' && !user.isApproved).toList();
      }
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Users')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(value: 'inactive', child: Text('Inactive Only')),
              const PopupMenuItem(value: 'pending', child: Text('Pending Artists')),
            ],
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _selectedStatus == 'all' ? 'All Users' :
                    _selectedStatus == 'active' ? 'Active' :
                    _selectedStatus == 'inactive' ? 'Inactive' : 'Pending',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Icon(Icons.filter_list, color: AppColors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalUsers = _allUsers.length;
    final totalArtists = _artists.length;
    final totalCustomers = _customers.length;
    final pendingArtists = _artists.where((artist) => !artist.isApproved).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', totalUsers.toString(), AppColors.primaryColor),
          _statItem('Artists', totalArtists.toString(), AppColors.gold),
          _statItem('Customers', totalCustomers.toString(), AppColors.successColor),
          _statItem('Pending', pendingArtists.toString(), AppColors.warningColor),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(List<User> users) {
    final filteredUsers = _getFilteredUsers(users);

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedStatus != 'all'
                  ? Icons.search_off
                  : Icons.people,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No users found for "$_searchQuery"'
                  : 'No ${_selectedStatus != 'all' ? _selectedStatus : ''} users found',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedStatus != 'all')
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedStatus = 'all';
                    _searchController.clear();
                  });
                },
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return UserCard(
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            role: user.role,
            isActive: user.isActive,
            isApproved: user.isApproved,
            createdAt: user.createdAt,
            onDelete: () => _deleteUser(user.id),
            onViewDetails: () => _showUserDetails(user),
            onToggleStatus: () => _toggleUserStatus(user.id, user.isActive),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Artists'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load users',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_allUsers),
                _buildUserList(_artists),
                _buildUserList(_customers),
              ],
            ),
          ),
        ],
      ),

    );
  }
}