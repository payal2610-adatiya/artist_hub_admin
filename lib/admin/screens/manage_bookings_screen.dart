// lib/admin/screens/manage_bookings_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/booking_card.dart';
import '../services/admin_api_service.dart';
import '../../models/booking_model.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({Key? key}) : super(key: key);

  @override
  _ManageBookingsScreenState createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    final bookings = await AdminApiService.getAllBookings();

    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  List<Booking> get _filteredBookings {
    if (_selectedFilter == 'all') return _bookings;
    return _bookings.where((b) => b.status == _selectedFilter).toList();
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Booking ID', '#${booking.id}'),
              _detailRow('Customer', booking.customerName),
              _detailRow('Artist', booking.artistName),
              _detailRow('Date', booking.bookingDate.toString()),
              _detailRow('Event Address', booking.eventAddress),
              _detailRow('Status', booking.status),
              _detailRow('Payment Status', booking.paymentStatus),
              _detailRow('Payment Method', booking.paymentMethod),
              _detailRow('Created', booking.createdAt.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', 'all'),
                    _filterChip('Booked', 'booked'),
                    _filterChip('Pending', 'pending'),
                    _filterChip('Completed', 'completed'),
                    _filterChip('Cancelled', 'cancelled'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = _filteredBookings[index];
                  return BookingCard(
                    customerName: booking.customerName,
                    artistName: booking.artistName,
                    bookingDate: booking.bookingDate,
                    status: booking.status,
                    paymentStatus: booking.paymentStatus,
                    onViewDetails: () => _showBookingDetails(booking),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBookings,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          color: _selectedFilter == value ? Colors.white : AppColors.textColor,
        ),
      ),
    );
  }
}