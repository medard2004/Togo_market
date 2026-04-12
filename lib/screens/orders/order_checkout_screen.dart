import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';
import '../../../utils/responsive.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({super.key});
  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  // 'livraison' = côté gauche maquette | 'retrait' = côté droit
  String _mode = 'livraison';
  bool _confirmed = false;
  final _phoneCtrl = TextEditingController(text: '90 00 00 00');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final args = Get.arguments as Map<String, dynamic>?;
    final product = getProductById(args?['productId'] ?? 'p1');

    // ── Confirmation ─────────────────────────────────────────────────────────
    if (_confirmed) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (_, v, __) => Transform.scale(
                scale: v,
                child: Icon(Icons.check_circle_rounded,
                    size: r.s(80), color: Colors.green),
              ),
            ),
            SizedBox(height: r.s(20)),
            Text('Commande confirmée !',
                style: TextStyle(
                    fontSize: r.fs(22),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground)),
            SizedBox(height: r.s(8)),
            Text('Le vendeur sera notifié immédiatement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: r.fs(14), color: AppTheme.mutedForeground)),
          ]),
        ),
      );
    }

    // ── Montant formaté façon maquette : "745.000 FCFA" ──────────────────────
    String priceMain = '';
    if (product != null) {
      final v = product.price.toStringAsFixed(0);
      priceMain = v.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,

      // ── AppBar : bouton ← rond + titre centré ──────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: r.s(12)),
          child: GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.s(36),
              height: r.s(36),
              margin: EdgeInsets.symmetric(vertical: r.s(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowCard,
              ),
              child: Icon(Icons.arrow_back,
                  size: r.s(18), color: AppTheme.foreground),
            ),
          ),
        ),
        title: Text('Commander',
            style: TextStyle(
                fontSize: r.fs(16),
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground)),
      ),

      // ── Body scrollable ───────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(8), r.hPad, r.s(160)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Carte produit ─────────────────────────────────────────────
            if (product != null)
              Container(
                padding: EdgeInsets.all(r.s(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    // Image produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(10)),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: r.s(64),
                        height: r.s(64),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: r.s(12)),
                    // Titre + prix (prix = chiffres en gras + FCFA petit)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: r.fs(13),
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.foreground)),
                          SizedBox(height: r.s(5)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$priceMain ',
                                  style: TextStyle(
                                      fontSize: r.fs(15),
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                      fontFamily: 'PlusJakartaSans'),
                                ),
                                TextSpan(
                                  text: 'FCFA',
                                  style: TextStyle(
                                      fontSize: r.fs(11),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                      fontFamily: 'PlusJakartaSans'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge quantité
                    Container(
                      width: r.s(32),
                      height: r.s(32),
                      decoration: BoxDecoration(
                        color: AppTheme.muted,
                        borderRadius: BorderRadius.circular(r.rad(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text('x1',
                          style: TextStyle(
                              fontSize: r.fs(12),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mutedForeground)),
                    ),
                  ],
                ),
              ),

            SizedBox(height: r.s(22)),

            // ── 2. Mode de réception ─────────────────────────────────────────
            // Icône camion pour livraison, icône caisse pour retrait
            Row(children: [
              Icon(
                _mode == 'livraison'
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                size: r.s(18),
                color: AppTheme.primary,
              ),
              SizedBox(width: r.s(7)),
              Text('Mode de réception',
                  style: TextStyle(
                      fontSize: r.fs(15),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(12)),

            // Option Livraison à domicile
            _OrderModeOption(
              value: 'livraison',
              groupValue: _mode,
              title: 'Livraison à domicile',
              subtitle: 'Recevez votre colis à Lomé & environs',
              onTap: () => setState(() => _mode = 'livraison'),
              r: r,
            ),
            SizedBox(height: r.s(10)),
            // Option Retrait en point de vente
            _OrderModeOption(
              value: 'retrait',
              groupValue: _mode,
              title: 'Retrait en point de vente',
              subtitle: 'Gratuit · Récupérez au Grand Marché',
              onTap: () => setState(() => _mode = 'retrait'),
              r: r,
            ),

            SizedBox(height: r.s(22)),

            // ── 3. Vos coordonnées ───────────────────────────────────────────
            Row(children: [
              Icon(Icons.person_outline, size: r.s(18), color: AppTheme.primary),
              SizedBox(width: r.s(7)),
              Text('Vos coordonnées',
                  style: TextStyle(
                      fontSize: r.fs(15),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(14)),

            // Label téléphone
            Text('NUMÉRO DE TÉLÉPHONE',
                style: TextStyle(
                    fontSize: r.fs(10),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                    letterSpacing: 0.7)),
            SizedBox(height: r.s(7)),

            // Champ téléphone : +228 | numéro | ✓
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Préfixe +228
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.s(14)),
                      decoration: BoxDecoration(
                        border:
                            Border(right: BorderSide(color: AppTheme.border)),
                      ),
                      alignment: Alignment.center,
                      child: Text('+228',
                          style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w500,
                              color: AppTheme.foreground)),
                    ),
                    // Champ numéro
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                            fontSize: r.fs(14), color: AppTheme.foreground),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: r.s(12), vertical: r.s(14)),
                          isDense: true,
                          hintText: '90 00 00 00',
                          hintStyle: TextStyle(
                              color: AppTheme.mutedForeground,
                              fontSize: r.fs(14)),
                        ),
                      ),
                    ),
                    // Icône check verte
                    Padding(
                      padding: EdgeInsets.only(right: r.s(12)),
                      child: Icon(Icons.check_circle_outline,
                          size: r.s(20), color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: r.s(14)),

            // Label champ note — change selon mode
            Text(
              _mode == 'livraison'
                  ? 'QUARTIER & PRÉCISIONS'
                  : 'NOTE OU PRÉCISIONS',
              style: TextStyle(
                  fontSize: r.fs(10),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedForeground,
                  letterSpacing: 0.7),
            ),
            SizedBox(height: r.s(7)),

            // Champ texte libre
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 4,
                style:
                    TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  isDense: true,
                  hintText: _mode == 'livraison'
                      ? 'Ex: Adidogomé, près de l\'église, portail bleu...'
                      : 'Indiquez l\'heure de votre passage ou toute autre précision utile...',
                  hintStyle: TextStyle(
                      fontSize: r.fs(13), color: AppTheme.mutedForeground),
                ),
              ),
            ),

            SizedBox(height: r.s(14)),

            // ── 4. Bandeau paiement ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: r.s(12)),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_outlined,
                      size: r.s(16), color: AppTheme.primary),
                  SizedBox(width: r.s(7)),
                  Text(
                    _mode == 'livraison'
                        ? 'Paiement à la livraison uniquement'
                        : 'Paiement au moment du retrait',
                    style: TextStyle(
                        fontSize: r.fs(12),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── 5. Footer fixe : ligne séparatrice + total + bouton + note ─────────
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        padding: EdgeInsets.fromLTRB(
            r.hPad,
            r.s(14),
            r.hPad,
            r.s(20) + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ligne total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Total à payer',
                    style: TextStyle(
                        fontSize: r.fs(13), color: AppTheme.mutedForeground)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: product != null ? '$priceMain ' : '0 ',
                        style: TextStyle(
                            fontSize: r.fs(20),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                            fontFamily: 'PlusJakartaSans'),
                      ),
                      TextSpan(
                        text: 'FCFA',
                        style: TextStyle(
                            fontSize: r.fs(13),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                            fontFamily: 'PlusJakartaSans'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: r.s(12)),

            // Bouton Confirmer
            GestureDetector(
              onTap: () {
                setState(() => _confirmed = true);
                Future.delayed(const Duration(seconds: 3),
                    () => Get.offAllNamed('/home'));
              },
              child: Container(
                width: double.infinity,
                height: r.s(54).clamp(50.0, 62.0),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(30)),
                  boxShadow: AppTheme.shadowPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Confirmer la commande',
                        style: TextStyle(
                            fontSize: r.fs(15),
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(width: r.s(6)),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: r.s(13), color: Colors.white),
                  ],
                ),
              ),
            ),

            SizedBox(height: r.s(8)),

            // Note légale contextuelle
            Text(
              _mode == 'livraison'
                  ? 'En confirmant, vous vous engagez à réceptionner votre commande.'
                  : 'En confirmant, vous vous engagez à venir récupérer votre commande.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: r.fs(10), color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget : option radio mode livraison / retrait ────────────────────────────
class _OrderModeOption extends StatelessWidget {
  final String value, groupValue, title, subtitle;
  final VoidCallback onTap;
  final R r;
  const _OrderModeOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(14)),
        decoration: BoxDecoration(
          // Fond blanc dans les deux cas — seule la bordure change
          color: active ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(r.rad(14)),
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Bouton radio dessiné à la main
            Container(
              width: r.s(22),
              height: r.s(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppTheme.primary : const Color(0xFFBBB5B0),
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: active
                  ? Center(
                      child: Container(
                        width: r.s(11),
                        height: r.s(11),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: r.s(14)),
            // Textes — titre toujours en noir/foreground (pas orange)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: FontWeight.w700,
                        // Titre reste foreground même quand actif — comme dans la maquette
                        color: AppTheme.foreground,
                      )),
                  SizedBox(height: r.s(2)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
