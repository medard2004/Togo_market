import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ShopInfo {
  final String name;
  final String slogan;
  final String description;
  final String category;
  final String location;
  final String phone;
  final String openingTime;
  final String closingTime;
  final List<String> openingDays;
  final List<String> zones;
  final String coverUrl;
  final String logoUrl;

  const ShopInfo({
    required this.name,
    required this.slogan,
    required this.description,
    required this.category,
    required this.location,
    required this.phone,
    required this.openingTime,
    required this.closingTime,
    required this.openingDays,
    required this.zones,
    required this.coverUrl,
    required this.logoUrl,
  });

  static const sample = ShopInfo(
    name: 'Kofi Tech Shop',
    slogan: 'Électronique de qualité à Lomé',
    description:
        'Boutique spécialisée dans la vente de produits électroniques neufs et d’occasion. Livraison rapide sur Lomé et service client disponible 7j/7.',
    category: 'Électronique',
    location: 'Tokoin, Lomé',
    phone: '+228 90 00 00 00',
    openingTime: '08:00',
    closingTime: '18:00',
    openingDays: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
    zones: ['Tokoin', 'Adidogomé', 'Bè'],
    coverUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600&auto=format&fit=crop',
    logoUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
  );
}

class EditShopScreen extends StatefulWidget {
  final ShopInfo shop;

  const EditShopScreen({super.key, required this.shop});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _sloganController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  late String _category;
  late String _location;
  late String _openingTime;
  late String _closingTime;
  late final Set<String> _selectedDays;
  late final Set<String> _selectedZones;

  final _categories = [
    'Électronique',
    'Mode',
    'Maison',
    'Services',
    'Beauté',
  ];

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

  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _sloganController = TextEditingController(text: widget.shop.slogan);
    _descriptionController = TextEditingController(text: widget.shop.description);
    _phoneController = TextEditingController(text: widget.shop.phone);
    _category = widget.shop.category;
    _location = widget.shop.location;
    _openingTime = widget.shop.openingTime;
    _closingTime = widget.shop.closingTime;
    _selectedDays = widget.shop.openingDays.toSet();
    _selectedZones = widget.shop.zones.toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _openingTime.isNotEmpty &&
        _closingTime.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Modifier la boutique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(widget.shop.coverUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -36,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(widget.shop.logoUrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 52),
            _buildLabel('Nom de la boutique *'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Ex: Kofi Tech Shop'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildLabel('Slogan'),
            const SizedBox(height: 8),
            TextField(
              controller: _sloganController,
              decoration: const InputDecoration(hintText: 'Votre slogan...'),
            ),
            const SizedBox(height: 16),
            _buildLabel('Catégorie principale'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  items: _categories
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre boutique...',
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Téléphone *'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration:
                  const InputDecoration(hintText: '+228 90 00 00 00'),
            ),
            const SizedBox(height: 16),
            _buildLabel('Localisation *'),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _location),
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Tokoin, Lomé',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Horaires d’ouverture'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeButton('Ouverture', _openingTime, () async {
                    final result = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: int.parse(_openingTime.split(':').first),
                          minute: int.parse(_openingTime.split(':').last)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppTheme.primary,
                            onPrimary: Colors.white,
                            onSurface: AppTheme.foreground,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (result != null) {
                      setState(() => _openingTime = result.format(context));
                    }
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton('Fermeture', _closingTime, () async {
                    final result = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: int.parse(_closingTime.split(':').first),
                          minute: int.parse(_closingTime.split(':').last)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppTheme.primary,
                            onPrimary: Colors.white,
                            onSurface: AppTheme.foreground,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (result != null) {
                      setState(() => _closingTime = result.format(context));
                    }
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Jours d’ouverture'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                final selected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppTheme.primary : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.foreground,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildLabel('Zones de vente'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _zones.map((zone) {
                final selected = _selectedZones.contains(zone);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedZones.remove(zone);
                      } else {
                        _selectedZones.add(zone);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppTheme.primary : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      zone,
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.foreground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Enregistrer les modifications',
              icon: Icons.save_outlined,
              onTap: _isFormValid ? () => Get.back() : () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTimeButton(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
