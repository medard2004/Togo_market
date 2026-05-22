import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../Api/services/order_service.dart';
import '../../../Api/firebase/services/chat_service.dart';
import '../../../utils/location_service.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';
import '../../../models/models.dart';
import '../../../utils/responsive.dart';
import '../../../Api/provider/auth_controller.dart';
import '../../../controllers/app_controller.dart';
import 'package:geolocator/geolocator.dart';

import '../../../Api/core/api_client.dart';
import '../../../Api/config/api_constants.dart';
import '../../../utils/app_toasts.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({super.key});
  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen>
    with WidgetsBindingObserver {
  String _mode = 'livraison';
  String _paymentMode = 'livraison';
  bool _confirmed = false;
  int _quantity = 1;
  bool _isLoading = false;
  bool _gpsLoading = false;
  bool _waitingForLocationActivation = false;
  double? _deliveryLat;
  double? _deliveryLon;
  String? _phoneError;
  Map<String, dynamic>? _orderResult; // Réponse de l'API après création
  int _countdown = 10; // Compte à rebours avant redirection

  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final MapController _mapController = MapController();

  late final _orderService = OrderService(Get.find<ApiClient>());
  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefillPhone();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_countdown <= 1) {
        Get.offAllNamed('/home');
        return false;
      }
      setState(() => _countdown--);
      return true;
    });
  }

  /// Affiche un dialogue de confirmation avant de passer la commande
  Future<bool> _showConfirmationDialog(
      Product product, String priceMain, String totalPriceMain) async {
    final modeLabel =
        _mode == 'livraison' ? 'Livraison à domicile' : 'Retrait en boutique';
    final payLabel = _paymentMode == 'livraison'
        ? 'À la livraison / retrait'
        : 'Entente en messagerie';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header gradient ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Confirmer la commande',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Veuillez vérifier les détails avant de valider',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // ── Détails commande ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    // Produit
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl:
                                ApiConstants.resolveImageUrl(product.image),
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 52,
                              height: 52,
                              color: AppTheme.muted,
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: AppTheme.mutedForeground, size: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.foreground),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$priceMain FCFA',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Divider(height: 1, color: AppTheme.border),
                    const SizedBox(height: 14),

                    // Lignes de récap
                    _confirmRow(
                        Icons.local_shipping_outlined, 'Livraison', modeLabel),
                    const SizedBox(height: 8),
                    _confirmRow(
                        Icons.credit_card_outlined, 'Paiement', payLabel),
                    const SizedBox(height: 8),
                    _confirmRow(
                        Icons.phone_outlined, 'Téléphone', _formattedPhone),
                    if (_mode == 'livraison' &&
                        _addressCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _confirmRow(Icons.location_on_outlined, 'Adresse',
                          _addressCtrl.text),
                    ],
                    const SizedBox(height: 8),
                    _confirmRow(
                        Icons.production_quantity_limits_outlined, 'Quantité', 'x $_quantity'),
                    const SizedBox(height: 8),
                    _confirmRow(
                        Icons.calculate_outlined, 'Total', '$totalPriceMain FCFA'),

                    const SizedBox(height: 16),
                    // Avertissement
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Une fois confirmée, la commande sera envoyée au vendeur immédiatement.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Boutons ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.foreground,
                          side: BorderSide(color: AppTheme.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Confirmer',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTheme.mutedForeground),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground),
          ),
        ),
      ],
    );
  }

  void _prefillPhone() {
    try {
      final user = Get.find<AuthController>().currentUser.value;
      if (user != null && user.telephone.isNotEmpty) {
        String phone = user.telephone.replaceAll(RegExp(r'\s+'), '');
        if (phone.startsWith('+228')) phone = phone.substring(4);
        if (phone.startsWith('228') && phone.length > 8)
          phone = phone.substring(3);
        _phoneCtrl.text = phone;
      }
    } catch (_) {}
  }

  bool _validatePhone() {
    final clean = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) {
      setState(() => _phoneError = 'Le numéro est requis');
      return false;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(clean)) {
      setState(() => _phoneError =
          'Le numéro togolais doit contenir exactement 8 chiffres');
      return false;
    }
    setState(() => _phoneError = null);
    return true;
  }

  bool get _isPhoneValid {
    final clean = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^\d{8}$').hasMatch(clean);
  }

  String get _formattedPhone =>
      '+228${_phoneCtrl.text.replaceAll(RegExp(r'\s+'), '')}';

  Future<void> _requestGpsPosition() async {
    setState(() => _gpsLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _gpsLoading = false);
        _showLocationSettingsDialog();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception("Permission refusée");
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception("Permission refusée définitivement");
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _deliveryLat = position.latitude;
        _deliveryLon = position.longitude;
        _gpsLoading = false;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      _reverseGeocodeAndFillAddress(position.latitude, position.longitude);
      AppToasts.success(
          context, 'Localisation récupérée', 'Votre position a été ajoutée.');
    } catch (e) {
      setState(() => _gpsLoading = false);
      AppToasts.error(
          context, 'Erreur GPS', 'Impossible de récupérer votre position.');
    }
  }

  void _showLocationSettingsDialog() {
    final r = R(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(r.s(24)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(24))),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: r.s(48),
                height: r.s(48),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_disabled,
                    color: Colors.orange, size: r.s(24)),
              ),
              SizedBox(height: r.s(16)),
              Text(
                'Localisation désactivée',
                style: TextStyle(
                  fontSize: r.fs(18),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              SizedBox(height: r.s(8)),
              Text(
                'La géolocalisation est nécessaire pour partager votre position. Vous pouvez aussi sélectionner votre adresse manuellement sur la carte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fs(14),
                  color: AppTheme.mutedForeground,
                  height: 1.4,
                ),
              ),
              SizedBox(height: r.s(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.foreground,
                        side: BorderSide(color: AppTheme.border),
                        padding: EdgeInsets.symmetric(vertical: r.s(14)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(14))),
                      ),
                      child: Text('Plus tard',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: r.fs(14))),
                    ),
                  ),
                  SizedBox(width: r.s(12)),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        _waitingForLocationActivation = true;
                        await Geolocator.openLocationSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: r.s(14)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(14))),
                      ),
                      child: Text('Activer le GPS',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: r.fs(14))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _deliveryLat = point.latitude;
      _deliveryLon = point.longitude;
    });
    _reverseGeocodeAndFillAddress(point.latitude, point.longitude);
  }

  Future<void> _reverseGeocodeAndFillAddress(double lat, double lon) async {
    final data = await LocationService.reverseGeocode(lat, lon);
    if (data != null && mounted) {
      String formatted = '';
      if (data['ville'] != null && data['ville']!.isNotEmpty)
        formatted += data['ville']!;
      if (data['quartier'] != null && data['quartier']!.isNotEmpty) {
        formatted += (formatted.isNotEmpty ? ', ' : '') + data['quartier']!;
      }
      if (formatted.isNotEmpty) setState(() => _addressCtrl.text = formatted);
    }
  }

  /// Get real product from AppController, fallback to mock
  Product? _getProduct(dynamic productId) {
    try {
      final ctrl = Get.find<AppController>();
      final p = ctrl.products
          .firstWhereOrNull((p) => p.id.toString() == productId.toString());
      if (p != null) return p;
    } catch (_) {}
    return getProductById(productId?.toString() ?? 'p1');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForLocationActivation) {
      _waitingForLocationActivation = false;
      _checkLocationAndResume();
    }
  }

  Future<void> _checkLocationAndResume() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      _requestGpsPosition();
    }
  }

  Widget _recapRow(R r, IconData icon, String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.s(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: r.s(16), color: AppTheme.mutedForeground),
          SizedBox(width: r.s(8)),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontSize: r.fs(13), color: AppTheme.mutedForeground)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: r.fs(13),
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppTheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recapRowIcon(R r, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.s(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: r.s(16), color: AppTheme.mutedForeground),
          SizedBox(width: r.s(8)),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontSize: r.fs(13), color: AppTheme.mutedForeground)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foreground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recapDivider() =>
      Divider(height: 1, thickness: 0.5, color: AppTheme.border);

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final args = Get.arguments as Map<String, dynamic>?;
    final product = _getProduct(args?['productId']);

    // ── Montant formaté façon maquette : "745.000 FCFA" ──────────────────────
    String priceMain = '';
    String totalPriceMain = '';
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Commander')),
        body: const Center(child: Text('Produit non trouvé')),
      );
    }

    final v = product.price.toStringAsFixed(0);
    priceMain = v.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    final tv = (product.price * _quantity).toStringAsFixed(0);
    totalPriceMain = tv.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    // ── Page de Confirmation ──────────────────────────────────────────────────
    if (_confirmed) {
      final orderId = _orderResult?['id']?.toString() ?? '-';
      final orderDate = DateTime.now();
      final dateStr =
          '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year}  ${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}';
      final modeLabel =
          _mode == 'livraison' ? 'Livraison à domicile' : 'Retrait en boutique';
      final modeIcon = _mode == 'livraison'
          ? Icons.delivery_dining_outlined
          : Icons.storefront_outlined;
      final payLabel = _paymentMode == 'livraison'
          ? 'À la livraison/retrait'
          : 'Entente en messagerie';

      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: r.hPad, vertical: r.s(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── 1. Countdown + Icône ─────────────────────────────────────
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: r.s(110),
                        height: r.s(110),
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(_countdown),
                          tween: Tween(begin: 1.0, end: 0.0),
                          duration: const Duration(seconds: 1),
                          builder: (_, value, __) => CircularProgressIndicator(
                            value: (_countdown - 1 + value) / 10,
                            strokeWidth: 5,
                            backgroundColor: AppTheme.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: r.s(40), color: AppTheme.primary),
                          SizedBox(height: r.s(2)),
                          Text(
                            '$_countdown',
                            style: TextStyle(
                              fontSize: r.fs(18),
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.s(10)),
                Text(
                  'Redirection dans $_countdown secondes…',
                  style: TextStyle(
                      fontSize: r.fs(12), color: AppTheme.mutedForeground),
                ),
                SizedBox(height: r.s(20)),

                // ── 2. Titre ─────────────────────────────────────────────────
                Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: r.fs(24),
                    fontWeight: FontWeight.w900,
                    color: AppTheme.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: r.s(6)),
                Text(
                  'Votre commande a été transmise au vendeur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: r.fs(13),
                      color: AppTheme.mutedForeground,
                      height: 1.5),
                ),
                SizedBox(height: r.s(24)),

                // ── 3. Card récapitulative ────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(r.rad(24)),
                    boxShadow: AppTheme.shadowCard,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      // Header avec image produit
                      Container(
                        padding: EdgeInsets.all(r.s(16)),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(r.rad(24)),
                            topRight: Radius.circular(r.rad(24)),
                          ),
                          border: Border(
                              bottom: BorderSide(color: AppTheme.border)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(r.rad(12)),
                              child: CachedNetworkImage(
                                imageUrl:
                                    ApiConstants.resolveImageUrl(product.image),
                                width: r.s(56),
                                height: r.s(56),
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: r.s(56),
                                  height: r.s(56),
                                  color: AppTheme.muted,
                                  child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppTheme.mutedForeground),
                                ),
                              ),
                            ),
                            SizedBox(width: r.s(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: r.fs(14),
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.foreground),
                                  ),
                                  SizedBox(height: r.s(4)),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: r.s(8),
                                            vertical: r.s(3)),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.orange.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(r.rad(20)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.hourglass_top_outlined,
                                                size: 12,
                                                color: Colors.orange.shade700),
                                            const SizedBox(width: 4),
                                            Text(
                                              'En attente',
                                              style: TextStyle(
                                                  fontSize: r.fs(11),
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      Colors.orange.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lignes de détails
                      Padding(
                        padding: EdgeInsets.all(r.s(16)),
                        child: Column(
                          children: [
                            _recapRow(r, Icons.tag_outlined, 'N° Commande',
                                '#$orderId',
                                bold: true),
                            _recapDivider(),
                            _recapRow(r, Icons.calendar_today_outlined, 'Date',
                                dateStr),
                            _recapDivider(),
                            _recapRow(r, Icons.shopping_bag_outlined, 'Produit',
                                product.title),
                            _recapDivider(),
                            _recapRow(
                                r, Icons.numbers_outlined, 'Quantité', '1'),
                            _recapDivider(),
                            _recapRow(r, Icons.payments_outlined, 'Prix total',
                                '$priceMain FCFA',
                                valueColor: AppTheme.primary, bold: true),
                            _recapDivider(),
                            _recapRowIcon(r, modeIcon, 'Livraison', modeLabel),
                            if (_mode == 'livraison' &&
                                _addressCtrl.text.isNotEmpty) ...[
                              _recapDivider(),
                              _recapRow(r, Icons.location_on_outlined,
                                  'Adresse', _addressCtrl.text),
                            ],
                            _recapDivider(),
                            _recapRow(r, Icons.credit_card_outlined, 'Paiement',
                                payLabel),
                            _recapDivider(),
                            _recapRow(r, Icons.phone_outlined, 'Téléphone',
                                _formattedPhone),
                            if (_noteCtrl.text.isNotEmpty) ...[
                              _recapDivider(),
                              _recapRow(r, Icons.notes_outlined, 'Note',
                                  _noteCtrl.text),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: r.s(28)),

                // ── 4. Boutons ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: r.s(54),
                  child: ElevatedButton.icon(
                    onPressed: () => Get.offAllNamed('/orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.rad(18))),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text('Voir mes commandes',
                        style: TextStyle(
                            fontSize: r.fs(15), fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(height: r.s(12)),
                SizedBox(
                  width: double.infinity,
                  height: r.s(48),
                  child: OutlinedButton.icon(
                    onPressed: () => Get.offAllNamed('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.foreground,
                      side: BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.rad(18))),
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: Text('Retour à l\'accueil',
                        style: TextStyle(
                            fontSize: r.fs(14), fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: r.s(16)),
              ],
            ),
          ),
        ),
      );
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
                color: AppTheme.cardColor,
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
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    // Image produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(10)),
                      child: CachedNetworkImage(
                        imageUrl: ApiConstants.resolveImageUrl(product.image),
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
                    // Badge quantité ou Sélecteur de quantité
                    if (product.stockType == 'unique')
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
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.muted.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(r.rad(8)),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(r.s(6)),
                                child: Icon(Icons.remove, size: r.s(16), color: AppTheme.foreground),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: r.s(8)),
                              child: Text(
                                '$_quantity',
                                style: TextStyle(
                                  fontSize: r.fs(13),
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.foreground,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_quantity < product.stock) {
                                  setState(() => _quantity++);
                                } else {
                                  AppToasts.warning(context, 'Stock limite', 'La quantité maximale disponible en stock est de ${product.stock}.');
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(r.s(6)),
                                child: Icon(Icons.add, size: r.s(16), color: AppTheme.foreground),
                              ),
                            ),
                          ],
                        ),
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
              Icon(Icons.person_outline,
                  size: r.s(18), color: AppTheme.primary),
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

            // Champ téléphone : +228 | numéro | ✓/✗ dynamique
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(
                  color: _phoneError != null
                      ? AppTheme.destructive
                      : AppTheme.border,
                ),
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
                        onChanged: (_) {
                          if (_phoneError != null)
                            setState(() => _phoneError = null);
                          setState(() {}); // refresh check icon
                        },
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
                    // Icône dynamique: ✓ vert si valide, ✗ rouge si invalide
                    Padding(
                      padding: EdgeInsets.only(right: r.s(12)),
                      child: _isPhoneValid
                          ? Icon(Icons.check_circle,
                              size: r.s(20), color: Colors.green.shade600)
                          : (_phoneCtrl.text.isNotEmpty
                              ? Icon(Icons.error_outline,
                                  size: r.s(20), color: AppTheme.destructive)
                              : Icon(Icons.phone_outlined,
                                  size: r.s(20),
                                  color: AppTheme.mutedForeground)),
                    ),
                  ],
                ),
              ),
            ),
            // Message d'erreur téléphone
            if (_phoneError != null)
              Padding(
                padding: EdgeInsets.only(top: r.s(6), left: r.s(4)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: r.s(14), color: AppTheme.destructive),
                    SizedBox(width: r.s(4)),
                    Expanded(
                      child: Text(
                        _phoneError!,
                        style: TextStyle(
                            fontSize: r.fs(12), color: AppTheme.destructive),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: r.s(14)),

            if (_mode == 'livraison') ...[
              Text(
                'ADRESSE DE LIVRAISON',
                style: TextStyle(
                    fontSize: r.fs(10),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                    letterSpacing: 0.7),
              ),
              SizedBox(height: r.s(7)),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _addressCtrl,
                  style:
                      TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(r.s(14)),
                    isDense: true,
                    hintText: 'Ex: Lomé, Quartier Tokoin, Villa 452',
                    hintStyle: TextStyle(
                        fontSize: r.fs(13), color: AppTheme.mutedForeground),
                  ),
                ),
              ),
              SizedBox(height: r.s(14)),

              // Carte interactive pour sélectionner la localisation
              Row(children: [
                Icon(Icons.map_outlined,
                    size: r.s(18), color: AppTheme.primary),
                SizedBox(width: r.s(7)),
                Text('Partager ma localisation',
                    style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground)),
              ]),
              SizedBox(height: r.s(4)),
              Text('Appuyez sur la carte ou utilisez le GPS',
                  style: TextStyle(
                      fontSize: r.fs(12), color: AppTheme.mutedForeground)),
              SizedBox(height: r.s(10)),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _deliveryLat != null && _deliveryLon != null
                                ? LatLng(_deliveryLat!, _deliveryLon!)
                                : const LatLng(6.137, 1.212),
                        initialZoom: 13.0,
                        minZoom: 6.0,
                        maxZoom: 18.0,
                        cameraConstraint: CameraConstraint.contain(
                          bounds: LatLngBounds(
                            const LatLng(5.9, -0.4),
                            const LatLng(11.3, 1.9),
                          ),
                        ),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                        onTap: (_, point) => _onMapTap(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.togomarket.app',
                        ),
                        if (_deliveryLat != null && _deliveryLon != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_deliveryLat!, _deliveryLon!),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on,
                                    color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Bouton GPS
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        heroTag: 'gps_delivery',
                        onPressed: _gpsLoading ? null : _requestGpsPosition,
                        backgroundColor: AppTheme.primary,
                        child: _gpsLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.my_location,
                                color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(14)),
            ],

            // Champ texte libre (note)
            Text(
              'NOTE OU PRÉCISIONS',
              style: TextStyle(
                  fontSize: r.fs(10),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedForeground,
                  letterSpacing: 0.7),
            ),
            SizedBox(height: r.s(7)),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style:
                    TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  isDense: true,
                  hintText:
                      'Indiquez l\'heure de passage ou précisions utiles...',
                  hintStyle: TextStyle(
                      fontSize: r.fs(13), color: AppTheme.mutedForeground),
                ),
              ),
            ),

            if (_mode == 'retrait') ...[
              SizedBox(height: r.s(22)),
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: r.s(18), color: AppTheme.primary),
                SizedBox(width: r.s(7)),
                Text('Lieu de retrait',
                    style: TextStyle(
                        fontSize: r.fs(15),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground)),
              ]),
              SizedBox(height: r.s(12)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.s(16)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: r.s(44),
                          height: r.s(44),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.storefront,
                              color: AppTheme.secondary, size: r.s(22)),
                        ),
                        SizedBox(width: r.s(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?.boutiqueObj?.nom ??
                                    (product != null
                                        ? (getSellerById(
                                                    product.sellerId.toString())
                                                ?.shopName ??
                                            'Boutique du vendeur')
                                        : 'Boutique du vendeur'),
                                style: TextStyle(
                                    fontSize: r.fs(14),
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.foreground),
                              ),
                              SizedBox(height: r.s(2)),
                              Text(
                                product?.boutiqueObj?.adresse ??
                                    product?.boutiqueObj?.detailsAdresse ??
                                    (product != null
                                        ? (getSellerById(
                                                    product.sellerId.toString())
                                                ?.location ??
                                            'Lomé, Togo')
                                        : 'Lomé, Togo'),
                                style: TextStyle(
                                    fontSize: r.fs(12),
                                    color: AppTheme.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: r.s(12)),
                    // Mini-carte boutique (lecture seule)
                    if (product?.boutiqueObj != null &&
                        product!.boutiqueObj!.latitude != 0 &&
                        product.boutiqueObj!.longitude != 0)
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(r.rad(12)),
                          border: Border.all(color: AppTheme.border),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(product.boutiqueObj!.latitude,
                                product.boutiqueObj!.longitude),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.togomarket.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(product.boutiqueObj!.latitude,
                                      product.boutiqueObj!.longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.storefront,
                                      color: Colors.deepOrange, size: 36),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: r.s(12)),
                    // Bouton Voir Itinéraire
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final boutique = product?.boutiqueObj;
                          Uri? uri;
                          String locationQuery = '';

                          if (boutique != null &&
                              boutique.latitude != 0 &&
                              boutique.longitude != 0) {
                            locationQuery =
                                '${boutique.latitude},${boutique.longitude}';
                          } else if (boutique != null &&
                              (boutique.detailsAdresse?.isNotEmpty == true ||
                                  boutique.adresse?.isNotEmpty == true)) {
                            final parts = [
                              if (boutique.detailsAdresse?.isNotEmpty == true)
                                boutique.detailsAdresse!,
                              if (boutique.adresse?.isNotEmpty == true)
                                boutique.adresse!
                            ];
                            locationQuery = parts.join(', ');
                          } else {
                            final seller = getSellerById(
                                product?.sellerId?.toString() ?? '');
                            if (seller != null && seller.location.isNotEmpty) {
                              locationQuery = seller.location;
                            }
                          }

                          if (locationQuery.isNotEmpty) {
                            uri = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationQuery)}');
                            try {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              AppToasts.error(context, 'Erreur',
                                  'Impossible d\'ouvrir Google Maps.');
                            }
                          } else {
                            AppToasts.info(context, 'Information',
                                'La position du vendeur n\'est pas renseignée.');
                          }
                        },
                        icon: Icon(Icons.directions_outlined, size: r.s(18)),
                        label: Text('Voir l\'itinéraire sur Maps'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondary,
                          side: BorderSide(color: AppTheme.secondary),
                          padding: EdgeInsets.symmetric(vertical: r.s(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: r.s(14)),

            SizedBox(height: r.s(22)),
            Row(children: [
              Icon(Icons.credit_card_outlined,
                  size: r.s(18), color: AppTheme.primary),
              SizedBox(width: r.s(7)),
              Text('Mode de paiement',
                  style: TextStyle(
                      fontSize: r.fs(15),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(12)),

            _OrderModeOption(
              value: 'livraison',
              groupValue: _paymentMode,
              title: _mode == 'livraison'
                  ? 'Paiement à la livraison'
                  : 'Paiement au moment du retrait',
              subtitle: 'Payez en espèces ou mobile money à la réception',
              onTap: () => setState(() => _paymentMode = 'livraison'),
              r: r,
            ),
            SizedBox(height: r.s(10)),
            _OrderModeOption(
              value: 'entente',
              groupValue: _paymentMode,
              title: 'Entente avec le vendeur',
              subtitle: 'Discutez en messagerie pour une avance (ex: 50%)',
              onTap: () => setState(() => _paymentMode = 'entente'),
              r: r,
            ),
          ],
        ),
      ),

      // ── 5. Footer fixe : ligne séparatrice + total + bouton + note ─────────
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(14), r.hPad,
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
                        text: product != null ? '$totalPriceMain ' : '0 ',
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

            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      if (!_validatePhone()) return;

                      if (_mode == 'livraison' &&
                          _addressCtrl.text.trim().isEmpty) {
                        AppToasts.error(context, 'Adresse requise',
                            'Veuillez renseigner votre adresse de livraison.');
                        return;
                      }

                      // ── Dialogue de confirmation ──────────────────────────────
                      final userConfirmed =
                          await _showConfirmationDialog(product, priceMain, totalPriceMain);
                      if (!userConfirmed) return;
                      setState(() => _isLoading = true);
                      try {
                        // 1. Créer la commande sur le backend
                        final orderResp = await _orderService.createOrder(
                          productId:
                              int.tryParse(product.id?.toString() ?? '0') ?? 1,
                          quantity: _quantity,
                          paymentMethod: _paymentMode,
                          deliveryMethod: _mode,
                          deliveryAddress: _addressCtrl.text,
                          deliveryLat: _deliveryLat,
                          deliveryLon: _deliveryLon,
                          phone: _formattedPhone,
                          notes: _noteCtrl.text,
                        );
                        _orderResult =
                            orderResp['order'] as Map<String, dynamic>?;

                        // 2. Envoyer le résumé de commande dans la messagerie
                        final currentUser =
                            Get.find<AuthController>().currentUser.value;
                        final senderId = currentUser?.id.toString() ?? '';

                        // ⚠️ Utiliser boutique.id si disponible (même logique que "Discuter")
                        // sinon product.sellerId (user_id). Sans ça = 2 conversations séparées.
                        final sellerId = product.boutiqueObj != null
                            ? product.boutiqueObj!.id.toString()
                            : product.sellerId.toString();

                        if (senderId.isNotEmpty && sellerId.isNotEmpty) {
                          final orderId =
                              _orderResult?['id']?.toString() ?? '-';
                          final orderDate = DateTime.now();
                          final dateStr =
                              '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year} à ${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}';
                          final modeLabel = _mode == 'livraison'
                              ? 'Livraison à domicile'
                              : 'Retrait en boutique';
                          final payLabel = _paymentMode == 'livraison'
                              ? 'À la livraison / retrait'
                              : 'Entente en messagerie';

                          // Données structurées encodées en JSON dans le contenu
                          // → La bulle de chat les décodera pour afficher une card identique
                          final orderData = {
                            'order_id': orderId,
                            'date': dateStr,
                            'product_title': product.title,
                            'product_image': product.image,
                            'quantity': '$_quantity',
                            'total': '$totalPriceMain FCFA',
                            'mode': modeLabel,
                            'address': (_mode == 'livraison' &&
                                    _addressCtrl.text.isNotEmpty)
                                ? _addressCtrl.text
                                : '',
                            'payment': payLabel,
                            'phone': _formattedPhone,
                            'note': _noteCtrl.text,
                            'status': 'En attente',
                          };
                          // Sérialiser en JSON simple (sans dart:convert pour éviter les imports)
                          final jsonContent = orderData.entries
                              .map((e) =>
                                  '"${e.key}":"${e.value.replaceAll('"', '\\"')}"')
                              .join(',');
                          final orderJsonMessage = '{$jsonContent}';

                          // Créer la session si elle n'existe pas encore
                          final buyerName = currentUser?.nom ??
                              currentUser?.email ??
                              'Acheteur';
                          final buyerAvatar = currentUser?.avatarUrl ?? '';
                          final sellerName = product.boutiqueObj?.nom ??
                              product.userObj?.nom ??
                              'Vendeur';
                          final sellerAvatar = product.boutiqueObj?.logoUrl ??
                              product.userObj?.avatarUrl ??
                              '';

                          final chatId = await _chatService.getOrCreateChat(
                            myId: senderId,
                            myName: buyerName,
                            myAvatar: buyerAvatar,
                            otherId: sellerId,
                            otherName: sellerName,
                            otherAvatar: sellerAvatar,
                            productId: product.id.toString(),
                            productTitle: product.title,
                            productImage: product.image,
                          );

                          await _chatService.sendMessage(
                            chatId,
                            senderId,
                            sellerId,
                            orderJsonMessage,
                            isBuyerSending: true,
                            type: 'order', // type spécial pour le rendu card
                          );
                        }

                        AppToasts.success(context, 'Succès',
                            'Votre commande a été transmise au vendeur.');
                        setState(() {
                          _isLoading = false;
                          _confirmed = true;
                        });
                        _startCountdown();
                      } catch (e) {
                        setState(() => _isLoading = false);
                        AppToasts.error(
                            context, 'Échec de la commande', e.toString());
                      }
                    },
              child: Container(
                width: double.infinity,
                height: r.s(54).clamp(50.0, 62.0),
                decoration: BoxDecoration(
                  color: _isLoading ? AppTheme.muted : AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(30)),
                  boxShadow: _isLoading ? [] : AppTheme.shadowPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    else ...[
                      Text('Confirmer la commande',
                          style: TextStyle(
                              fontSize: r.fs(15),
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(width: r.s(6)),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: r.s(13), color: Colors.white),
                    ]
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
          // Fond dynamique selon le thème et l'état
          color: active ? AppTheme.primaryLight : AppTheme.cardColor,
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
                        decoration: BoxDecoration(
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
