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
        title: const Text('Mes Favoris'),
        leading: const BackButton(),
      ),
      body: Obx(() {
        final favs = ctrl.favorites;
        if (favs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(r.s(30)),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_rounded, size: r.s(64), color: AppTheme.primary),
                ),
                SizedBox(height: r.s(24)),
                Text(
                  'Aucun favori pour l\'instant',
                  style: TextStyle(
                    fontSize: r.fs(18),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(8)),
                Text(
                  'Appuyez sur l\'icône de cœur pour sauvegarder\nvos articles préférés',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.fs(14),
                    color: AppTheme.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compteur
            Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, r.s(14), r.hPad, r.s(8)),
              child: Text(
                '${favs.length} article${favs.length > 1 ? 's' : ''} sauvegardé${favs.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ),
            // Liste tickets
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(24)),
                itemCount: favs.length,
                separatorBuilder: (_, __) => SizedBox(height: r.s(10)),
                itemBuilder: (_, i) => FavoriteTicketCard(product: favs[i]),
              ),
            ),
          ],
        );
      }),
    );
  }
}
