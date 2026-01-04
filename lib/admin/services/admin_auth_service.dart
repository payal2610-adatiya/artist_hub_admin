// lib/admin/services/admin_auth_service.dart
class AdminAuthService {
  static String? _adminToken;
  static Map<String, dynamic>? _adminData;

  // Save admin session
  static void saveAdminSession(String token, Map<String, dynamic> adminData) {
    _adminToken = token;
    _adminData = adminData;
  }

  // Get admin token
  static String? get adminToken => _adminToken;

  // Get admin data
  static Map<String, dynamic>? get adminData => _adminData;

  // Check if admin is logged in
  static bool get isLoggedIn => _adminToken != null;

  // Logout
  static void logout() {
    _adminToken = null;
    _adminData = null;
  }

  // Get admin name
  static String get adminName => _adminData?['name'] ?? 'Admin';

  // Get admin email
  static String get adminEmail => _adminData?['email'] ?? '';
}