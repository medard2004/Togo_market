import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/app_controller.dart';
import '../../../Api/provider/auth_controller.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/user_avatar.dart';

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
            onTap: () => Get.toNamed('/notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: r.s(42), height: r.s(42),
                  decoration: BoxDecoration(color: AppTheme.cardColor, shape: BoxShape.circle, boxShadow: AppTheme.shadowCard),
                  child: Icon(Icons.notifications_outlined, size: r.s(22), color: AppTheme.foreground),
                ),
                if (ctrl.unreadNotifications.value > 0)
                  Positioned(
                    top: r.s(4), right: r.s(4),
                    child: Container(
                      width: r.s(10), height: r.s(10),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: r.s(10)),
          GestureDetector(
            onTap: () => Get.toNamed('/profile'),
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
