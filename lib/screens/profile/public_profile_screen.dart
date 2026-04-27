import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';
import '../seller/widgets/seller_product_card.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? '';
    final seller = getSellerById(id);

    if (seller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil introuvable')),
        body: const Center(child: Text('Cet utilisateur n\'existe pas.')),
      );
    }

    final products = mockProducts.where((p) => p.sellerId == id).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
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
                          backgroundImage: CachedNetworkImageProvider(seller.avatar),
                        ),
                      ),
                      SizedBox(height: r.s(12)),
                      Text(
                        seller.name,
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
                            seller.location,
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
                          _buildHeaderStat(r, '${seller.rating}', 'Note', Icons.star),
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
                        _buildInfoRow(r, Icons.calendar_today_outlined, 'Membre depuis', 'Janvier 2023'),
                        Divider(height: r.s(24), color: AppTheme.border),
                        _buildInfoRow(r, Icons.verified_user_outlined, 'Vérification', 'Compte vérifié'),
                        Divider(height: r.s(24), color: AppTheme.border),
                        _buildInfoRow(r, Icons.speed_outlined, 'Réactivité', 'Répond sous ${seller.responseTime}'),
                      ],
                    ),
                  ),
                  SizedBox(height: r.s(28)),
                  Text(
                    'Annonces de ${seller.name}',
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
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: r.s(16)),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: r.s(16),
                crossAxisSpacing: r.s(12),
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => SellerProductCard(product: products[i], r: r),
                childCount: products.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: r.s(40))),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(r.s(20), r.s(12), r.s(20), MediaQuery.of(context).padding.bottom + r.s(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/chat/${seller.id}', arguments: seller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: EdgeInsets.symmetric(vertical: r.s(15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(16))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, color: Colors.white),
              SizedBox(width: r.s(10)),
              Text(
                'Contacter ${seller.name}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
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
