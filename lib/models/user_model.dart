// lib/models/user_model.dart
import 'dart:ui';

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isApproved;
  final bool isActive;
  final DateTime createdAt;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleStatus; // NEW: Add this


  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.isApproved,
    required this.isActive,
    required this.createdAt,
    this.onDelete,
    this.onViewDetails,
    this.onToggleStatus, // NEW: Add this

  });

// lib/models/user_model.dart - Fix the fromJson method
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isApproved: _parseBool(json['is_approved']),
      isActive: _parseBool(json['is_active']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

// Helper methods to handle type conversions
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }}