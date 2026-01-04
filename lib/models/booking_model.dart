// lib/models/booking_model.dart
class Booking {
  final int id;
  final int customerId;
  final int artistId;
  final String customerName;
  final String artistName;
  final DateTime bookingDate;
  final String eventAddress;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.artistId,
    required this.customerName,
    required this.artistName,
    required this.bookingDate,
    required this.eventAddress,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['booking_id'] ?? json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      artistId: json['artist_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      artistName: json['artist_name'] ?? '',
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toString()),
      eventAddress: json['event_address'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}