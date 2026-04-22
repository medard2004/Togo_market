import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import 'edit_shop_screen.dart';

class ShopInformationScreen extends StatelessWidget {
  const ShopInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final shop = ShopInfo.sample;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Informations de la boutique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => Get.toNamed('/edit-shop', arguments: shop),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: r.s(160),
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: shop.coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.muted),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: r.s(72),
                          height: r.s(72),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                shop.logoUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: r.s(14)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shop.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${shop.category} • Vendeur vérifié',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shop.description,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informations clés',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.location_on_outlined, 'Localisation', shop.location),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.access_time, 'Horaires', '${shop.openingTime} - ${shop.closingTime}, ${shop.openingDays.join('-')}'),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.map_outlined, 'Zones couvertes', shop.zones.join(', ')),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.category_outlined, 'Catégories', shop.category),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.star, 'Note', '4.8 / 5'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.foreground,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
