// lib/utils/helpers.dart
import 'package:intl/intl.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  // Format currency
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Get status color
  static int getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0xFFFFA000; // Amber
      case 'approved':
      case 'completed':
      case 'paid':
        return 0xFF388E3C; // Green
      case 'rejected':
      case 'cancelled':
        return 0xFFD32F2F; // Red
      default:
        return 0xFF616161; // Grey
    }
  }
}