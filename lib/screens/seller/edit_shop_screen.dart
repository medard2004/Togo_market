import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart'; // Used for AppCategory (UI model)
import '../../Api/model/boutique_model.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/core/api_client.dart';
import '../../Api/config/api_constants.dart';
import '../../utils/app_toasts.dart';

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

  String _zone = 'Tokoin';
  List<String> _selectedCategoryIds = [];

  TimeOfDay? _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  List<String> _selectedDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  Map<String, dynamic> _errors = {};
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isPickingImage = false;
  List<AppCategory> _dbCategories = [];
  final ImagePicker _picker = ImagePicker();

  late Boutique _boutique;

  final _zones = [
    'Tokoin',
    'Avépozo',
    'Adidogomé',
    'Bè',
    'Kégué',
    'Nyékonakpoè',
    'Agbalépédo',
    'Amadahomé',
    'Agoè',
    'Legbassito',
  ];

  @override
  void initState() {
    super.initState();
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

    // Préremplir la zone si elle correspond à une valeur connue
    final adresse = _boutique.adresse ?? '';
    if (_zones.contains(adresse)) {
      _zone = adresse;
    }

    // Préremplir les horaires
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
        _selectedDays = List<String>.from(jours);
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
              final nom = e['nom'].toString();
              IconData iconData = Icons.category_rounded;
              if (e['slug'] == 'mode') iconData = Icons.shopping_bag_rounded;
              else if (e['slug'] == 'beaute-sante') iconData = Icons.face_retouching_natural_rounded;
              else if (e['slug'] == 'electronique') iconData = Icons.devices_rounded;
              else if (e['slug'] == 'alimentation') iconData = Icons.restaurant_rounded;
              else if (e['slug'] == 'maison-decoration') iconData = Icons.home_rounded;
              else if (e['slug'] == 'immobilier') iconData = Icons.apartment_rounded;
              else if (e['slug'] == 'vehicules') iconData = Icons.directions_car_rounded;
              else if (e['slug'] == 'services') iconData = Icons.build_rounded;

              return AppCategory(id: e['id'].toString(), label: nom, icon: iconData);
            }).toList();

            // Préremplir les catégories existantes
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
    if (url.startsWith('/storage/')) {
      final baseUrl = ApiConstants.baseUrl;
      final rootUrl = baseUrl.endsWith('/api')
          ? baseUrl.substring(0, baseUrl.length - 4)
          : baseUrl;
      return '$rootUrl$url';
    }
    return url;
  }

  Future<void> _pickImage(bool isBanner) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          if (isBanner) {
            _bannerPath = pickedFile.path;
          } else {
            _logoPath = pickedFile.path;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Modifier la boutique'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: Get.back,
          ),
          centerTitle: true,
        ),
        body: _isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover & Avatar
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(true),
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(16),
                                image: _bannerPath != null
                                    ? DecorationImage(
                                        image: FileImage(File(_bannerPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : (_boutique.bannerUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(_resolveUrl(_boutique.bannerUrl)),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                              ),
                              child: _bannerPath == null && _boutique.bannerUrl.isEmpty
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.panorama_outlined,
                                            size: 40,
                                            color: AppTheme.primary.withOpacity(0.5)),
                                        const SizedBox(height: 8),
                                        Text('Ajouter une bannière',
                                            style: TextStyle(
                                                color: AppTheme.primary.withOpacity(0.7),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    )
                                  : Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white.withOpacity(0.8),
                                          child: const Icon(Icons.edit, color: AppTheme.primary),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            child: GestureDetector(
                              onTap: () => _pickImage(false),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.background,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.cardColor,
                                  backgroundImage: (_logoPath != null
                                      ? FileImage(File(_logoPath!))
                                      : (_boutique.logoUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(_resolveUrl(_boutique.logoUrl))
                                          : null)) as ImageProvider?,
                                  child: _logoPath == null && _boutique.logoUrl.isEmpty
                                      ? const Icon(Icons.storefront,
                                          size: 40, color: AppTheme.primary)
                                      : const Align(
                                          alignment: Alignment.bottomRight,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: AppTheme.primary,
                                            child: Icon(Icons.edit, size: 14, color: Colors.white),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Nom de la boutique
                    const Text('Nom de la boutique *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      onChanged: (_) {
                        if (_errors.containsKey('nom')) setState(() => _errors.remove('nom'));
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: Ma Super Boutique',
                        errorText: _errors['nom'] != null
                            ? (_errors['nom'] is List ? _errors['nom'].join('\n') : _errors['nom'].toString())
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Catégorie de produits *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
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
                          backgroundColor: AppTheme.cardColor,
                          selectedColor: AppTheme.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Description',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Ex: Produits de qualité et livraison rapide.'),
                    ),
                    const SizedBox(height: 16),

                    // Téléphone Principal
                    const Text('Téléphone Principal *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) {
                        if (_errors.containsKey('telephone')) setState(() => _errors.remove('telephone'));
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: 90 00 00 00',
                        errorText: _errors['telephone'] != null
                            ? (_errors['telephone'] is List
                                ? _errors['telephone'].join('\n')
                                : _errors['telephone'].toString())
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Téléphone Secondaire
                    const Text('Téléphone / Contact 2 (Optionnel)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phone2Ctrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) {
                        if (_errors.containsKey('contacts.0')) setState(() => _errors.remove('contacts.0'));
                        if (_errors.containsKey('contacts')) setState(() => _errors.remove('contacts'));
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: 99 00 00 00',
                        errorText: _errors['contacts.0'] != null
                            ? (_errors['contacts.0'] is List
                                ? _errors['contacts.0'].join('\n')
                                : _errors['contacts.0'].toString())
                            : (_errors['contacts'] != null
                                ? (_errors['contacts'] is List
                                    ? _errors['contacts'].join('\n')
                                    : _errors['contacts'].toString())
                                : null),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jours d'ouverture
                    const Text('Jours d\'ouverture *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days.map((day) {
                        final isSelected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => _toggleDay(day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? Colors.white : AppTheme.foreground,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Horaires d'ouverture
                    const Text('Horaires d\'ouverture *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.wb_sunny_outlined, size: 18, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(_formatTime(_openingTime),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('à',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.mutedForeground)),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.nights_stay_outlined, size: 18, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(_formatTime(_closingTime),
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Localisation / Zone
                    const Text('Localisation de la boutique *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _zone,
                          isExpanded: true,
                          items: _zones
                              .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                              .toList(),
                          onChanged: (v) => setState(() => _zone = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Détails de l'adresse
                    const Text('Détails de l\'adresse (Optionnel)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Ex: Près de la pharmacie XYZ...'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Opacity(
              opacity: (_isFormValid && !_isLoading) ? 1.0 : 0.5,
              child: AppButton(
                label: _isLoading ? 'Enregistrement...' : 'Enregistrer les modifications',
                icon: _isLoading ? Icons.hourglass_empty : Icons.save_outlined,
                onTap: (_isFormValid && !_isLoading)
                    ? () async {
                        setState(() {
                          _errors.clear();
                          _isLoading = true;
                        });

                        final telephoneFormatted = _formatPhoneNumber(_phoneCtrl.text.trim());
                        final phone2Raw = _phone2Ctrl.text.trim();
                        final phone2Formatted = _formatPhoneNumber(phone2Raw);

                        if (phone2Formatted.isNotEmpty && telephoneFormatted == phone2Formatted) {
                          setState(() {
                            _errors['contacts.0'] = 'Le contact secondaire ne peut pas être identique au numéro principal.';
                            _isLoading = false;
                          });
                          return;
                        }

                        // On envoie toujours contacts pour ne pas perdre la valeur existante.
                        // Si le champ est vide → tableau vide → le backend supprime le contact.
                        // Si rempli → met à jour.
                        final List<String> contacts =
                            phone2Formatted.isNotEmpty ? [phone2Formatted] : [];

                        final payload = {
                          'nom': _nameCtrl.text.trim(),
                          'telephone': telephoneFormatted,
                          'adresse': _zone,
                          'details_adresse': _detailsCtrl.text.trim(),
                          'description': _descCtrl.text.trim(),
                          'contacts': contacts,
                          'horaires': {
                            'jours': _selectedDays,
                            'ouverture': _formatTime(_openingTime),
                            'fermeture': _formatTime(_closingTime),
                          },
                          'categories': _selectedCategoryIds,
                          if (_bannerPath != null) 'bannerPath': _bannerPath,
                          if (_logoPath != null) 'logoPath': _logoPath,
                        };

                        try {
                          final result = await BoutiqueController.to.updateBoutique(payload);
                          if (result == true) {
                            AppToasts.success(
                              context,
                              'Succès',
                              'Votre boutique a été modifiée avec succès.',
                            );
                            Get.back();
                          } else if (result is Map) {
                            setState(() {
                              _errors = Map<String, dynamic>.from(result);
                            });
                            AppToasts.error(
                              context,
                              'Erreur de validation',
                              'Veuillez corriger les erreurs dans le formulaire.',
                            );
                          } else {
                            AppToasts.error(context, 'Erreur', 'Une erreur inattendue est survenue.');
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    : () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
