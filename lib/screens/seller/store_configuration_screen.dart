import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/common_widgets.dart';

class StoreConfigurationScreen extends StatefulWidget {
  const StoreConfigurationScreen({super.key});

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  TimeOfDay? _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  String _zone = 'Tokoin';
  String _categoryId = 'friperie'; // Default category
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> _selectedDays = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven'
  ]; // Default

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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
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
    return _nameCtrl.text.isNotEmpty &&
        _phoneCtrl.text.isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _openingTime != null &&
        _closingTime != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _sloganCtrl.dispose();
    _phoneCtrl.dispose();
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
        body: SingleChildScrollView(
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
                            backgroundColor: Colors.white.withOpacity(0.4),
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

              // Form fields
              const Text('Nom de la boutique *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                decoration:
                    const InputDecoration(hintText: 'Ex: Ma Super Boutique'),
              ),
              const SizedBox(height: 16),

              const Text('Slogan (Optionnel)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _sloganCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    hintText: 'Motto de votre boutique...'),
              ),
              const SizedBox(height: 16),

              const Text('Catégorie de produits *',
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
                    value: _categoryId,
                    isExpanded: true,
                    items: mockCategories
                        .where((c) => c.id != 'all')
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(c.icon,
                                      size: 18, color: AppTheme.primary),
                                  const SizedBox(width: 8),
                                  Text(c.label),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

              const Text('Téléphone *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration:
                    const InputDecoration(hintText: 'Ex: +228 90 00 00 00'),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              const Text('Jours d\'ouverture',
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primary : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected ? Colors.white : AppTheme.foreground,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Horaires d\'ouverture',
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
                            const Icon(Icons.wb_sunny_outlined,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(_formatTime(_openingTime),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
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
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Localisation *',
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
                        .map((z) => DropdownMenuItem(
                              value: z,
                              child: Text(z),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _zone = v!),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Opacity(
              opacity: _isFormValid ? 1.0 : 0.5,
              child: AppButton(
                label: 'Créer ma boutique',
                icon: Icons.storefront_outlined,
                onTap: _isFormValid
                    ? () {
                        Get.offNamed('/dashboard');
                      }
                    : () {
                        // Action désactivée
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
