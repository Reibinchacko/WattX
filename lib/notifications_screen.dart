import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3ED),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildNotificationList(),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.black,
            ),
          ),
          Text(
            'Notifications',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Alerts',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '4 new updates',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 18),
              const SizedBox(width: 8),
              Text(
                'Filter',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationList() {
    return Column(
      children: [
        _NotificationCard(
          type: NotificationType.critical,
          title: 'Voltage Surge',
          description:
              'Grid voltage exceeded safe limit (255V). Automated breaker triggered to protect connected appliances.',
          time: '2 min ago',
          hasAction: true,
        ),
        const SizedBox(height: 16),
        _NotificationCard(
          type: NotificationType.warning,
          title: 'High Usage',
          description:
              'Power consumption is 35% higher than your daily average for this time of day.',
          time: '1 hour ago',
        ),
        const SizedBox(height: 16),
        _NotificationCard(
          type: NotificationType.resolved,
          title: 'Connection Restored',
          description:
              'Data synchronization with the main server has been restored and is stable.',
          time: 'Yesterday, 4:30 PM',
        ),
        const SizedBox(height: 16),
        _NotificationCard(
          type: NotificationType.info,
          title: 'Firmware Update',
          description:
              'Smart meter firmware successfully updated to version 2.4.1.',
          time: '2 days ago',
        ),
      ],
    );
  }
}

enum NotificationType { critical, warning, resolved, info }

class _NotificationCard extends StatelessWidget {
  final NotificationType type;
  final String title;
  final String description;
  final String time;
  final bool hasAction;

  const _NotificationCard({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.hasAction = false,
  });

  Color get _baseColor {
    switch (type) {
      case NotificationType.critical:
        return const Color(0xFFEF5350);
      case NotificationType.warning:
        return const Color(0xFFFFA726);
      case NotificationType.resolved:
        return const Color(0xFF66BB6A);
      case NotificationType.info:
        return const Color(0xFF42A5F5);
    }
  }

  String get _badgeText {
    switch (type) {
      case NotificationType.critical:
        return 'CRITICAL';
      case NotificationType.warning:
        return 'WARNING';
      case NotificationType.resolved:
        return 'RESOLVED';
      case NotificationType.info:
        return 'INFO';
    }
  }

  IconData get _icon {
    switch (type) {
      case NotificationType.critical:
        return Icons.bolt;
      case NotificationType.warning:
        return Icons.trending_up;
      case NotificationType.resolved:
        return Icons.check_circle;
      case NotificationType.info:
        return Icons.file_download;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: _baseColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _baseColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_icon, color: _baseColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _baseColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (type == NotificationType.critical ||
                                    type == NotificationType.warning)
                                  Icon(
                                    type == NotificationType.critical
                                        ? Icons.error
                                        : Icons.warning,
                                    color: _baseColor,
                                    size: 14,
                                  ),
                                if (type == NotificationType.critical ||
                                    type == NotificationType.warning)
                                  const SizedBox(width: 4),
                                Text(
                                  _badgeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _baseColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF616161),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Color(0xFF9E9E9E)),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                          if (hasAction)
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'View Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _baseColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 14, color: _baseColor),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
