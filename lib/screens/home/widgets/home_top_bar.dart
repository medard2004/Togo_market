import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/app_controller.dart';
import '../../../Api/provider/auth_controller.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/user_avatar.dart';
import '../../../controllers/notification_controller.dart';

class HomeTopBar extends StatelessWidget {
  final AppController ctrl;
  const HomeTopBar({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, r.s(12), r.hPad, r.s(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Bonjour',
                        style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
                    SizedBox(width: r.s(4)),
                    Icon(Icons.waving_hand_rounded, size: r.fs(16), color: Colors.orangeAccent),
                    SizedBox(width: r.s(6)),
                    Flexible(
                      child: Obx(() {
                        final authCtrl = Get.find<AuthController>();
                        final user = authCtrl.currentUser.value;
                        final name = user?.nom?.isNotEmpty == true ? user!.nom!.split(' ').first : 'Utilisateur';
                        return Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600, color: AppTheme.foreground),
                        );
                      }),
                    ),
                  ],
                ),
                Text('Togo_Market',
                    style: TextStyle(fontSize: r.fs(20), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (Get.find<AuthController>().currentUser.value == null) {
                Get.toNamed('/auth', arguments: {'redirect': '/notifications'});
              } else {
                Get.toNamed('/notifications');
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: r.s(42), height: r.s(42),
                  decoration: BoxDecoration(color: AppTheme.cardColor, shape: BoxShape.circle, boxShadow: AppTheme.shadowCard),
                  child: Icon(Icons.notifications_outlined, size: r.s(22), color: AppTheme.foreground),
                ),
                Obx(() {
                  final unread = Get.find<NotificationController>().unreadCount.value;
                  if (unread > 0) {
                    return Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.all(r.s(4)),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardColor, width: 2),
                        ),
                        constraints: BoxConstraints(
                          minWidth: r.s(18),
                          minHeight: r.s(18),
                        ),
                        child: Center(
                          child: Text(
                            unread > 99 ? '99+' : unread.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: r.fs(9),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          SizedBox(width: r.s(10)),
          GestureDetector(
            onTap: () {
              if (Get.find<AuthController>().currentUser.value == null) {
                Get.toNamed('/auth', arguments: {'redirect': '/profile'});
              } else {
                Get.toNamed('/profile');
              }
            },
            child: Obx(() {
              final authCtrl = Get.find<AuthController>();
              final user = authCtrl.currentUser.value;
              return UserAvatar(
                url: user?.avatarUrl,
                name: user?.nom,
                radius: r.s(20),
              );
            }),
          ),
        ],
      ),
    );
  }
}
