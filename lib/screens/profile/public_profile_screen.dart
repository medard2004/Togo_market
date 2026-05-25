import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../Api/config/api_constants.dart';
import '../../controllers/public_profile_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/provider/auth_controller.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? '';
    // Initialiser le contrôleur pour cet ID
    final ctrl = Get.put(PublicProfileController(id), tag: id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = ctrl.user.value;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profil introuvable')),
            body: const Center(child: Text('Cet utilisateur n\'existe pas.')),
          );
        }

        final products = ctrl.products;
        final avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? ApiConstants.resolveImageUrl(user.avatarUrl!)
            : '';

        return CustomScrollView(
          slivers: [
            // ── Header Profil ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: r.s(280),
              pinned: true,
              backgroundColor: AppTheme.primary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fond dégradé
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Contenu profil
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: r.s(60)),
                        Container(
                          padding: EdgeInsets.all(r.s(4)),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: r.s(45),
                            backgroundColor:
                                AppTheme.secondary.withOpacity(0.2),
                            backgroundImage: avatarUrl.isNotEmpty
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            child: avatarUrl.isEmpty
                                ? Icon(Icons.person,
                                    size: r.s(45),
                                    color: AppTheme.secondary)
                                : null,
                          ),
                        ),
                        SizedBox(height: r.s(12)),
                        Text(
                          user.nom ?? 'Utilisateur',
                          style: TextStyle(
                            fontSize: r.fs(22),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: r.s(4)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: r.s(14), color: Colors.white70),
                            SizedBox(width: r.s(4)),
                            Text(
                              (() {
                                if (user.profileQuartierId != null) {
                                  final auth = Get.find<AuthController>();
                                  for (var v in auth.locations) {
                                    for (var q in v.quartiers) {
                                      if (q.id == user.profileQuartierId) {
                                        return '${v.nom}, ${q.nom}';
                                      }
                                    }
                                  }
                                }
                                return 'Togo';
                              })(),
                              style: TextStyle(
                                fontSize: r.fs(13),
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.s(16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeaderStat(r, '0.0', 'Note', Icons.star),
                            Container(width: 1, height: r.s(20), color: Colors.white24, margin: EdgeInsets.symmetric(horizontal: r.s(20))),
                            _buildHeaderStat(r, '${products.length}', 'Annonces', Icons.shopping_bag),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Infos supplémentaires ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(r.s(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.s(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(r.rad(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(r, Icons.calendar_today_outlined, 'Membre depuis', 'Janvier 2024'),
                          Divider(height: r.s(24), color: AppTheme.border),
                          _buildInfoRow(r, Icons.verified_user_outlined, 'Vérification', 'Compte vérifié'),
                          Divider(height: r.s(24), color: AppTheme.border),
                          _buildInfoRow(r, Icons.speed_outlined, 'Réactivité', 'Répond rapidement'),
                        ],
                      ),
                    ),
                    SizedBox(height: r.s(28)),
                    Text(
                      'Annonces de ${user.nom ?? 'l\'utilisateur'}',
                      style: TextStyle(
                        fontSize: r.fs(18),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                    SizedBox(height: r.s(16)),
                  ],
                ),
              ),
            ),

            // ── Grille de produits ─────────────────────────────────────────────
            if (products.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: r.s(40)),
                    child: Text('Aucune annonce pour le moment', style: TextStyle(color: AppTheme.mutedForeground)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: r.s(16)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: r.s(16),
                    crossAxisSpacing: r.s(12),
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(product: products[i]),
                    childCount: products.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: r.s(40))),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final user = ctrl.user.value;
        if (user == null) return const SizedBox();

        return Container(
          padding: EdgeInsets.fromLTRB(
            r.s(20),
            r.s(12),
            r.s(20),
            MediaQuery.of(context).padding.bottom + r.s(12),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              final auth = Get.find<AuthController>();
              final me = auth.currentUser.value;
              if (me == null) {
                Get.toNamed('/auth');
                return;
              }
              final myId = me.id.toString();
              try {
                final chatId = await ChatService.to.getOrCreateChat(
                  myId: myId,
                  myName: me.nom ?? 'Utilisateur',
                  myAvatar: me.avatarUrl ?? '',
                  otherId: user.id.toString(),
                  otherName: user.nom ?? 'Vendeur',
                  otherAvatar: user.avatarUrl ?? '',
                );
                Get.toNamed('/chat/$chatId', arguments: user);
              } catch (_) {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'ouvrir la conversation.',
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: EdgeInsets.symmetric(vertical: r.s(15)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.rad(16)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                SizedBox(width: r.s(10)),
                Text(
                  'Contacter ${user.nom ?? 'le vendeur'}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderStat(R r, String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: r.s(14), color: Colors.white),
            SizedBox(width: r.s(4)),
            Text(
              value,
              style: TextStyle(
                fontSize: r.fs(16),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(11),
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(R r, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.s(8)),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(r.rad(10)),
          ),
          child: Icon(icon, size: r.s(18), color: AppTheme.primary),
        ),
        SizedBox(width: r.s(12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: r.fs(11),
                color: AppTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: r.fs(13),
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
