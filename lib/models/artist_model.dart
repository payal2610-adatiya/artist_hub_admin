// lib/models/artist_model.dart - Updated to match your API structure
class Artist {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isApproved;
  final bool isActive;
  final DateTime createdAt;

  // Profile details (from separate API)
  String? category;
  String? experience;
  double? price;
  String? description;
  double? avgRating;
  int? totalReviews;

  Artist({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.isApproved,
    required this.isActive,
    required this.createdAt,
    this.category,
    this.experience,
    this.price,
    this.description,
    this.avgRating,
    this.totalReviews,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'artist',
      isApproved: (json['is_approved'] ?? 0) == 1,
      isActive: (json['is_active'] ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      avgRating: double.tryParse((json['avg_rating'] ?? 0).toString()) ?? 0.0,
      totalReviews: int.tryParse((json['total_reviews'] ?? 0).toString()) ?? 0,
    );
  }

  // For pending artists
  factory Artist.fromPendingJson(Map<String, dynamic> json) {
    return Artist(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: 'artist',
      isApproved: false,
      isActive: true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  // Method to fetch profile details
  Future<void> fetchProfileDetails() async {
    try {
      // You would call view_artist_profile.php here
      // For now, we'll use the existing data structure
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }
}

