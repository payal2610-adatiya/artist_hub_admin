// lib/models/dashboard_stats_model.dart
class DashboardStats {
  final int totalArtists;
  final int totalCustomers;
  final int pendingArtists;
  final int totalBookings;
  final int ongoingServices;
  final int upcomingBookings;

  DashboardStats({
    required this.totalArtists,
    required this.totalCustomers,
    required this.pendingArtists,
    required this.totalBookings,
    required this.ongoingServices,
    required this.upcomingBookings,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalArtists: json['total_artists'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      pendingArtists: json['pending_artists'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      ongoingServices: json['ongoing_services'] ?? 0,
      upcomingBookings: json['upcoming_bookings'] ?? 0,
    );
  }

  // Method to create stats from fetched data
  static DashboardStats calculateStats({
    required int artistCount,
    required int customerCount,
    required int pendingArtistCount,
    required int bookingCount,
    required List<dynamic> bookings,
  }) {
    // Calculate ongoing services (bookings with status 'booked' for today or future)
    final ongoingServices = bookings.where((booking) {
      if (booking is Map<String, dynamic>) {
        final status = booking['status'] ?? '';
        final bookingDate = booking['booking_date'] ?? '';
        if (status == 'booked' && bookingDate.isNotEmpty) {
          try {
            final date = DateTime.parse(bookingDate);
            return date.isAtSameMomentAs(DateTime.now()) || date.isAfter(DateTime.now());
          } catch (e) {
            return false;
          }
        }
      }
      return false;
    }).length;

    // Calculate upcoming bookings (future bookings)
    final upcomingBookings = bookings.where((booking) {
      if (booking is Map<String, dynamic>) {
        final bookingDate = booking['booking_date'] ?? '';
        if (bookingDate.isNotEmpty) {
          try {
            final date = DateTime.parse(bookingDate);
            return date.isAfter(DateTime.now());
          } catch (e) {
            return false;
          }
        }
      }
      return false;
    }).length;

    return DashboardStats(
      totalArtists: artistCount,
      totalCustomers: customerCount,
      pendingArtists: pendingArtistCount,
      totalBookings: bookingCount,
      ongoingServices: ongoingServices,
      upcomingBookings: upcomingBookings,
    );
  }
}