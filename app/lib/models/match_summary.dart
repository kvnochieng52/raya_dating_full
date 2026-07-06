import 'user_model.dart';

class LastMessagePreview {
  LastMessagePreview({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.isMine,
  });

  final int id;
  final int senderId;
  final String body;
  final DateTime createdAt;
  final bool isMine;

  factory LastMessagePreview.fromJson(Map<String, dynamic> json) =>
      LastMessagePreview(
        id: json['id'] as int,
        senderId: json['sender_id'] as int,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isMine: (json['is_mine'] as bool?) ?? false,
      );
}

class MatchSummary {
  MatchSummary({
    required this.matchId,
    required this.matchedAt,
    required this.lastActivityAt,
    required this.partner,
    required this.unreadCount,
    this.lastMessage,
  });

  final int matchId;
  final DateTime matchedAt;
  final DateTime lastActivityAt;
  final UserProfile partner;
  final LastMessagePreview? lastMessage;
  final int unreadCount;

  bool get hasMessages => lastMessage != null;
  bool get hasUnread => unreadCount > 0;

  factory MatchSummary.fromJson(Map<String, dynamic> json) {
    final lastMsgJson = json['last_message'];
    return MatchSummary(
      matchId: json['id'] as int,
      matchedAt: DateTime.parse(json['matched_at'] as String),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
      partner: UserProfile.fromBackend(json['profile'] as Map<String, dynamic>),
      lastMessage: lastMsgJson is Map<String, dynamic>
          ? LastMessagePreview.fromJson(lastMsgJson)
          : null,
      unreadCount: (json['unread_count'] as int?) ?? 0,
    );
  }
}
