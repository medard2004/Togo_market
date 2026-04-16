import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  String _condition = 'Neuf';
  String _priceType = 'Fixe';
  String _category = 'electronique';
  bool _showZones = false;
  final Set<String> _selectedZones = {};

  static const _zones = [
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

  Product? _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? _loadProductById();
    _titleController = TextEditingController(text: _product?.title ?? '');
    _priceController =
        TextEditingController(text: _product?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: _product?.description ?? '');
    _locationController =
        TextEditingController(text: _product?.location ?? 'Tokoin, Lomé');
    _category = _product?.category ?? 'electronique';
    _condition = _product?.condition ?? 'Neuf';

    if (_product != null && _zones.contains(_product!.location)) {
      _selectedZones.add(_product!.location);
    }
  }

  Product? _loadProductById() {
    final id = Get.parameters['id'];
    if (id == null || id.isEmpty) return null;
    return getProductById(id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null && Get.parameters['id'] != null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Produit introuvable', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              AppButton(label: 'Retour', onTap: Get.back),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Modifier un produit'),
          leading: const BackButton(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TogoSlideUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Photos',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        TogoPressableScale(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primary,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _product?.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _product!.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.camera_alt_outlined,
                                          color: AppTheme.primary),
                                      SizedBox(height: 6),
                                      Text('1/5',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primary)),
                                    ],
                                  ),
                          ),
                        ),
                        ...List.generate(
                          4,
                          (i) => TogoSlideUp(
                            delay: Duration(milliseconds: 100 + (i * 50)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppTheme.border,
                                    style: BorderStyle.solid),
                              ),
                              child: const Icon(Icons.add,
                                  color: AppTheme.mutedForeground),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TogoSlideUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Titre',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: iPhone 13 128GB',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prix (FCFA)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Catégorie',
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
                                value: _category,
                                isExpanded: true,
                                items: mockCategories
                                    .where((c) => c.id != 'all')
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Row(
                                            children: [
                                              Icon(c.icon,
                                                  size: 16,
                                                  color: AppTheme.primary),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  c.label,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _category = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type de prix',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriceTypeToggle('Fixe', Icons.flash_on_rounded),
                        const SizedBox(width: 8),
                        _buildPriceTypeToggle(
                            'Négociable', Icons.handshake_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('État',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final option in ['Neuf', 'Occasion'])
                          Expanded(
                            child: TogoPressableScale(
                              onTap: () => setState(() => _condition = option),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                    right: option == 'Neuf' ? 6 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _condition == option
                                      ? AppTheme.primaryLight
                                      : AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _condition == option
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                    width: _condition == option ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _condition == option
                                          ? AppTheme.primary
                                          : AppTheme.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Localisation',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration:
                          const InputDecoration(hintText: 'Ex: Tokoin, Lomé'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Décrivez votre produit en détail...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TogoSlideUp(
                delay: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    TogoPressableScale(
                      onTap: () => setState(() => _showZones = !_showZones),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppTheme.primary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('Zones de vente',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Icon(
                              _showZones
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _showZones
                          ? Column(
                              children: [
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (_selectedZones.length ==
                                        _zones.length) {
                                      setState(() => _selectedZones.clear());
                                    } else {
                                      setState(
                                          () => _selectedZones.addAll(_zones));
                                    }
                                  },
                                  child: Text(
                                    _selectedZones.length == _zones.length
                                        ? 'Tout désélectionner'
                                        : 'Tout sélectionner',
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _zones
                                      .map((zone) => TogoPressableScale(
                                            onTap: () {
                                              setState(() {
                                                if (_selectedZones
                                                    .contains(zone)) {
                                                  _selectedZones.remove(zone);
                                                } else {
                                                  _selectedZones.add(zone);
                                                }
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _selectedZones
                                                        .contains(zone)
                                                    ? AppTheme.primary
                                                    : AppTheme.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _selectedZones
                                                          .contains(zone)
                                                      ? AppTheme.primary
                                                      : AppTheme.border,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (_selectedZones
                                                      .contains(zone))
                                                    const Icon(Icons.check,
                                                        size: 12,
                                                        color: Colors.white),
                                                  if (_selectedZones
                                                      .contains(zone))
                                                    const SizedBox(width: 4),
                                                  Text(
                                                    zone,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _selectedZones
                                                              .contains(zone)
                                                          ? Colors.white
                                                          : AppTheme.foreground,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            boxShadow: AppTheme.shadowCardLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'En publiant, vous acceptez nos Conditions d\'utilisation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Enregistrer les modifications',
                onTap: () {
                  Get.back();
                },
                icon: Icons.save_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTypeToggle(String label, IconData icon) {
    final isSelected = _priceType == label;
    return Expanded(
      child: TogoPressableScale(
        onTap: () => setState(() => _priceType = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLight : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: isSelected ? AppTheme.primary : AppTheme.foreground),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primary : AppTheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
