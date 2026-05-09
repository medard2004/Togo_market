import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final Map<String, dynamic> orderData = Get.arguments ?? {};

    // We can either pass an Order object or a map. For now, let's assume a map from OrdersScreen
    final String title = orderData['title'] ?? 'Commande';
    final String price = orderData['price'] ?? '0 F';
    final String status = orderData['status'] ?? 'En attente';
    final String image = orderData['image'] ?? '';
    final String partnerName =
        orderData['vendor'] ?? orderData['buyer'] ?? 'Inconnu';
    final bool isSale = orderData['isSale'] ?? false;
    final String orderId = orderData['orderId'] ?? '#TG-8829';
    final String date = orderData['date'] ?? '08 Mai 2026, 09:45';

    Color statusColor;
    Color textColor;

    switch (status) {
      case 'Confirmé':
        statusColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'Terminé':
        statusColor = const Color(0xFFF2F2F7);
        textColor = const Color(0xFF8E8E93);
        break;
      case 'Annulé':
        statusColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default: // En attente
        statusColor = const Color(0xFFFFF7E6);
        textColor = const Color(0xFFB45309);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: AppTheme.foreground, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          'Détails de commande',
          style: TextStyle(
            color: AppTheme.foreground,
            fontSize: r.fs(16),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz,
                color: AppTheme.foreground, size: r.s(24)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(r.s(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(r.s(16)),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(r.rad(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.s(10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'Terminé'
                          ? Icons.check_circle
                          : Icons.access_time_filled,
                      color: textColor,
                      size: r.s(20),
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut : $status',
                          style: TextStyle(
                            fontSize: r.fs(15),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          status == 'En attente'
                              ? 'Le vendeur doit confirmer votre commande.'
                              : 'Commande traitée le $date',
                          style: TextStyle(
                            fontSize: r.fs(12),
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(24)),

            // ── Order Info ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Numéro de commande',
                      style: TextStyle(
                        fontSize: r.fs(12),
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      orderId,
                      style: TextStyle(
                        fontSize: r.fs(16),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: r.fs(12),
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      date.split(',')[0],
                      style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: r.s(24)),

            // ── Product Details ──────────────────────────────────────────────
            Text(
              'Articles',
              style: TextStyle(
                fontSize: r.fs(15),
                fontWeight: FontWeight.w800,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(12)),
            Container(
              padding: EdgeInsets.all(r.s(12)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(20)),
                boxShadow: AppTheme.shadowSm,
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r.rad(15)),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      width: r.s(80),
                      height: r.s(80),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: r.s(4)),
                        Text(
                          'Quantité: 1',
                          style: TextStyle(
                            fontSize: r.fs(12),
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        SizedBox(height: r.s(4)),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: r.fs(16),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(24)),

            // ── Partner Info (Seller/Buyer) ──────────────────────────────────
            Text(
              isSale
                  ? 'Informations de l\'acheteur'
                  : 'Informations du vendeur',
              style: TextStyle(
                fontSize: r.fs(15),
                fontWeight: FontWeight.w800,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(12)),
            Container(
              padding: EdgeInsets.all(r.s(16)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(20)),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: r.s(24),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Text(
                      partnerName[0].toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: r.fs(18),
                      ),
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partnerName,
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                        SizedBox(height: r.s(2)),
                        Text(
                          'Lomé, Togo',
                          style: TextStyle(
                            fontSize: r.fs(12),
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.chat_bubble_outline,
                        onTap: () {},
                        r: r,
                      ),
                      SizedBox(width: r.s(8)),
                      _IconButton(
                        icon: Icons.call_outlined,
                        onTap: () {},
                        r: r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(24)),

            // ── Delivery Info ────────────────────────────────────────────────
            Text(
              'Mode de réception',
              style: TextStyle(
                fontSize: r.fs(15),
                fontWeight: FontWeight.w800,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(12)),
            Container(
              padding: EdgeInsets.all(r.s(16)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(20)),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.s(10)),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.rad(12)),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: AppTheme.primary,
                      size: r.s(20),
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Livraison à domicile',
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                        Text(
                          'Lomé, Quartier Tokoin, Villa 452',
                          style: TextStyle(
                            fontSize: r.fs(12),
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(32)),

            // ── Payment Summary ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(r.s(20)),
              decoration: BoxDecoration(
                color: AppTheme.foreground.withOpacity(0.03),
                borderRadius: BorderRadius.circular(r.rad(24)),
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _PriceRow(label: 'Sous-total', value: price, r: r),
                  SizedBox(height: r.s(12)),
                  _PriceRow(
                      label: 'Frais de livraison', value: '1 500 F', r: r),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: r.s(16)),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: r.fs(16),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.foreground,
                        ),
                      ),
                      Text(
                        price, // In a real app, calculate total
                        style: TextStyle(
                          fontSize: r.fs(20),
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(40)),

            // ── Actions ──────────────────────────────────────────────────────
            if (status == 'En attente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.destructive.withOpacity(0.1),
                        foregroundColor: AppTheme.destructive,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: r.s(16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.rad(16)),
                        ),
                      ),
                      child: Text('Annuler',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: r.fs(14))),
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: r.s(16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.rad(16)),
                        ),
                      ),
                      child: Text(
                        isSale ? 'Accepter' : 'Modifier',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: r.fs(14)),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: r.s(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.rad(16)),
                    ),
                  ),
                  child: Text('Besoin d\'aide ?',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: r.fs(14))),
                ),
              ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final R r;

  const _IconButton({required this.icon, required this.onTap, required this.r});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.s(10)),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.border),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: r.s(18), color: AppTheme.primary),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final R r;

  const _PriceRow({required this.label, required this.value, required this.r});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(14),
            color: AppTheme.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: r.fs(14),
            fontWeight: FontWeight.w700,
            color: AppTheme.foreground,
          ),
        ),
      ],
    );
  }
}
