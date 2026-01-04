// lib/admin/screens/manage_artists_screen.dart - Fixed version
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../widgets/artist_card.dart';
import '../services/admin_api_service.dart';
import '../../models/artist_model.dart';

class ManageArtistsScreen extends StatefulWidget {
  const ManageArtistsScreen({Key? key}) : super(key: key);

  @override
  _ManageArtistsScreenState createState() => _ManageArtistsScreenState();
}

class _ManageArtistsScreenState extends State<ManageArtistsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Artist> _approvedArtists = [];
  List<Artist> _pendingArtists = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    setState(() => _isLoading = true);

    try {
      final [approved, pending] = await Future.wait([
        AdminApiService.getAllArtists(),
        AdminApiService.getPendingArtists(),
      ]);

      setState(() {
        _approvedArtists = approved;
        _pendingArtists = pending;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading artists: $e');
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load artists');
    }
  }

  // ADD THIS MISSING METHOD
  Future<void> _approveArtist(int artistId) async {
    // Show confirmation dialog
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

    // Show loading
    setState(() => _isLoading = true);

    try {
      final response = await AdminApiService.approveArtist(artistId);

      setState(() => _isLoading = false);

      if (response.status) {
        _showSuccessSnackbar(response.message);
        await _loadArtists(); // Refresh the list
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
    }
  }

  Future<void> _deleteArtist(int artistId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artist'),
        content: const Text('Are you sure you want to delete this artist? This action cannot be undone.'),
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

      final response = await AdminApiService.deleteArtist(artistId);

      setState(() => _isLoading = false);

      if (response.status == true) {
        _showSuccessSnackbar(response.message ?? 'Artist deleted successfully');
        _loadArtists(); // Refresh the list
      } else {
        _showErrorSnackbar(response.message ?? 'Failed to delete artist');
      }
    }
  }

  void _showArtistDetails(Artist artist) async {
    // Show loading
    setState(() => _isLoading = true);

    final detailedArtist = await AdminApiService.getArtistDetails(artist.id);

    setState(() => _isLoading = false);

    final artistToShow = detailedArtist ?? artist;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(artistToShow.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailItem('Email', artistToShow.email),
              _detailItem('Phone', artistToShow.phone),
              _detailItem('Address', artistToShow.address),
              if (artistToShow.category != null)
                _detailItem('Category', artistToShow.category!),
              if (artistToShow.experience != null)
                _detailItem('Experience', artistToShow.experience!),
              if (artistToShow.price != null && artistToShow.price! > 0)
                _detailItem('Price', Helpers.formatCurrency(artistToShow.price!)),
              if (artistToShow.description != null && artistToShow.description!.isNotEmpty)
                _detailItem('Description', artistToShow.description!),
              _detailItem('Rating', '${artistToShow.avgRating?.toStringAsFixed(1) ?? '0.0'} ⭐ (${artistToShow.totalReviews ?? 0} reviews)'),
              _detailItem('Status', artistToShow.isApproved ? 'Approved' : 'Pending'),
              _detailItem('Active', artistToShow.isActive ? 'Yes' : 'No'),
              _detailItem('Joined', Helpers.formatDate(artistToShow.createdAt)),
            ],
          ),
        ),
        actions: [
          if (!artistToShow.isApproved)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _approveArtist(artistToShow.id); // FIXED: Changed approveArtist to _approveArtist
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successColor),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.darkGrey)),
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

  List<Artist> _getFilteredArtists(List<Artist> artists, bool isPending) {
    var filtered = artists.where((artist) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          artist.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          artist.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          artist.phone.contains(_searchQuery) ||
          (artist.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      // Category filter (for approved artists only)
      if (!isPending && _selectedCategory != 'All') {
        return matchesSearch && (artist.category ?? '') == _selectedCategory;
      }

      return matchesSearch;
    }).toList();

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  List<String> _getCategories() {
    final categories = _approvedArtists
        .map((a) => a.category ?? 'Uncategorized')
        .where((c) => c.isNotEmpty && c != 'Not specified')
        .toSet()
        .toList();

    categories.sort();
    return ['All', ...categories];
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
                decoration: InputDecoration(
                  hintText: 'Search artists...',
                  prefixIcon: Icon(Icons.search, color: AppColors.grey),
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
          if (_tabController.index == 0 && _getCategories().length > 1) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              itemBuilder: (context) => _getCategories().map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
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
                      _selectedCategory,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.grey),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Artists'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white,
          onTap: (index) {
            setState(() {
              _searchQuery = '';
              _selectedCategory = 'All';
            });
          },
          tabs: const [
            Tab(text: 'Approved Artists',),
            Tab(text: 'Pending Approval'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                // Approved Artists Tab
                _approvedArtists.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, size: 64, color: AppColors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No approved artists found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadArtists,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getFilteredArtists(_approvedArtists, false).length,
                    itemBuilder: (context, index) {
                      final artist = _getFilteredArtists(_approvedArtists, false)[index];
                      return ArtistCard(
                        name: artist.name,
                        category: artist.category ?? 'Not specified',
                        rating: artist.avgRating ?? 0.0,
                        earnings: artist.price ?? 0.0,
                        isPending: false,
                        onViewDetails: () => _showArtistDetails(artist),
                        onDelete: () => _deleteArtist(artist.id),
                      );
                    },
                  ),
                ),

                // Pending Artists Tab
                _pendingArtists.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pending, size: 64, color: AppColors.primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'No pending artists found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadArtists,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getFilteredArtists(_pendingArtists, true).length,
                    itemBuilder: (context, index) {
                      final artist = _getFilteredArtists(_pendingArtists, true)[index];
                      return ArtistCard(
                        name: artist.name,
                        category: 'Pending Approval',
                        rating: 0.0,
                        earnings: 0.0,
                        isPending: true,
                        onApprove: () => _approveArtist(artist.id),
                        onViewDetails: () => _showArtistDetails(artist),
                        onDelete: () => _deleteArtist(artist.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}