import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/model/location_model.dart';
import '../../controllers/boutique_controller.dart';
import '../../utils/app_toasts.dart';
import 'store_config_model.dart';

class StoreConfigurationScreen extends StatefulWidget {
  const StoreConfigurationScreen({super.key});

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  final StoreConfigData _data = StoreConfigData();

  // Controllers for general info
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _secondaryPhoneCtrls = [];
  final _addressCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isPickingImage = false;
  bool _gpsLoading = false;
  String? _gpsStatus;

  late final AuthController _authCtrl;

  final List<IconData> _stepIcons = [
    Icons.storefront_rounded,
    Icons.auto_awesome_rounded,
    Icons.location_on_rounded,
    Icons.access_time_filled_rounded,
    Icons.verified_user_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _authCtrl = Get.find<AuthController>();
    // Set default ville if locations loaded
    if (_authCtrl.locations.isNotEmpty) {
      _data.ville = _authCtrl.locations.first.nom;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    for (var ctrl in _secondaryPhoneCtrls) {
      ctrl.dispose();
    }
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      if (_data.name.trim().isEmpty) {
        AppToasts.error(context, 'Erreur', 'Le nom de la boutique est requis.');
        return;
      }
      if (_data.categoryIds.isEmpty) {
        AppToasts.error(context, 'Erreur', 'Sélectionnez au moins une catégorie.');
        return;
      }
      
      setState(() => _isLoading = true);
      final validate = await BoutiqueController.to.validateStep(1, {'nom': _data.name});
      setState(() => _isLoading = false);
      
      if (validate is Map) {
        final errors = validate.entries.map((e) {
          final v = e.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          return v.toString();
        }).join('\n');
        AppToasts.error(context, 'Erreur', errors);
        return;
      } else if (validate == false) {
        return;
      }
    } else if (_currentStep == 2) {
      if (_data.phone.trim().isEmpty) {
        AppToasts.error(context, 'Erreur', 'Le numéro WhatsApp est requis.');
        return;
      }
      if (_data.ville.isEmpty) {
        AppToasts.error(context, 'Erreur', 'Sélectionnez une ville.');
        return;
      }

      // Collect valid secondary phones
      _data.secondaryPhones = _secondaryPhoneCtrls
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      setState(() => _isLoading = true);
      final validate = await BoutiqueController.to.validateStep(3, {
        'telephone': _data.phone,
        if (_data.secondaryPhones.isNotEmpty) 'contacts': _data.secondaryPhones
      });
      setState(() => _isLoading = false);
      
      if (validate is Map) {
        final errors = validate.entries.map((e) {
          final v = e.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          return v.toString();
        }).join('\n');
        AppToasts.error(context, 'Erreur', errors);
        return;
      } else if (validate == false) {
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submitBoutique();
    }
  }

  Future<void> _submitBoutique() async {
    if (_isLoading) return;
    // Basic validation
    if (_data.name.trim().isEmpty) {
      AppToasts.error(context, 'Erreur', 'Le nom de la boutique est requis.');
      return;
    }
    if (_data.phone.trim().isEmpty) {
      AppToasts.error(context, 'Erreur', 'Le numéro WhatsApp est requis.');
      return;
    }
    if (_data.categoryIds.isEmpty) {
      AppToasts.error(context, 'Erreur', 'Sélectionnez au moins une catégorie.');
      return;
    }
    if (_data.ville.isEmpty) {
      AppToasts.error(context, 'Erreur', 'Sélectionnez une ville.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = _data.toPayload();
      final result = await BoutiqueController.to.createBoutique(payload);

      if (result == true) {
        if (mounted) {
          AppToasts.success(context, 'Succès', 'Votre boutique a été créée avec succès !');
        }
        Get.offNamed('/dashboard');
      } else if (result is Map) {
        // Validation errors from backend
        final errors = result.entries.map((e) {
          final v = e.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          return v.toString();
        }).join('\n');
        if (mounted) {
          AppToasts.error(context, 'Erreur de validation', errors);
        }
      } else {
        if (mounted) {
          AppToasts.error(context, 'Erreur', 'Une erreur inattendue est survenue.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToasts.error(context, 'Erreur', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentStep = idx),
                  children: [
                    _buildStep1Identity(),
                    _buildStep2Visuals(),
                    _buildStep3Location(),
                    _buildStep4Hours(),
                    _buildStep5Review(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              TogoPressableScale(
                onTap: _prevStep,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.shadowSm,
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: AppColors.foreground),
                ),
              ),
              const Expanded(
                child: Text('Ma Boutique',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
              ),
              const SizedBox(width: 40), // Balance
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (i) {
              final isActive = i == _currentStep;
              final isCompleted = i < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 40 : 32,
                      height: isActive ? 40 : 32,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? AppColors.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? AppShadows.shadowPrimary
                            : AppShadows.shadowSm,
                        border: Border.all(
                            color: isActive || isCompleted
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_rounded : _stepIcons[i],
                        size: isActive ? 18 : 14,
                        color: isActive || isCompleted
                            ? Colors.white
                            : AppColors.mutedForeground,
                      ),
                    ),
                    if (i < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: IDENTITY ---
  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TogoFadeInEntry(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commençons par le nom',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground)),
            const SizedBox(height: 8),
            const Text('Choisissez un nom qui reflète votre passion.',
                style:
                    TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 32),
            _buildCharmingField(
              label: 'Nom de la boutique',
              controller: _nameCtrl,
              hint: 'Ex: Togo Chic Fashion',
              icon: Icons.storefront_rounded,
              onChanged: (v) => _data.name = v,
            ),
            _buildFieldLabel('Catégories de votre boutique *'),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            _buildCharmingField(
              label: 'Votre histoire (Description)',
              controller: _descCtrl,
              hint: 'Parlez de vous en quelques lignes...',
              icon: Icons.history_edu_rounded,
              maxLines: 3,
              onChanged: (v) => _data.description = v,
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: VISUALS ---
  Widget _buildStep2Visuals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TogoFadeInEntry(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Une image forte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
            const SizedBox(height: 8),
            const Text('Les visuels augmentent de 80% l\'engagement.',
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Formats : JPEG, PNG, WebP • Taille max : 5 Mo',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500))),
              ]),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Photo de Couverture'),
            _buildBannerPicker(),
            const SizedBox(height: 32),
            _buildFieldLabel('Votre Logo'),
            Center(child: _buildLogoPickerArea()),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: LOCATION ---
  Widget _buildStep3Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TogoFadeInEntry(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Où vous trouver ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
            const SizedBox(height: 8),
            const Text('Rassurez vos clients sur votre proximité.',
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 32),
            _buildPhoneInput(
              label: 'Numéro de téléphone',
              controller: _phoneCtrl,
              onChanged: (v) => _data.phone = v,
            ),
            ...List.generate(_secondaryPhoneCtrls.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPhoneInput(
                        label: 'Autre numéro ${index + 1}',
                        controller: _secondaryPhoneCtrls[index],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    TogoPressableScale(
                      onTap: () => setState(() {
                        _secondaryPhoneCtrls[index].dispose();
                        _secondaryPhoneCtrls.removeAt(index);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24), // Match _buildCharmingField margin
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TogoPressableScale(
                onTap: () {
                  setState(() {
                    _secondaryPhoneCtrls.add(TextEditingController());
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.lgBorderRadius,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Ajouter un autre numéro', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel('Ville *'),
            _buildVilleDropdown(),
            const SizedBox(height: 24),
            _buildCharmingField(
              label: 'Adresse / Quartier',
              controller: _addressCtrl,
              hint: 'Ex: Quartier Tokoin, près de la pharmacie...',
              icon: Icons.near_me_rounded,
              onChanged: (v) => _data.address = v,
            ),
            const SizedBox(height: 24),
            _buildGpsButton(),
          ],
        ),
      ),
    );
  }

  // --- STEP 4: HOURS ---
  Widget _buildStep4Hours() {
    return TogoFadeInEntry(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const Text('Vos horaires',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.foreground)),
          const SizedBox(height: 8),
          const Text('Définissez vos temps forts de vente.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
          const SizedBox(height: 24),
          ...(_data.openingHours.map((h) => _buildCharmingDayRow(h))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- STEP 5: REVIEW ---
  Widget _buildStep5Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TogoFadeInEntry(
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('Prêt pour l\'aventure !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text(
                'Votre boutique va être superbe. Voici un dernier coup d\'œil.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 32),
            _buildModernReviewCard(),
          ],
        ),
      ),
    );
  }

  // --- CHARMING WIDGETS ---

  Widget _buildCharmingField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: AppShadows.shadowSm,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon,
                  color: AppColors.primary.withOpacity(0.6), size: 20),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lgBorderRadius,
                borderSide:
                    BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.lgBorderRadius,
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPhoneInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: AppShadows.shadowSm,
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Text('🇹🇬', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text('+228',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground)),
                  ],
                ),
              ),
              // Input
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: '00 00 00 00',
                    hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground)),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      final cats = _authCtrl.categories;
      if (cats.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Chargement des catégories...', style: TextStyle(color: AppColors.mutedForeground)),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cats.map((c) {
          final isSelected = _data.categoryIds.contains(c.id);
          return FilterChip(
            label: Text(c.nom),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.foreground,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _data.categoryIds.add(c.id);
                } else {
                  _data.categoryIds.remove(c.id);
                }
              });
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildVilleDropdown() {
    return Obx(() {
      final villes = _authCtrl.locations;
      final villeNames = villes.map((v) => v.nom).toList();
      // Ensure current value is valid
      if (villeNames.isNotEmpty && !villeNames.contains(_data.ville)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _data.ville = villeNames.first);
        });
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: AppShadows.shadowSm,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: villeNames.contains(_data.ville) ? _data.ville : null,
            isExpanded: true,
            hint: const Text('Sélectionner une ville'),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            items: villeNames
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Row(children: [
                        const Icon(Icons.location_city_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _data.ville = v!),
          ),
        ),
      );
    });
  }

  Future<void> _pickStoreImage(bool isBanner) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        // Check size (5 Mo = 5242880 bytes)
        final fileSize = await File(picked.path).length();
        if (fileSize > 5242880) {
          if (mounted) {
            AppToasts.error(context, 'Image trop volumineuse',
                'L\'image dépasse 5 Mo. Veuillez choisir une image plus légère.');
          }
          return;
        }
        setState(() {
          if (isBanner) {
            _data.bannerPath = picked.path;
          } else {
            _data.logoPath = picked.path;
          }
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Widget _buildBannerPicker() {
    return TogoPressableScale(
      onTap: () => _pickStoreImage(true),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.xlBorderRadius,
          image: _data.bannerPath != null
              ? DecorationImage(
                  image: FileImage(File(_data.bannerPath!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
                )
              : null,
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _data.bannerPath != null ? Colors.black.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_data.bannerPath != null ? Icons.edit : Icons.add_a_photo_rounded,
                    color: _data.bannerPath != null ? Colors.white : AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(_data.bannerPath != null ? 'Changer la couverture' : 'Ajouter une couverture',
                    style: TextStyle(
                        color: _data.bannerPath != null ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPickerArea() {
    return TogoPressableScale(
      onTap: () => _pickStoreImage(false),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.shadowLg,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: _data.logoPath != null ? FileImage(File(_data.logoPath!)) : null,
              child: _data.logoPath == null
                  ? const Icon(Icons.storefront, size: 40, color: AppColors.primary)
                  : null,
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(_data.logoPath != null ? Icons.edit : Icons.camera_alt_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _requestGpsPosition() async {
    setState(() { _gpsLoading = true; _gpsStatus = null; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _gpsStatus = 'Services de localisation désactivés'; _gpsLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _gpsStatus = 'Permission refusée'; _gpsLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _gpsStatus = 'Permission refusée définitivement'; _gpsLoading = false; });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _data.latitude = position.latitude;
        _data.longitude = position.longitude;
        _gpsStatus = 'Position détectée ✅';
        _gpsLoading = false;
      });
    } catch (e) {
      setState(() { _gpsStatus = 'Erreur GPS: ${e.toString().substring(0, 50)}'; _gpsLoading = false; });
    }
  }

  Widget _buildGpsButton() {
    return TogoPressableScale(
      onTap: _gpsLoading ? null : _requestGpsPosition,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100,
        decoration: BoxDecoration(
          color: _data.latitude != null
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.primary.withOpacity(0.05),
          borderRadius: AppRadius.xlBorderRadius,
          border: Border.all(
            color: _data.latitude != null
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: _gpsLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    SizedBox(width: 12),
                    Text('Recherche de la position...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_data.latitude != null ? Icons.check_circle : Icons.pin_drop_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(_data.latitude != null ? 'Position détectée ✅' : 'Vérifier la position GPS',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    if (_data.latitude != null) ...[
                      const SizedBox(height: 6),
                      Text('${_data.latitude!.toStringAsFixed(4)}, ${_data.longitude!.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCharmingDayRow(DayOpeningHours h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: h.isOpen ? AppShadows.shadowMd : AppShadows.shadowSm,
          border: Border.all(
            color: h.isOpen
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border.withOpacity(0.3),
            width: h.isOpen ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: h.isOpen
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calendar_today_rounded,
                      size: 16,
                      color: h.isOpen
                          ? AppColors.primary
                          : AppColors.mutedForeground),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(h.day,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900))),
                Switch.adaptive(
                  value: h.isOpen,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => h.isOpen = v),
                ),
              ],
            ),
            if (h.isOpen) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCharmingTime(
                      h.openingTime!, (t) => setState(() => h.openingTime = t)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('→',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedForeground)),
                  ),
                  _buildCharmingTime(
                      h.closingTime!, (t) => setState(() => h.closingTime = t)),
                  const Spacer(),
                  TogoPressableScale(
                    onTap: () => setState(() => h.isHalfDay = !h.isHalfDay),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            h.isHalfDay ? AppColors.primary : AppColors.muted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Demi-journée',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: h.isHalfDay
                                  ? Colors.white
                                  : AppColors.mutedForeground)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCharmingTime(TimeOfDay time, Function(TimeOfDay) onPicked) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onPicked(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildModernReviewCard() {
    final categoryNames = _authCtrl.categories
        .where((c) => _data.categoryIds.contains(c.id))
        .map((c) => c.nom)
        .join(', ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlBorderRadius,
        boxShadow: AppShadows.shadowLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              image: _data.bannerPath != null
                  ? DecorationImage(image: FileImage(File(_data.bannerPath!)), fit: BoxFit.cover)
                  : null,
            ),
            child: _data.bannerPath == null
                ? const Center(child: Icon(Icons.panorama_outlined, size: 40, color: AppColors.primary))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -50, left: 0, right: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: _data.logoPath != null ? FileImage(File(_data.logoPath!)) : null,
                              child: _data.logoPath == null
                                  ? const Icon(Icons.storefront, size: 28, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(_nameCtrl.text.isEmpty ? 'Mon Togo Market' : _nameCtrl.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const Divider(height: 40),
                _buildReviewRow(Icons.phone_iphone_rounded,
                    _phoneCtrl.text.isEmpty ? 'Non renseigné' : _phoneCtrl.text),
                if (_secondaryPhoneCtrls.isNotEmpty)
                  ..._secondaryPhoneCtrls.map((c) => c.text.trim().isNotEmpty ? _buildReviewRow(Icons.phone_rounded, c.text) : const SizedBox.shrink()),
                _buildReviewRow(Icons.location_city_rounded,
                    _data.ville.isNotEmpty ? '${_data.ville}${_data.address.isNotEmpty ? ', ${_data.address}' : ''}' : 'Non renseigné'),
                _buildReviewRow(Icons.category_rounded,
                    categoryNames.isNotEmpty ? categoryNames : 'Non sélectionné'),
                if (_data.latitude != null)
                  _buildReviewRow(Icons.gps_fixed, 'GPS: ${_data.latitude!.toStringAsFixed(4)}, ${_data.longitude!.toStringAsFixed(4)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    bool isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.border.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          if (_currentStep == 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('C\'est parti !'),
              ),
            )
          else ...[
            TogoPressableScale(
              onTap: _prevStep,
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.foreground),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isLast ? 'Lancer ma boutique 🚀' : 'Continuer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
