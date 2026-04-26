import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/boutique_controller.dart';
import '../../models/shop_info_model.dart';
import '../../Api/config/api_constants.dart';
import 'edit_shop_screen.dart';

class ShopInformationScreen extends StatelessWidget {
  const ShopInformationScreen({super.key});

  String _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final baseUrl = ApiConstants.baseUrl;
    final rootUrl = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    if (url.startsWith('/')) return '$rootUrl$url';
    return '$rootUrl/$url';
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Informations de la boutique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final boutique = BoutiqueController.to.myBoutique.value;
        if (boutique == null) {
          return const Center(child: Text("Boutique introuvable"));
        }

        String horairesStr = "08h - 18h";
        String joursStr = "Lun-Sam";
        if (boutique.horaires is Map) {
          if (boutique.horaires['ouverture'] != null) {
            horairesStr = "${boutique.horaires['ouverture']} - ${boutique.horaires['fermeture']}";
          }
          if (boutique.horaires['jours'] is List) {
            joursStr = (boutique.horaires['jours'] as List).join('-');
          }
        }

        String locationStr = '';
        if (boutique.adresse?.isNotEmpty == true) {
          locationStr = boutique.adresse!;
        }
        if (boutique.detailsAdresse?.isNotEmpty == true) {
          if (locationStr.isNotEmpty) locationStr += ', ';
          locationStr += boutique.detailsAdresse!;
        }
        if (locationStr.isEmpty) locationStr = 'Adresse non spécifiée';

        return SingleChildScrollView(
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
                    child: boutique.bannerUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _resolveUrl(boutique.bannerUrl),
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppTheme.muted),
                            errorWidget: (_, __, ___) => Container(color: AppTheme.muted),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primary.withValues(alpha: 0.25),
                                  AppTheme.primaryLight,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 48,
                                color: AppTheme.primary,
                              ),
                            ),
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
                            image: boutique.logoUrl.isNotEmpty 
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(_resolveUrl(boutique.logoUrl)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: boutique.logoUrl.isEmpty 
                              ? const Icon(Icons.storefront, color: AppTheme.primary, size: 32)
                              : null,
                        ),
                        SizedBox(width: r.s(14)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                boutique.nom,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                locationStr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Vendeur vérifié',
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
              boutique.description.isNotEmpty ? boutique.description : 'Aucune description fournie.',
              style: const TextStyle(fontSize: 14, height: 1.6),
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
                Icons.location_on_outlined, 'Localisation', locationStr),
            const SizedBox(height: 12),
            if (boutique.categories != null && boutique.categories!.isNotEmpty) ...[
              _buildInfoRow(
                  Icons.category_outlined,
                  'Catégories',
                  boutique.categories!.map((c) => c['nom'].toString()).join(', ')),
              const SizedBox(height: 12),
            ],
            _buildInfoRow(
                Icons.access_time, 'Horaires', '$horairesStr, $joursStr'),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.phone_outlined, 'Téléphone', boutique.telephone),
            const SizedBox(height: 12),
            if (boutique.contacts != null && boutique.contacts!.isNotEmpty)
              _buildInfoRow(Icons.contact_phone_outlined, 'Contact 2', boutique.contacts!.first.toString()),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.star, 'Note', '${boutique.noteMoyenne} / 5'),
            const SizedBox(height: 32),
            AppButton(
              label: 'Modifier la boutique',
              icon: Icons.edit_outlined,
              onTap: () => Get.toNamed('/edit-shop'), // EditShopScreen will use the controller directly
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
      }),
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
