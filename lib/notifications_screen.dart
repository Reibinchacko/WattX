import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'models/alert_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: StreamBuilder<List<AlertModel>>(
                stream: _databaseService.getAlerts(_uid),
                builder: (context, snapshot) {
                  final alerts = snapshot.data ?? [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildTitle(alerts.length),
                        const SizedBox(height: 16),
                        _buildNotificationList(alerts),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
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
                color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
              color: Colors.black,
            ),
          ),
          Text('Notifications',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () {},
              color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildTitle(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Alerts',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)),
            const SizedBox(height: 2),
            Text('$count new updates',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF757575))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Row(children: [
            const Icon(Icons.tune, size: 18),
            const SizedBox(width: 8),
            Text('Filter',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600))
          ]),
        ),
      ],
    );
  }

  Widget _buildNotificationList(List<AlertModel> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No new notifications',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: alerts
          .map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _NotificationCard(
                  alert: alert,
                  onTap: () =>
                      _databaseService.markAlertAsRead(_uid, alert.alertId))))
          .toList(),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const _NotificationCard({required this.alert, this.onTap});

  Color get _baseColor {
    switch (alert.type) {
      case 'critical':
        return const Color(0xFFEF5350);
      case 'warning':
        return const Color(0xFFFFA726);
      case 'resolved':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  IconData get _icon {
    switch (alert.type) {
      case 'critical':
        return Icons.bolt;
      case 'warning':
        return Icons.trending_up;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
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
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: _baseColor),
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
                                      color: _baseColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle),
                                  child:
                                      Icon(_icon, color: _baseColor, size: 20)),
                              const SizedBox(width: 12),
                              Text(alert.title,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: _baseColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(alert.type.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _baseColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(alert.message,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF616161),
                              height: 1.5)),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Color(0xFF9E9E9E)),
                            const SizedBox(width: 4),
                            Text(
                                DateFormat('MMM d, h:mm a')
                                    .format(alert.timestamp),
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF9E9E9E)))
                          ]),
                          if (onTap != null && !alert.isRead)
                            GestureDetector(
                                onTap: onTap,
                                child: Text('Mark as Read',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _baseColor))),
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
