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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _sloganController = TextEditingController(text: widget.shop.slogan);
    _descriptionController = TextEditingController(text: widget.shop.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty;
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
            _buildLabel('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre boutique...',
              ),
            ),
            const SizedBox(height: 32),
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
}
