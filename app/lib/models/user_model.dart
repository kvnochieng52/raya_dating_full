class UserProfile {
  final String id;
  /// Full name from the user account (e.g. "Daniel Otieno").
  final String name;
  /// Profile nickname the user set themselves (e.g. "Daniel"). Optional.
  final String? nickname;
  final int age;
  final String bio;
  final List<String> photos;
  final String gender;
  final List<String> interests;
  final String occupation;
  final String education;
  final double latitude;
  final double longitude;
  final DateTime lastSeen;
  final bool isOnline;
  final bool isVerified;
  final double? distanceKm;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.gender,
    required this.interests,
    required this.occupation,
    required this.education,
    required this.latitude,
    required this.longitude,
    required this.lastSeen,
    required this.isOnline,
    required this.isVerified,
    this.nickname,
    this.distanceKm,
  });

  /// Prefer the nickname when set, otherwise fall back to the full name.
  /// All UI surfaces (cards, tiles, chat header) should render this.
  String get displayName {
    final n = nickname?.trim();
    if (n != null && n.isNotEmpty) return n;
    return name;
  }

  /// Builds a profile from the API shape returned by /api/discovery,
  /// /api/likes/* and /api/matches.
  factory UserProfile.fromBackend(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final rawPhotos = (json['photos'] as List?) ?? const [];
    final photoUrls = rawPhotos
        .map((p) => (p as Map<String, dynamic>)['url'])
        .whereType<String>()
        .toList();
    final rawNickname = (json['nickname'] as String?)?.trim();
    final hasNickname = rawNickname != null && rawNickname.isNotEmpty;
    final fullName = (user?['name'] as String?)?.trim() ?? 'Unknown';
    return UserProfile(
      id: (json['user_id'] ?? user?['id']).toString(),
      name: fullName,
      nickname: hasNickname ? rawNickname : null,
      age: (json['age'] as int?) ?? 0,
      bio: (json['bio'] as String?) ?? '',
      photos: photoUrls,
      gender: (json['gender'] as String?) ?? '',
      interests: ((json['interests'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      occupation: (json['occupation'] as String?) ?? '',
      education: (json['education_level'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      lastSeen: DateTime.now(),
      isOnline: false,
      isVerified: (json['email_verified'] == true) ||
          (json['phone_verified'] == true) ||
          (json['selfie_uploaded'] == true),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  double distanceFrom(double lat, double lng) {
    if (distanceKm != null) return distanceKm!;
    final latDiff = latitude - lat;
    final lngDiff = longitude - lng;
    return (latDiff * latDiff + lngDiff * lngDiff) * 111;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'photos': photos,
      'gender': gender,
      'interests': interests,
      'occupation': occupation,
      'education': education,
      'latitude': latitude,
      'longitude': longitude,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'isVerified': isVerified,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      bio: json['bio'],
      photos: List<String>.from(json['photos']),
      gender: json['gender'],
      interests: List<String>.from(json['interests']),
      occupation: json['occupation'],
      education: json['education'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastSeen: DateTime.parse(json['lastSeen']),
      isOnline: json['isOnline'],
      isVerified: json['isVerified'],
    );
  }
}

class MatchData {
  final String userId;
  final String matchedUserId;
  final DateTime matchedAt;
  final bool isLiked;
  final bool isMatched; // Both users liked each other

  MatchData({
    required this.userId,
    required this.matchedUserId,
    required this.matchedAt,
    required this.isLiked,
    required this.isMatched,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'matchedUserId': matchedUserId,
      'matchedAt': matchedAt.toIso8601String(),
      'isLiked': isLiked,
      'isMatched': isMatched,
    };
  }

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      userId: json['userId'],
      matchedUserId: json['matchedUserId'],
      matchedAt: DateTime.parse(json['matchedAt']),
      isLiked: json['isLiked'],
      isMatched: json['isMatched'],
    );
  }
}

enum SwipeAction {
  like,
  pass,
  superLike,
}

class FilterCriteria {
  final int minAge;
  final int maxAge;
  final double maxDistance;
  final List<String> genders;
  final List<String> interests;
  final bool onlineOnly;
  final bool verifiedOnly;

  FilterCriteria({
    this.minAge = 18,
    this.maxAge = 100,
    this.maxDistance = 100,
    this.genders = const [],
    this.interests = const [],
    this.onlineOnly = false,
    this.verifiedOnly = false,
  });

  bool matches(UserProfile user, double userLat, double userLng) {
    // Age filter
    if (user.age < minAge || user.age > maxAge) return false;

    // Gender filter
    if (genders.isNotEmpty && !genders.contains(user.gender)) return false;

    // Distance filter
    if (user.distanceFrom(userLat, userLng) > maxDistance) return false;

    // Online filter
    if (onlineOnly && !user.isOnline) return false;

    // Verified filter
    if (verifiedOnly && !user.isVerified) return false;

    // Interest filter
    if (interests.isNotEmpty) {
      final hasCommonInterest = user.interests.any((interest) => interests.contains(interest));
      if (!hasCommonInterest) return false;
    }

    return true;
  }
}