import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/notification_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;

    // Déclencher le rafraîchissement au chargement
    controller.fetchNotificationsFromServer();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const BackButton(),
        actions: [
          Obx(() {
            final hasUnread = controller.notifications.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () => controller.markAllAsRead(),
              icon: Icon(
                PhosphorIcons.checks(PhosphorIconsStyle.bold),
                size: 16,
                color: AppTheme.primary,
              ),
              label: Text(
                'Tout lire',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchNotificationsFromServer(),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.bellSlash(PhosphorIconsStyle.light),
                          size: 64,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucune notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous serez notifié des commandes et messages ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotificationsFromServer(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final notif = controller.notifications[i];
              IconData icon;
              Color iconColor;
              
              switch (notif.type.toLowerCase()) {
                case 'message':
                  icon = PhosphorIcons.chatCircle(PhosphorIconsStyle.regular);
                  iconColor = AppTheme.primary;
                  break;
                case 'order':
                  icon = PhosphorIcons.shoppingBag(PhosphorIconsStyle.regular);
                  iconColor = AppTheme.secondary;
                  break;
                default:
                  icon = PhosphorIcons.heart(PhosphorIconsStyle.regular);
                  iconColor = Colors.red;
              }

              return InkWell(
                onTap: () => controller.handleNotificationTap(notif),
                borderRadius: BorderRadius.circular(16),
                child: Container(
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            notif.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
