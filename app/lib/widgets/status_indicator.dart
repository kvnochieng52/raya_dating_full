import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/privacy_service.dart';

class OnlineStatusIndicator extends StatelessWidget {
  final OnlineStatus status;
  final double size;
  final bool showText;
  final DateTime? lastSeen;

  const OnlineStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.showText = false,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData? statusIcon;

    switch (status) {
      case OnlineStatus.online:
        statusColor = Colors.green;
        statusIcon = Icons.circle;
        break;
      case OnlineStatus.away:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case OnlineStatus.doNotDisturb:
        statusColor = Colors.red;
        statusIcon = Icons.do_not_disturb_on;
        break;
      case OnlineStatus.offline:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
        break;
    }

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case OnlineStatus.online:
        return 'Online';
      case OnlineStatus.away:
        return 'Away';
      case OnlineStatus.doNotDisturb:
        return 'Busy';
      case OnlineStatus.offline:
        if (lastSeen != null) {
          return PrivacyService.formatLastSeen(lastSeen!);
        }
        return 'Offline';
    }
  }
}

class VisibilityModeIndicator extends StatelessWidget {
  final VisibilityMode mode;
  final bool showText;

  const VisibilityModeIndicator({
    super.key,
    required this.mode,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (mode) {
      case VisibilityMode.public:
        icon = Icons.public;
        color = Colors.green;
        break;
      case VisibilityMode.private:
        icon = Icons.lock_outline;
        color = Colors.orange;
        break;
      case VisibilityMode.invisible:
        icon = Icons.visibility_off;
        color = Colors.red;
        break;
    }

    if (showText) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              PrivacyService.getVisibilityModeTitle(mode),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      icon,
      size: 20,
      color: color,
    );
  }
}

class ProfileStatusWidget extends StatelessWidget {
  final OnlineStatus onlineStatus;
  final VisibilityMode visibilityMode;
  final DateTime? lastSeen;
  final bool showOnlineStatus;
  final bool showLastSeen;

  const ProfileStatusWidget({
    super.key,
    required this.onlineStatus,
    required this.visibilityMode,
    this.lastSeen,
    this.showOnlineStatus = true,
    this.showLastSeen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visibility Mode
        VisibilityModeIndicator(
          mode: visibilityMode,
          showText: true,
        ),

        if (showOnlineStatus) ...[
          const SizedBox(height: 8),
          // Online Status
          OnlineStatusIndicator(
            status: onlineStatus,
            showText: true,
            lastSeen: showLastSeen ? lastSeen : null,
            size: 16,
          ),
        ],
      ],
    );
  }
}