import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../controllers/app_controller.dart';
import '../../../utils/responsive.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final r = R(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: const Text('Mes favoris',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: const BackButton(color: AppTheme.foreground),
      ),
      body: Obx(() {
        final favs = ctrl.favorites;
        if (favs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: r.s(112),
                    height: r.s(112),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border,
                        size: r.s(48), color: AppTheme.primary),
                  ),
                  SizedBox(height: r.s(22)),
                  Text(
                    'Aucun favori',
                    style: TextStyle(
                      fontSize: r.fs(18),
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  SizedBox(height: r.s(10)),
                  Text(
                    'Vos articles préférés seront affichés ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.fs(14),
                      color: AppTheme.mutedForeground,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(r.hPad, r.s(20), r.hPad, r.s(24)),
          itemCount: favs.length,
          separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
          itemBuilder: (_, i) => FavoriteTicketCard(product: favs[i]),
        );
      }),
    );
  }
}
