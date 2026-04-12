import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const BackButton(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final notif = mockNotifications[i];
          IconData icon;
          Color iconColor;
          switch (notif.type) {
            case 'message':
              icon = Icons.chat_bubble_outline;
              iconColor = AppTheme.primary;
              break;
            case 'order':
              icon = Icons.shopping_bag_outlined;
              iconColor = AppTheme.secondary;
              break;
            default:
              icon = Icons.favorite_border;
              iconColor = Colors.red;
          }
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notif.isRead ? AppTheme.cardColor : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: notif.isRead
                  ? Border.all(color: AppTheme.border)
                  : Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(notif.body,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.mutedForeground)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(notif.time,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.mutedForeground)),
                    if (!notif.isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
