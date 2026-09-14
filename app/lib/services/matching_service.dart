import '../models/user_model.dart';
import 'discovery_service.dart';

/// Thin compatibility wrapper around [DiscoveryService]. Existing screens were
/// written against this class with mock data; we now translate their calls into
/// real API requests.
class MatchingService {
  static String _swipeAction(SwipeAction action) {
    switch (action) {
      case SwipeAction.like:
        return 'like';
      case SwipeAction.superLike:
        return 'super_like';
      case SwipeAction.pass:
        return 'pass';
    }
  }

  /// Maps the gender list selected in [FilterCriteria] to the backend's
  /// `show_me` enum.
  static String? _showMeFor(List<String> genders) {
    if (genders.isEmpty) return null;
    if (genders.length == 1) {
      switch (genders.first) {
        case 'Man':
          return 'Men';
        case 'Woman':
          return 'Women';
      }
    }
    return 'Everyone';
  }

  /// Fetches the discovery feed.
  static Future<List<UserProfile>> getDiscoveryProfiles({
    FilterCriteria? filters,
  }) async {
    final raw = await DiscoveryService.fetchFeed(
      minAge: filters?.minAge,
      maxAge: filters?.maxAge,
      showMe: filters != null ? _showMeFor(filters.genders) : null,
      interests: (filters?.interests.isNotEmpty ?? false)
          ? filters!.interests
          : null,
      verifiedOnly: filters?.verifiedOnly,
    );
    return raw.map(UserProfile.fromBackend).toList();
  }

  /// Records a swipe. Returns `true` if it produced a mutual match.
  Future<bool> handleSwipe(String userId, SwipeAction action) async {
    final result = await DiscoveryService.swipe(
      targetUserId: int.parse(userId),
      action: _swipeAction(action),
    );
    return (result['is_match'] as bool?) ?? false;
  }

  /// Profiles the user has liked or super-liked.
  Future<List<UserProfile>> getPeopleYouLiked() async {
    final raw = await DiscoveryService.sentLikes();
    return raw
        .where((entry) => entry['profile'] is Map<String, dynamic>)
        .map((entry) => UserProfile.fromBackend(entry['profile'] as Map<String, dynamic>))
        .toList();
  }

  /// Profiles who have liked the user (mutual or not).
  Future<List<UserProfile>> getWhoLikedYou() async {
    final raw = await DiscoveryService.receivedLikes();
    return raw
        .where((entry) => entry['profile'] is Map<String, dynamic>)
        .map((entry) => UserProfile.fromBackend(entry['profile'] as Map<String, dynamic>))
        .toList();
  }

  /// Mutual matches.
  static Future<List<UserProfile>> getMatches() async {
    final raw = await DiscoveryService.matches();
    return raw
        .where((entry) => entry['profile'] is Map<String, dynamic>)
        .map((entry) => UserProfile.fromBackend(entry['profile'] as Map<String, dynamic>))
        .toList();
  }
}
