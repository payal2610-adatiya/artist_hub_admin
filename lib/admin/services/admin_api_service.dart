// lib/admin/services/admin_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/api_response_model.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/artist_model.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class AdminApiService {
  static const String baseUrl = Constants.apiBaseUrl; // Your API base URL
  static Future<List<Artist>> getPendingArtists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/artist_pending_request.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] is List) {
          return data['data'].map<Artist>((item) => Artist.fromPendingJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching pending artists: $e');
      return [];
    }
  }


  static Future<DashboardStats> getDashboardStats() async {
    try {
      // Fetch all data in parallel
      final responses = await Future.wait([
        // Get all approved artists
        http.get(Uri.parse('$baseUrl/view_artist.php')),
        // Get all customers
        http.get(Uri.parse('$baseUrl/view_customer.php')),
        // Get pending artists
        http.get(Uri.parse('$baseUrl/artist_pending_request.php')),
        // Get all bookings
        http.get(Uri.parse('$baseUrl/view_booking_by_admin.php')),
      ]);

      // Process responses
      int totalArtists = 0;
      int totalCustomers = 0;
      int pendingArtists = 0;
      List<dynamic> bookings = [];

      // Process artists response
      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        if (data['status'] == true) {
          totalArtists = (data['data'] as List).length;
        }
      }

      // Process customers response
      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body);
        if (data['status'] == true) {
          totalCustomers = (data['data'] as List).length;
        }
      }

      // Process pending artists response
      if (responses[2].statusCode == 200) {
        final data = json.decode(responses[2].body);
        if (data['status'] == true) {
          pendingArtists = (data['data'] as List).length;
        }
      }

      // Process bookings response
      if (responses[3].statusCode == 200) {
        final data = json.decode(responses[3].body);
        if (data['status'] == true) {
          bookings = data['data'];
        }
      }

      final totalBookings = bookings.length;

      // Calculate and return stats
      return DashboardStats.calculateStats(
        artistCount: totalArtists,
        customerCount: totalCustomers,
        pendingArtistCount: pendingArtists,
        bookingCount: totalBookings,
        bookings: bookings,
      );

    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return DashboardStats(
        totalArtists: 0,
        totalCustomers: 0,
        pendingArtists: 0,
        totalBookings: 0,
        ongoingServices: 0,
        upcomingBookings: 0,
      );
    }
  }

  // Admin Login
  static Future<ApiResponse> adminLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        return ApiResponse(
          status: false,
          message: 'Server error: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Connection error: $e',
        data: null,
      );
    }
  }

  // Approve Artist
  static Future<ApiResponse> approveArtist(int artistId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/artist_aproval.php'),
        body: {'artist_id': artistId.toString()},
      );

      return ApiResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }

  // Get Dashboard Stats

  // Get Artist Details with Profile
  static Future<Artist?> getArtistDetails(int artistId) async {
    try {
      // Get basic artist info
      final artistResponse = await http.get(
          Uri.parse('$baseUrl/artist_details.php?artist_id=$artistId')
      );

      if (artistResponse.statusCode == 200) {
        final data = json.decode(artistResponse.body);
        if (data['status'] == true) {
          final artist = Artist.fromJson(data['data']);

          // Get profile details
          final profileResponse = await http.get(
              Uri.parse('$baseUrl/view_artist_profile.php?user_id=$artistId')
          );

          if (profileResponse.statusCode == 200) {
            final profileData = json.decode(profileResponse.body);
            if (profileData['status'] == true && profileData['data'] is List && profileData['data'].isNotEmpty) {
              final profile = profileData['data'][0];
              artist.category = profile['category'] ?? 'Not specified';
              artist.experience = profile['experience'] ?? '';
              artist.price = double.tryParse((profile['price'] ?? 0).toString()) ?? 0.0;
              artist.description = profile['description'] ?? '';
            }
          }

          return artist;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching artist details: $e');
      return null;
    }
  }


  // Get All Artists
  static Future<List<Artist>> getAllArtists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view_artist.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final List<Artist> artists = [];

          for (var item in data['data']) {
            final artist = Artist.fromJson(item);

            // Try to fetch profile details for each artist
            try {
              final profileResponse = await http.get(
                  Uri.parse('$baseUrl/view_artist_profile.php?user_id=${artist.id}')
              );

              if (profileResponse.statusCode == 200) {
                final profileData = json.decode(profileResponse.body);
                if (profileData['status'] == true && profileData['data'] is List && profileData['data'].isNotEmpty) {
                  final profile = profileData['data'][0];
                  artist.category = profile['category'] ?? 'Not specified';
                  artist.experience = profile['experience'] ?? '';
                  artist.price = double.tryParse((profile['price'] ?? 0).toString()) ?? 0.0;
                  artist.description = profile['description'] ?? '';
                }
              }
            } catch (e) {
              print('Error fetching profile for artist ${artist.id}: $e');
            }

            artists.add(artist);
          }

          return artists;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching artists: $e');
      return [];
    }
  }
  // Get Pending Artists

  // Get All Bookings
  static Future<List<Booking>> getAllBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view_booking_by_admin.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> bookingsJson = data['data'];
          return bookingsJson.map((json) => Booking.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Get All Users
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view_user.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> usersJson = data['data'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Delete User
  static Future<ApiResponse> deleteUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user.php'),
        body: {'id': userId.toString()},
      );

      return ApiResponse.fromJson(json.decode(response.body));
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }
  static Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/view_artist.php')),
        http.get(Uri.parse('$baseUrl/view_booking_by_admin.php')),
      ]);

      final List<Map<String, dynamic>> activities = [];

      // Process artists for recent registrations
      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        if (data['status'] == true) {
          final artists = data['data'] as List;
          if (artists.isNotEmpty) {
            // Get the most recent artist
            final recentArtist = artists.first;
            activities.add({
              'title': 'New artist registration',
              'description': '${recentArtist['name']} joined',
              'time': _formatTimeAgo(recentArtist['created_at']),
              'icon': 'person_add',
            });
          }
        }
      }

      // Process bookings for recent activities
      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body);
        if (data['status'] == true) {
          final bookings = data['data'] as List;
          if (bookings.isNotEmpty) {
            // Get the most recent booking
            final recentBooking = bookings.first;
            activities.add({
              'title': 'New booking',
              'description': '${recentBooking['customer_name']} booked ${recentBooking['artist_name']}',
              'time': _formatTimeAgo(recentBooking['created_at']),
              'icon': 'event',
            });
          }
        }
      }

      // Add some default activities if none found
      if (activities.length < 4) {
        final defaultActivities = [
          {
            'title': 'System updated',
            'description': 'Admin panel updated to v2.0',
            'time': '1 day ago',
            'icon': 'update',
          },
          {
            'title': 'New feature added',
            'description': 'User management module added',
            'time': '2 days ago',
            'icon': 'add_circle',
          },
        ];
        activities.addAll(defaultActivities);
      }

      return activities.take(4).toList();

    } catch (e) {
      print('Error fetching recent activities: $e');
      return [
        {
          'title': 'System started',
          'description': 'Admin panel initialized',
          'time': 'Just now',
          'icon': 'power',
        },
        {
          'title': 'Welcome',
          'description': 'Welcome to Artist Hub Admin',
          'time': 'Just now',
          'icon': 'waving_hand',
        },
      ];
    }
  }
  static String _formatTimeAgo(String? dateTime) {
    if (dateTime == null) return 'Recently';

    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
      if (difference.inHours < 24) return '${difference.inHours} hours ago';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} months ago';
      return '${(difference.inDays / 365).floor()} years ago';
    } catch (e) {
      return 'Recently';
    }
  }

  // Delete Artist
  static Future<ApiResponse> deleteArtist(int artistId) async {
    try {
      // First try to delete artist profile if exists
      await http.post(
        Uri.parse('$baseUrl/delete_artist_profile.php'),
        body: {'id': artistId.toString()},
      );

      // Then delete the user
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user.php'),
        body: {'id': artistId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          status: data['status'] ?? false,
          message: data['message'] ?? 'Artist deleted successfully',
          data: data['data'],
        );
      }

      return ApiResponse(
        status: false,
        message: 'Server error: ${response.statusCode}',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Connection error: $e',
        data: null,
      );
    }
  }
}


