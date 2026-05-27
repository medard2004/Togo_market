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
              final String type = notif.type.toLowerCase();
              final data = notif.customData ?? {};
              
              final receiverType = data['receiver_type']?.toString().toLowerCase();
              final isShopContext = receiverType == 'shop' || data.containsKey('boutique_id');

              IconData icon;
              Color iconColor;
              String contextLabel;
              
              if (isShopContext) {
                icon = type == 'order' 
                    ? PhosphorIcons.shoppingBag(PhosphorIconsStyle.regular)
                    : PhosphorIcons.storefront(PhosphorIconsStyle.regular);
                iconColor = Colors.orange.shade700;
                contextLabel = 'Boutique';
              } else {
                icon = type == 'order'
                    ? PhosphorIcons.package(PhosphorIconsStyle.regular)
                    : PhosphorIcons.user(PhosphorIconsStyle.regular);
                iconColor = AppTheme.primary;
                contextLabel = 'Personnel';
              }

              return InkWell(
                onTap: () => controller.handleNotificationTap(notif),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead ? AppTheme.cardColor : iconColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: notif.isRead
                        ? Border.all(color: AppTheme.border)
                        : Border.all(color: iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    contextLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: iconColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: TextStyle(
                                fontSize: 13,
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
