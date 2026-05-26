import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../map/unified_map_screen.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/core/api_client.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/provider/auth_controller.dart';
import '../../utils/app_toasts.dart';
import '../../utils/image_optimization_service.dart';
import '../../utils/category_icon_helper.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  String? _bannerPath;
  String? _logoPath;

  int? _villeId;
  int? _quartierId;
  List<String> _selectedCategoryIds = [];

  TimeOfDay? _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  List<String> _selectedDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  Map<String, dynamic> _errors = {};
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isPickingImage = false;
  bool _gpsLoading = false;
  double? _latitude;
  double? _longitude;
  List<AppCategory> _dbCategories = [];
  final ImagePicker _picker = ImagePicker();


  late Boutique _boutique;
  late final AuthController _authCtrl;

  @override
  void initState() {
    super.initState();
    _authCtrl = Get.find<AuthController>();
    _boutique = BoutiqueController.to.myBoutique.value!;
    _initFromBoutique();
    _fetchCategories();
  }

  void _initFromBoutique() {
    _nameCtrl.text = _boutique.nom;
    _descCtrl.text = _boutique.description;
    _phoneCtrl.text = _boutique.telephone;
    _phone2Ctrl.text = (_boutique.contacts != null && _boutique.contacts!.isNotEmpty)
        ? _boutique.contacts!.first.toString()
        : '';
    _detailsCtrl.text = _boutique.detailsAdresse ?? '';

    final adresse = _boutique.adresse ?? '';
    if (adresse.isNotEmpty) {
      for (var v in _authCtrl.locations) {
        if (v.nom.toLowerCase() == adresse.toLowerCase()) {
          _villeId = v.id;
          break;
        }
      }
    }
    
    _latitude = _boutique.latitude;
    _longitude = _boutique.longitude;

    if (_boutique.horaires is Map) {
      final h = _boutique.horaires as Map;
      final ouv = h['ouverture']?.toString();
      final fer = h['fermeture']?.toString();
      final jours = h['jours'];

      if (ouv != null && ouv.contains(':')) {
        final parts = ouv.split(':');
        _openingTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      if (fer != null && fer.contains(':')) {
        final parts = fer.split(':');
        _closingTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 18,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      if (jours is List) {
        _selectedDays = List<String>.from(jours.map((e) => e.toString()));
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Get.find<ApiClient>().get(ApiConstants.categoriesEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (mounted) {
          setState(() {
            _dbCategories = data.map((e) {
              final nom = e['name'].toString();
              final IconData iconData = CategoryIconHelper.getIconFromString(e['icon']?.toString());
              return AppCategory(id: e['id'].toString(), label: nom, icon: iconData);
            }).toList();

            if (_boutique.categories != null) {
              _selectedCategoryIds = _boutique.categories!
                  .map((c) => c['id'].toString())
                  .toList();
            }
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    String cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('00')) {
      return '+228$cleanPhone';
    }
    return cleanPhone;
  }

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

  Future<void> _pickImage(bool isBanner) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        final optimizedFile = await ImageOptimizationService.optimizeImage(File(pickedFile.path));
        
        setState(() {
          if (isBanner) {
            _bannerPath = optimizedFile.path;
          } else {
            _logoPath = optimizedFile.path;
          }
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _pickTime(bool isOpening) async {
    final initialTime = isOpening
        ? (_openingTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_closingTime ?? const TimeOfDay(hour: 18, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isOpening ? 'Heure d\'ouverture' : 'Heure de fermeture',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.foreground,
              surface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.border.withOpacity(0.3), width: 0.5),
              ),
              hourMinuteColor: AppTheme.primary.withOpacity(0.08),
              hourMinuteTextColor: AppTheme.primary,
              dayPeriodTextColor: AppTheme.primary,
              dayPeriodColor: AppTheme.primary.withOpacity(0.15),
              dialBackgroundColor: AppTheme.primary.withOpacity(0.1),
              dialHandColor: AppTheme.primary,
              dialTextColor: AppTheme.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) _openingTime = picked;
        else _closingTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _performReverseGeocoding(double lat, double lon) async {
    final location = await _authCtrl.getCurrentLocationAndMatch(lat: lat, lon: lon);
    if (location != null && mounted) {
      setState(() {
        _villeId = location['villeId'];
        _quartierId = location['quartierId'];
      });
      AppToasts.success(context, "Position trouvée", "Votre zone a été pré-remplie.");
    }
  }

  Future<void> _requestGpsPosition() async {
    setState(() { _gpsLoading = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) AppToasts.error(context, 'Erreur GPS', 'Services de localisation désactivés');
        setState(() { _gpsLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) AppToasts.error(context, 'Erreur GPS', 'Permission refusée');
          setState(() { _gpsLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) AppToasts.error(context, 'Erreur GPS', 'Permission refusée définitivement');
        setState(() { _gpsLoading = false; });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gpsLoading = false;
      });

      if (mounted) AppToasts.success(context, 'GPS', 'Position détectée avec succès');
      
      _performReverseGeocoding(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) AppToasts.error(context, 'Erreur GPS', e.toString().substring(0, 50));
      setState(() { _gpsLoading = false; });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  bool get _isFormValid {
    return _nameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _selectedCategoryIds.isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _openingTime != null &&
        _closingTime != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header with Images
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppBackButton(onTap: () => Get.back()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner Image
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: _bannerPath != null
                        ? Image.file(File(_bannerPath!), fit: BoxFit.cover)
                        : (_boutique.bannerUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _resolveUrl(_boutique.bannerUrl),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppTheme.primaryLight,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.panorama_outlined, size: 40, color: AppTheme.primary.withOpacity(0.5)),
                                      const SizedBox(height: 8),
                                      Text('Ajouter une bannière', style: TextStyle(color: AppTheme.primary.withOpacity(0.8), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              )),
                  ),
                  // Gradient Overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  // Banner Edit Icon
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  // Logo Avatar
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.cardColor,
                              backgroundImage: (_logoPath != null
                                  ? FileImage(File(_logoPath!))
                                  : (_boutique.logoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(_resolveUrl(_boutique.logoUrl))
                                      : null)) as ImageProvider?,
                              child: _logoPath == null && _boutique.logoUrl.isEmpty
                                  ? const Icon(Icons.storefront, size: 40, color: AppTheme.primary)
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoadingCategories
                ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: 'Informations Générales',
                          icon: Icons.info_outline,
                          children: [
                            _buildModernTextField(
                              label: 'Nom de la boutique *',
                              controller: _nameCtrl,
                              hint: 'Ex: Ma Super Boutique',
                              errorText: _errors['nom'],
                              onChanged: (_) {
                                if (_errors.containsKey('nom')) setState(() => _errors.remove('nom'));
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              label: 'Description',
                              controller: _descCtrl,
                              hint: 'Ex: Produits de qualité et livraison rapide.',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              label: 'Téléphone Principal *',
                              controller: _phoneCtrl,
                              hint: 'Ex: 90 00 00 00',
                              keyboardType: TextInputType.phone,
                              errorText: _errors['telephone'],
                              onChanged: (_) {
                                if (_errors.containsKey('telephone')) setState(() => _errors.remove('telephone'));
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              label: 'Téléphone / Contact 2',
                              controller: _phone2Ctrl,
                              hint: 'Ex: 99 00 00 00',
                              keyboardType: TextInputType.phone,
                              errorText: _errors['contacts.0'] ?? _errors['contacts'],
                              onChanged: (_) {
                                if (_errors.containsKey('contacts.0')) setState(() => _errors.remove('contacts.0'));
                                if (_errors.containsKey('contacts')) setState(() => _errors.remove('contacts'));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        _buildSectionCard(
                          title: 'Catégories de produits *',
                          icon: Icons.category_outlined,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _dbCategories.map((c) {
                                final isSelected = _selectedCategoryIds.contains(c.id);
                                return FilterChip(
                                  label: Text(c.label),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.foreground,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategoryIds.add(c.id);
                                      } else {
                                        _selectedCategoryIds.remove(c.id);
                                      }
                                    });
                                  },
                                  backgroundColor: AppTheme.background,
                                  selectedColor: AppTheme.primary,
                                  checkmarkColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildSectionCard(
                          title: 'Jours et Horaires d\'ouverture *',
                          icon: Icons.schedule_outlined,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _days.map((day) {
                                final isSelected = _selectedDays.contains(day);
                                return GestureDetector(
                                  onTap: () => _toggleDay(day),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primary : AppTheme.background,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : AppTheme.foreground,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerTile(
                                    title: 'Ouverture',
                                    time: _openingTime,
                                    icon: Icons.wb_sunny_outlined,
                                    color: Colors.orange,
                                    onTap: () => _pickTime(true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePickerTile(
                                    title: 'Fermeture',
                                    time: _closingTime,
                                    icon: Icons.nights_stay_outlined,
                                    color: Colors.indigo,
                                    onTap: () => _pickTime(false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildSectionCard(
                          title: 'Localisation',
                          icon: Icons.place_outlined,
                          children: [
                            Obx(() {
                              final villes = _authCtrl.locations;
                              return _buildModernDropdown(
                                label: 'Ville / Commune *',
                                value: _villeId,
                                items: villes.map((v) => DropdownMenuItem(value: v.id, child: Text(v.nom))).toList(),
                                onChanged: (v) => setState(() { _villeId = v; _quartierId = null; }),
                              );
                            }),
                            const SizedBox(height: 16),
                            if (_villeId != null) ...[
                              Obx(() {
                                final ville = _authCtrl.locations.firstWhereOrNull((v) => v.id == _villeId);
                                final quartiers = ville?.quartiers ?? [];
                                
                                if (_quartierId != null && !quartiers.any((q) => q.id == _quartierId)) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) setState(() => _quartierId = null);
                                  });
                                }

                                return _buildModernDropdown(
                                  label: 'Quartier *',
                                  value: _quartierId,
                                  items: quartiers.map((q) => DropdownMenuItem(value: q.id, child: Text(q.nom))).toList(),
                                  onChanged: (v) => setState(() => _quartierId = v),
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                            _buildModernTextField(
                              label: 'Détails supplémentaires (facultatif)',
                              controller: _detailsCtrl,
                              hint: 'Ex: Derrière la pharmacie XYZ...',
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await Get.to(() => UnifiedMapScreen(
                                        initialLat: _latitude,
                                        initialLon: _longitude,
                                      ));
                                  if (result != null && result is Map) {
                                    setState(() {
                                      _latitude = result['latitude'];
                                      _longitude = result['longitude'];
                                    });
                                    _performReverseGeocoding(result['latitude'], result['longitude']);
                                  }
                                },
                                icon: Icon(Icons.location_on, color: AppTheme.primary),
                                label: Text(_latitude != null ? 'Modifier la localisation' : 'Choisir ma localisation'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            if (_latitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                    const SizedBox(width: 6),
                                    const Text('Position sélectionnée', style: TextStyle(color: Colors.green, fontSize: 12)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Bouton d'enregistrement
                        Opacity(
                          opacity: (_isFormValid && !_isLoading) ? 1.0 : 0.5,
                          child: AppButton(
                            label: _isLoading ? 'Enregistrement en cours...' : 'Enregistrer les modifications',
                            icon: _isLoading ? Icons.hourglass_empty : Icons.save_outlined,
                            onTap: (_isFormValid && !_isLoading) ? _saveShopChanges : () {},
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.foreground)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    dynamic errorText,
    Function(String)? onChanged,
  }) {
    final String? parsedError = errorText != null
        ? (errorText is List ? errorText.join('\n') : errorText.toString())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.foreground)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: parsedError,
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.destructive),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.foreground)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: const Text('Sélectionner'),
              items: items,
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required TimeOfDay? time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(_formatTime(time), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveShopChanges() async {
    setState(() {
      _errors.clear();
      _isLoading = true;
    });

    final telephoneFormatted = _formatPhoneNumber(_phoneCtrl.text.trim());
    final phone2Raw = _phone2Ctrl.text.trim();
    final phone2Formatted = _formatPhoneNumber(phone2Raw);

    if (phone2Formatted.isNotEmpty && telephoneFormatted == phone2Formatted) {
      setState(() {
        _errors['contacts.0'] = 'Le contact secondaire ne peut pas être identique au principal.';
        _isLoading = false;
      });
      return;
    }

    final List<String> contacts = phone2Formatted.isNotEmpty ? [phone2Formatted] : [];

    final ville = _authCtrl.locations.firstWhereOrNull((v) => v.id == _villeId);
    final villeNom = ville?.nom ?? '';
    final adresseComplete = villeNom;

    final payload = {
      'nom': _nameCtrl.text.trim(),
      'telephone': telephoneFormatted,
      'adresse': adresseComplete,
      'quartier_id': _quartierId,
      'details_adresse': _detailsCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'contacts': contacts,
      'horaires': {
        'jours': _selectedDays,
        'ouverture': _formatTime(_openingTime),
        'fermeture': _formatTime(_closingTime),
      },
      'categories': _selectedCategoryIds,
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
      if (_bannerPath != null) 'bannerPath': _bannerPath,
      if (_logoPath != null) 'logoPath': _logoPath,
    };

    try {
      final result = await BoutiqueController.to.updateBoutique(payload);
      if (result == true) {
        AppToasts.success(context, 'Succès', 'Votre boutique a été modifiée avec succès.');
        Get.back();
      } else if (result is Map) {
        setState(() {
          _errors = Map<String, dynamic>.from(result);
        });
        AppToasts.error(context, 'Erreur de validation', 'Veuillez corriger les erreurs dans le formulaire.');
      } else {
        AppToasts.error(context, 'Erreur', 'Une erreur inattendue est survenue.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
