import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
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
  final _sloganCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final List<IconData> _stepIcons = [
    Icons.storefront_rounded,
    Icons.auto_awesome_rounded,
    Icons.location_on_rounded,
    Icons.access_time_filled_rounded,
    Icons.verified_user_rounded,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offNamed('/dashboard');
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
          child: Stack(
            children: [
              Column(
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
                ],
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
            _buildCharmingField(
              label: 'Slogan (Optionnel)',
              controller: _sloganCtrl,
              hint: 'Ex: Le meilleur de Lomé',
              icon: Icons.auto_fix_high_rounded,
              onChanged: (v) => _data.slogan = v,
            ),
            _buildFieldLabel('Quelles sont vos catégories ? (Plusieurs possibles)'),
            _buildCategorySelector(),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: TogoFadeInEntry(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Une image forte',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground)),
            const SizedBox(height: 8),
            const Text('Les visuels augmentent de 80% l\'engagement.',
                style:
                    TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 32),
            _buildFieldLabel('Photo de Couverture'),
            _buildCharmingImagePicker(
              height: 180,
              imageUrl:
                  'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600',
              label: 'Éditer la couverture',
              isWide: true,
            ),
            const SizedBox(height: 32),
            _buildFieldLabel('Votre Logo'),
            Center(
              child: TogoPressableScale(
                onTap: () {},
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.shadowLg,
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 70,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200',
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: LOCATION ---
  Widget _buildStep3Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: TogoFadeInEntry(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Où vous trouver ?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground)),
            const SizedBox(height: 8),
            const Text('Rassurez vos clients sur votre proximité.',
                style:
                    TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
            const SizedBox(height: 32),
            _buildCharmingField(
              label: 'Numéro WhatsApp',
              controller: _phoneCtrl,
              hint: '+228 90 00 00 00',
              icon: Icons.phone_iphone_rounded,
              keyboardType: TextInputType.phone,
              onChanged: (v) => _data.phone = v,
            ),
            _buildFieldLabel('Choisissez votre Zone'),
            _buildZoneDropdown(),
            const SizedBox(height: 24),
            _buildCharmingField(
              label: 'Adresse ou Repères',
              controller: _addressCtrl,
              hint: 'Près de l\'ancienne poste...',
              icon: Icons.near_me_rounded,
              onChanged: (v) => _data.address = v,
            ),
            const SizedBox(height: 24),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: AppRadius.xlBorderRadius,
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pin_drop_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Vérifier la position GPS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 4: HOURS ---
  Widget _buildStep4Hours() {
    return TogoFadeInEntry(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: mockCategories
          .where((c) => c.id != 'all')
          .map((c) {
            final isSelected = _data.categoryIds.contains(c.id);
            return TogoPressableScale(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _data.categoryIds.remove(c.id);
                  } else {
                    _data.categoryIds.add(c.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: AppRadius.lgBorderRadius,
                  boxShadow: isSelected ? AppShadows.shadowPrimary : AppShadows.shadowSm,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      c.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
          .toList(),
    );
  }

  Widget _buildZoneDropdown() {
    final zones = [
      'Tokoin',
      'Avépozo',
      'Adidogomé',
      'Bè',
      'Kégué',
      'Nyékonakpoè',
      'Agoè'
    ];
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
          value: _data.zone,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary),
          items: zones
              .map((z) => DropdownMenuItem(
                    value: z,
                    child: Text(z,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _data.zone = v!),
        ),
      ),
    );
  }

  Widget _buildCharmingImagePicker(
      {required double height,
      required String imageUrl,
      required String label,
      required bool isWide}) {
    return TogoPressableScale(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: AppRadius.xlBorderRadius,
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.darken),
          ),
          boxShadow: AppShadows.shadowMd,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_a_photo_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
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
                Transform.scale(
                  scale: 0.7,
                  alignment: Alignment.centerRight,
                  child: CupertinoSwitch(
                    value: h.isOpen,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    onChanged: (v) => setState(() => h.isOpen = v),
                  ),
                ),
              ],
            ),
            if (h.isOpen) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCharmingTime(
                      h.openingTime!,
                      enabled: !h.isHalfDay,
                      (t) => setState(() {
                            h.openingTime = t;
                            if (h.openingTime?.hour == 9 &&
                                h.openingTime?.minute == 0 &&
                                h.closingTime?.hour == 12 &&
                                h.closingTime?.minute == 0) {
                              h.isHalfDay = true;
                            } else {
                              h.isHalfDay = false;
                            }
                          })),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('→',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedForeground)),
                  ),
                  _buildCharmingTime(
                      h.closingTime!,
                      enabled: !h.isHalfDay,
                      (t) => setState(() {
                            h.closingTime = t;
                            if (h.openingTime?.hour == 9 &&
                                h.openingTime?.minute == 0 &&
                                h.closingTime?.hour == 12 &&
                                h.closingTime?.minute == 0) {
                              h.isHalfDay = true;
                            } else {
                              h.isHalfDay = false;
                            }
                          })),
                  const Spacer(),
                  TogoPressableScale(
                    onTap: () => setState(() {
                      h.isHalfDay = !h.isHalfDay;
                      if (h.isHalfDay) {
                        h.openingTime = const TimeOfDay(hour: 9, minute: 0);
                        h.closingTime = const TimeOfDay(hour: 12, minute: 0);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            h.isHalfDay ? AppColors.primary : AppColors.muted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Demi-journée',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: h.isHalfDay
                                    ? Colors.white
                                    : AppColors.mutedForeground)),
                      ),
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

  Widget _buildCharmingTime(TimeOfDay time, Function(TimeOfDay) onPicked,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final t =
                  await showTimePicker(context: context, initialTime: time);
              if (t != null) onPicked(t);
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? Colors.transparent
                  : AppColors.border.withOpacity(0.3),
            ),
          ),
          child: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: enabled ? AppColors.foreground : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernReviewCard() {
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600'),
                fit: BoxFit.cover,
              ),
            ),
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
                        top: -50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 36,
                              backgroundImage: const CachedNetworkImageProvider(
                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                    _nameCtrl.text.isEmpty ? 'Mon Togo Market' : _nameCtrl.text,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                    _sloganCtrl.text.isEmpty
                        ? 'Prêt à vendre mes merveilles'
                        : _sloganCtrl.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 14)),
                const Divider(height: 40),
                _buildReviewRow(
                    Icons.phone_iphone_rounded,
                    _phoneCtrl.text.isEmpty
                        ? 'Non renseigné'
                        : _phoneCtrl.text),
                _buildReviewRow(
                    Icons.pin_drop_rounded, '${_data.zone}, ${_data.address}'),
                _buildReviewRow(Icons.auto_awesome_mosaic_rounded,
                    _data.categoryIds.isEmpty 
                      ? 'Aucune catégorie' 
                      : _data.categoryIds.map((id) => mockCategories.firstWhere((c) => c.id == id).label).join(', ')),
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
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentStep > 0) ...[
                TogoPressableScale(
                  onTap: _prevStep,
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 20, color: AppColors.foreground),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TogoPressableScale(
                  onTap: _nextStep,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'C\'est parti !' : 'Continuer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast ? Icons.rocket_launch_rounded : Icons.double_arrow_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
