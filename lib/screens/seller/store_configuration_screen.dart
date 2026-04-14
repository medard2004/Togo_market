import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/core/api_client.dart';
import '../../Api/config/api_constants.dart';
import '../../models/models.dart';
import '../../utils/app_toasts.dart';

class StoreConfigurationScreen extends StatefulWidget {
  const StoreConfigurationScreen({super.key});

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  String _zone = 'Tokoin';
  List<String> _selectedCategoryIds = [];

  TimeOfDay? _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> _selectedDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  Map<String, dynamic> _errors = {};
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<AppCategory> _dbCategories = [];

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
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await Get.find<ApiClient>().get(ApiConstants.categoriesEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (mounted) {
          setState(() {
            _dbCategories = data.map((e) {
              final nom = e['nom'].toString();
              IconData iconData = Icons.category_rounded;
              if (e['slug'] == 'mode')
                iconData = Icons.shopping_bag_rounded;
              else if (e['slug'] == 'beaute-sante')
                iconData = Icons.face_retouching_natural_rounded;
              else if (e['slug'] == 'electronique')
                iconData = Icons.devices_rounded;
              else if (e['slug'] == 'alimentation')
                iconData = Icons.restaurant_rounded;
              else if (e['slug'] == 'maison-decoration')
                iconData = Icons.home_rounded;
              else if (e['slug'] == 'immobilier')
                iconData = Icons.apartment_rounded;
              else if (e['slug'] == 'vehicules')
                iconData = Icons.directions_car_rounded;
              else if (e['slug'] == 'services') iconData = Icons.build_rounded;

              return AppCategory(
                  id: e['id'].toString(), label: nom, icon: iconData);
            }).toList();

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppTheme.border.withOpacity(0.3), width: 0.5),
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
        if (isOpening)
          _openingTime = picked;
        else
          _closingTime = picked;
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
          title: const Text('Configurer ma boutique'),
          leading: const BackButton(),
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
                          Container(
                            width: double.infinity,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: CachedNetworkImageProvider(
                                    'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600&auto=format&fit=crop'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.4),
                                  child: const Icon(Icons.camera_alt,
                                      color: AppTheme.primary),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.background,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundImage: CachedNetworkImageProvider(
                                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop'),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppTheme.primary,
                                    child: Icon(Icons.edit,
                                        size: 14, color: Colors.white),
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      onChanged: (_) {
                        if (_errors.containsKey('nom'))
                          setState(() => _errors.remove('nom'));
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: Ma Super Boutique',
                        errorText: _errors['nom'] != null
                            ? (_errors['nom'] is List
                                ? _errors['nom'].join('\n')
                                : _errors['nom'].toString())
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    const Text('Catégorie de produits *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText:
                              'Ex: Produits de qualité et livraison rapide.'),
                    ),
                    const SizedBox(height: 16),

                    // Téléphone Principal
                    const Text('Téléphone Principal *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) {
                        if (_errors.containsKey('telephone'))
                          setState(() => _errors.remove('telephone'));
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

                    // Téléphone Secondaire (Contact)
                    const Text('Téléphone / Contact 2 (Optionnel)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phone2Ctrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) {
                        if (_errors.containsKey('contacts.0'))
                          setState(() => _errors.remove('contacts.0'));
                        if (_errors.containsKey('contacts'))
                          setState(() => _errors.remove('contacts'));
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.foreground,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Horaires d'ouverture
                    const Text('Horaires d\'ouverture *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
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
                                  const Icon(Icons.wb_sunny_outlined,
                                      size: 18, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(_formatTime(_openingTime),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
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
                                  const Icon(Icons.nights_stay_outlined,
                                      size: 18, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(_formatTime(_closingTime),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
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
                              .map((z) =>
                                  DropdownMenuItem(value: z, child: Text(z)))
                              .toList(),
                          onChanged: (v) => setState(() => _zone = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Adresse
                    const Text('Détails de l\'adresse (Optionnel)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
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
                label:
                    _isLoading ? 'Création en cours...' : 'Créer ma boutique',
                icon: _isLoading
                    ? Icons.hourglass_empty
                    : Icons.storefront_outlined,
                onTap: (_isFormValid && !_isLoading)
                    ? () async {
                        setState(() {
                          _errors.clear();
                          _isLoading = true;
                        });

                        final telephoneFormatted =
                            _formatPhoneNumber(_phoneCtrl.text.trim());
                        final phone2Formatted =
                            _formatPhoneNumber(_phone2Ctrl.text.trim());

                        if (phone2Formatted.isNotEmpty && telephoneFormatted == phone2Formatted) {
                          setState(() {
                            _errors['contacts.0'] = 'Le contact secondaire ne peut pas être identique au numéro principal.';
                            _isLoading = false;
                          });
                          return;
                        }

                        final payload = {
                          'nom': _nameCtrl.text.trim(),
                          'telephone': telephoneFormatted,
                          'adresse': _zone,
                          'details_adresse': _detailsCtrl.text.trim(),
                          'description': _descCtrl.text.trim(),
                          if (phone2Formatted.isNotEmpty)
                            'contacts': [phone2Formatted],
                          'horaires': {
                            'jours': _selectedDays,
                            'ouverture': _formatTime(_openingTime),
                            'fermeture': _formatTime(_closingTime),
                          },
                          // On envoie le tableau des identifiants des catégories
                          'categories': _selectedCategoryIds,
                        };

                        try {
                          final result = await BoutiqueController.to
                              .createBoutique(payload);
                          if (result == true) {
                            AppToasts.success(
                              context,
                              'Félicitations',
                              'Votre boutique a été créée avec succès.',
                            );
                            Get.offNamed('/dashboard');
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
                            AppToasts.error(
                              context,
                              'Erreur',
                              'Une erreur inattendue est survenue.',
                            );
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
