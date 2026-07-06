import 'package:shared_preferences/shared_preferences.dart';

enum VisibilityMode {
  public,      // Visible to everyone
  private,     // Only visible to matches
  invisible,   // Not visible in discovery
}

enum OnlineStatus {
  online,      // Currently online
  offline,     // Offline
  away,        // Away/inactive
  doNotDisturb, // Do not disturb mode
}

class PrivacyService {
  static const String _visibilityKey = 'visibility_mode';
  static const String _onlineStatusKey = 'online_status';
  static const String _lastSeenKey = 'last_seen';
  static const String _showOnlineStatusKey = 'show_online_status';
  static const String _showLastSeenKey = 'show_last_seen';

  // Visibility Mode Management
  static Future<void> setVisibilityMode(VisibilityMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visibilityKey, mode.toString());
  }

  static Future<VisibilityMode> getVisibilityMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_visibilityKey);

    if (modeString == null) return VisibilityMode.public;

    switch (modeString) {
      case 'VisibilityMode.private':
        return VisibilityMode.private;
      case 'VisibilityMode.invisible':
        return VisibilityMode.invisible;
      default:
        return VisibilityMode.public;
    }
  }

  // Online Status Management
  static Future<void> setOnlineStatus(OnlineStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onlineStatusKey, status.toString());

    // Update last seen time when going offline
    if (status == OnlineStatus.offline) {
      await prefs.setInt(_lastSeenKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  static Future<OnlineStatus> getOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(_onlineStatusKey);

    if (statusString == null) return OnlineStatus.online;

    switch (statusString) {
      case 'OnlineStatus.offline':
        return OnlineStatus.offline;
      case 'OnlineStatus.away':
        return OnlineStatus.away;
      case 'OnlineStatus.doNotDisturb':
        return OnlineStatus.doNotDisturb;
      default:
        return OnlineStatus.online;
    }
  }

  // Last Seen Management
  static Future<DateTime?> getLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSeenKey);

    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Privacy Settings
  static Future<void> setShowOnlineStatus(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showOnlineStatusKey, show);
  }

  static Future<bool> getShowOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showOnlineStatusKey) ?? true;
  }

  static Future<void> setShowLastSeen(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showLastSeenKey, show);
  }

  static Future<bool> getShowLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showLastSeenKey) ?? true;
  }

  // Utility Methods
  static String getVisibilityModeDescription(VisibilityMode mode) {
    switch (mode) {
      case VisibilityMode.public:
        return 'Your profile is visible to everyone';
      case VisibilityMode.private:
        return 'Only your matches can see your profile';
      case VisibilityMode.invisible:
        return 'Your profile won\'t appear in discovery';
    }
  }

  static String getOnlineStatusDescription(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return 'Online';
      case OnlineStatus.offline:
        return 'Offline';
      case OnlineStatus.away:
        return 'Away';
      case OnlineStatus.doNotDisturb:
        return 'Do not disturb';
    }
  }

  static String getVisibilityModeTitle(VisibilityMode mode) {
    switch (mode) {
      case VisibilityMode.public:
        return 'Public';
      case VisibilityMode.private:
        return 'Private';
      case VisibilityMode.invisible:
        return 'Invisible';
    }
  }

  static String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Last seen long ago';
    }
  }
}