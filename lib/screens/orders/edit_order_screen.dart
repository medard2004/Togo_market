import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';

import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/config/api_constants.dart';
import '../../controllers/order_controller.dart';
import '../map/unified_map_screen.dart';

class EditOrderScreen extends StatefulWidget {
  final OrderModel order;
  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> with WidgetsBindingObserver {
  late int _quantity;
  double? _deliveryLat;
  double? _deliveryLon;
  int? _deliveryVilleId;
  String? _phoneError;
  bool _isLoading = false;
  bool _gpsLoading = false;
  bool _waitingForLocationActivation = false;

  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _quantity = widget.order.quantity;
    _deliveryLat = widget.order.deliveryLat;
    _deliveryLon = widget.order.deliveryLon;

    // Pre-fill phone
    String phone = widget.order.phone ?? '';
    phone = phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('+228')) phone = phone.substring(4);
    if (phone.startsWith('228') && phone.length > 8) phone = phone.substring(3);
    _phoneCtrl.text = phone;

    _addressCtrl.text = widget.order.deliveryAddress ?? '';
    _noteCtrl.text = widget.order.notes ?? '';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    _quartierCtrl.dispose();
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

  bool _validatePhone() {
    final clean = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) {
      setState(() => _phoneError = 'Le numéro est requis');
      return false;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(clean)) {
      setState(() => _phoneError = 'Le numéro togolais doit contenir exactement 8 chiffres');
      return false;
    }
    setState(() => _phoneError = null);
    return true;
  }

  bool get _isPhoneValid {
    final clean = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^\d{8}$').hasMatch(clean);
  }

  String get _formattedPhone => '+228${_phoneCtrl.text.replaceAll(RegExp(r'\s+'), '')}';

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
        if (permission == LocationPermission.denied) throw Exception("Permission refusée");
      }
      if (permission == LocationPermission.deniedForever) throw Exception("Permission refusée définitivement");

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _deliveryLat = position.latitude;
          _deliveryLon = position.longitude;
          _gpsLoading = false;
        });
        _reverseGeocodeAndFillAddress(position.latitude, position.longitude);
        AppToasts.success(context, 'Localisation récupérée', 'Votre position a été mise à jour.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _gpsLoading = false);
        AppToasts.error(context, 'Erreur GPS', 'Impossible de récupérer votre position.');
      }
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
                child: Icon(Icons.location_disabled, color: Colors.orange, size: r.s(24)),
              ),
              SizedBox(height: r.s(16)),
              Text('Localisation désactivée',
                style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w800, color: AppTheme.foreground),
              ),
              SizedBox(height: r.s(8)),
              Text('La géolocalisation est nécessaire pour partager votre position. Vous pouvez aussi sélectionner votre adresse manuellement sur la carte.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground, height: 1.4),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(14))),
                      ),
                      child: Text('Plus tard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: r.fs(14))),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(14))),
                      ),
                      child: Text('Activer le GPS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: r.fs(14))),
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

  Future<void> _reverseGeocodeAndFillAddress(double lat, double lon) async {
    try {
      final authCtrl = Get.find<AuthController>();
      final location = await authCtrl.getCurrentLocationAndMatch(lat: lat, lon: lon);
      if (location != null && mounted) {
        setState(() {
          if (location['villeId'] != null) {
            _deliveryVilleId = location['villeId'];
          }
          final rawQuartier = location['rawQuartier']?.toString() ?? '';
          if (rawQuartier.isNotEmpty) {
            _quartierCtrl.text = rawQuartier.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');
          }
        });
      }
    } catch (_) {}
  }

  String _buildDeliveryAddressString() {
    final authCtrl = Get.find<AuthController>();
    String parts = '';
    if (_deliveryVilleId != null) {
      final ville = authCtrl.locations.firstWhereOrNull((v) => v.id == _deliveryVilleId);
      if (ville != null) {
        parts = ville.nom;
        if (_quartierCtrl.text.trim().isNotEmpty) {
          parts += ', ${_quartierCtrl.text.trim()}';
        }
      }
    }
    if (_addressCtrl.text.trim().isNotEmpty) {
      parts += (parts.isNotEmpty ? ' – ' : '') + _addressCtrl.text.trim();
    }
    return parts;
  }

  Future<void> _submit() async {
    if (!_validatePhone()) return;

    setState(() => _isLoading = true);
    final data = <String, dynamic>{
      'quantity': _quantity,
      'phone': _formattedPhone,
      'notes': _noteCtrl.text,
    };
    
    final newAddress = _buildDeliveryAddressString();
    if (newAddress.isNotEmpty) {
      data['delivery_address'] = newAddress;
    } else {
       data['delivery_address'] = _addressCtrl.text;
    }
    
    if (_deliveryLat != null) data['delivery_lat'] = _deliveryLat;
    if (_deliveryLon != null) data['delivery_lon'] = _deliveryLon;

    await OrderController.to.updateBuyerOrder(context, widget.order, data);
    setState(() => _isLoading = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final product = widget.order.product;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text('Modifier la commande',
            style: TextStyle(fontSize: r.fs(16), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(8), r.hPad, r.s(160)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.titre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
                          SizedBox(height: r.s(5)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.order.totalPrice} ',
                                  style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w800, color: AppTheme.primary, fontFamily: 'PlusJakartaSans'),
                                ),
                                TextSpan(
                                  text: 'FCFA',
                                  style: TextStyle(fontSize: r.fs(11), fontWeight: FontWeight.w600, color: AppTheme.primary, fontFamily: 'PlusJakartaSans'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              if (_quantity > 1) setState(() => _quantity--);
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
                              style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w700, color: AppTheme.foreground),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _quantity++),
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

            // Vos coordonnées
            Row(children: [
              Icon(Icons.person_outline, size: r.s(18), color: AppTheme.primary),
              SizedBox(width: r.s(7)),
              Text('Vos coordonnées',
                  style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(14)),

            Text('NUMÉRO DE TÉLÉPHONE',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground, letterSpacing: 0.7)),
            SizedBox(height: r.s(7)),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: _phoneError != null ? AppTheme.destructive : AppTheme.border),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.s(14)),
                      decoration: BoxDecoration(border: Border(right: BorderSide(color: AppTheme.border))),
                      alignment: Alignment.center,
                      child: Text('+228', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w500, color: AppTheme.foreground)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) {
                          if (_phoneError != null) setState(() => _phoneError = null);
                          setState(() {});
                        },
                        style: TextStyle(fontSize: r.fs(14), color: AppTheme.foreground),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(14)),
                          isDense: true,
                          hintText: '90 00 00 00',
                          hintStyle: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: r.s(12)),
                      child: _isPhoneValid
                          ? Icon(Icons.check_circle, size: r.s(20), color: Colors.green.shade600)
                          : (_phoneCtrl.text.isNotEmpty
                              ? Icon(Icons.error_outline, size: r.s(20), color: AppTheme.destructive)
                              : Icon(Icons.phone_outlined, size: r.s(20), color: AppTheme.mutedForeground)),
                    ),
                  ],
                ),
              ),
            ),
            if (_phoneError != null)
              Padding(
                padding: EdgeInsets.only(top: r.s(6), left: r.s(4)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: r.s(14), color: AppTheme.destructive),
                    SizedBox(width: r.s(4)),
                    Expanded(child: Text(_phoneError!, style: TextStyle(fontSize: r.fs(12), color: AppTheme.destructive))),
                  ],
                ),
              ),

            SizedBox(height: r.s(14)),
            
            Text('ADRESSE DE LIVRAISON',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground, letterSpacing: 0.7)),
            SizedBox(height: r.s(7)),
            
            Text('Ville / Commune',
                style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
            SizedBox(height: r.s(5)),
            Obx(() {
              final authCtrl = Get.find<AuthController>();
              final villes = authCtrl.locations;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: r.s(12)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _deliveryVilleId,
                    isExpanded: true,
                    hint: Text('Sélectionner une ville', style: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground)),
                    items: villes.map((v) => DropdownMenuItem(value: v.id, child: Text(v.nom))).toList(),
                    onChanged: (v) => setState(() => _deliveryVilleId = v),
                  ),
                ),
              );
            }),
            SizedBox(height: r.s(10)),

            if (_deliveryVilleId != null) ...[
              Text('Quartier / Zone',
                  style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
              SizedBox(height: r.s(5)),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _quartierCtrl,
                  style: TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(r.s(14)),
                    isDense: true,
                    hintText: 'Saisissez votre quartier',
                    hintStyle: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground),
                  ),
                ),
              ),
              SizedBox(height: r.s(10)),
            ],

            Text('Détails',
                style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
            SizedBox(height: r.s(5)),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _addressCtrl,
                style: TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  isDense: true,
                  hintText: 'Ex: Derrière la station Total, portail bleu...',
                  hintStyle: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground),
                ),
              ),
            ),
            SizedBox(height: r.s(14)),

            // Carte GPS
            Row(children: [
              Icon(Icons.map_outlined, size: r.s(18), color: AppTheme.primary),
              SizedBox(width: r.s(7)),
              Text('Partager ma localisation',
                  style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(4)),
            Text('Sélectionnez votre position sur la carte pour plus de précision',
                style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
            SizedBox(height: r.s(10)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => UnifiedMapScreen(
                        initialLat: _deliveryLat,
                        initialLon: _deliveryLon,
                      ));
                  if (result != null && result is Map) {
                    setState(() {
                      _deliveryLat = result['latitude'];
                      _deliveryLon = result['longitude'];
                      if (result['address'] != null &&
                          result['address'].toString().isNotEmpty &&
                          _addressCtrl.text.isEmpty &&
                          result['address'] != "Recherche de l'adresse...") {
                        _addressCtrl.text = result['address'];
                      }
                    });
                    _reverseGeocodeAndFillAddress(result['latitude'], result['longitude']);
                  }
                },
                icon: Icon(Icons.location_on, color: AppTheme.primary),
                label: Text(_deliveryLat != null ? 'Modifier la localisation' : 'Choisir ma localisation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(vertical: r.s(14)),
                  side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(12))),
                ),
              ),
            ),
            if (_deliveryLat != null)
              Padding(
                padding: EdgeInsets.only(top: r.s(8)),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: r.s(14)),
                    SizedBox(width: r.s(6)),
                    Text('Position enregistrée', style: TextStyle(color: Colors.green, fontSize: r.fs(12))),
                  ],
                ),
              ),
            SizedBox(height: r.s(22)),

            Text('NOTE OU PRÉCISIONS',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground, letterSpacing: 0.7)),
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
                style: TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  isDense: true,
                  hintText: 'Indiquez l\'heure de passage ou précisions utiles...',
                  hintStyle: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(16), r.hPad, r.s(20) + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: r.s(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(16))),
            ),
            child: _isLoading
                ? SizedBox(width: r.s(20), height: r.s(20), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: r.fs(15))),
          ),
        ),
      ),
    );
  }
}
