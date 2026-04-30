import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String _condition = 'Neuf';
  String _priceType = 'Fixe';
  String _category = 'electronique';
  bool _showZones = false;
  final Set<String> _selectedZones = {};

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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Get.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness:
            Get.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('Ajouter un produit'),
          leading: BackButton(),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text('Brouillons',
                  style: TextStyle(color: AppTheme.mutedForeground)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos
              TogoSlideUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photos',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    SizedBox(height: 10),
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
                                  style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    color: AppTheme.primary),
                                Text('1/5',
                                    style: TextStyle(
                                        fontSize: 11, color: AppTheme.primary)),
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
                              child: Icon(Icons.add,
                                  color: AppTheme.mutedForeground),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Title
              TogoSlideUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Titre',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    const TextField(
                      decoration:
                          InputDecoration(hintText: 'Ex: iPhone 13 128GB '),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Price + Category
              TogoSlideUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prix (FCFA)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          const TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '0'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catégorie',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
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
                                dropdownColor: AppTheme.cardColor,
                                items: mockCategories
                                    .where((c) => c.id != 'all')
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Row(
                                            children: [
                                              Icon(c.icon,
                                                  size: 16,
                                                  color: AppTheme.primary),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  c.label,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _category = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Price type toggle
              TogoSlideUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type de prix',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriceTypeToggle('Fixe', Icons.flash_on_rounded),
                        SizedBox(width: 8),
                        _buildPriceTypeToggle(
                            'Négociable', Icons.handshake_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Condition
              TogoSlideUp(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('État',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in ['Neuf', 'Occasion'])
                          Expanded(
                            child: TogoPressableScale(
                              onTap: () => setState(() => _condition = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    EdgeInsets.only(right: c == 'Neuf' ? 6 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _condition == c
                                      ? AppTheme.primaryLight
                                      : AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _condition == c
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                    width: _condition == c ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _condition == c
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
              SizedBox(height: 16),
              // Description
              TogoSlideUp(
                delay: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre produit en détail...',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Zones
              TogoSlideUp(
                delay: const Duration(milliseconds: 700),
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
                            Icon(Icons.location_on_outlined,
                                color: AppTheme.primary),
                            SizedBox(width: 10),
                            Expanded(
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
                                SizedBox(height: 8),
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
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _zones
                                      .map((z) => TogoPressableScale(
                                            onTap: () {
                                              setState(() {
                                                if (_selectedZones
                                                    .contains(z)) {
                                                  _selectedZones.remove(z);
                                                } else {
                                                  _selectedZones.add(z);
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
                                                color:
                                                    _selectedZones.contains(z)
                                                        ? AppTheme.primary
                                                        : AppTheme.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                      _selectedZones.contains(z)
                                                          ? AppTheme.primary
                                                          : AppTheme.border,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (_selectedZones
                                                      .contains(z))
                                                    Icon(Icons.check,
                                                        size: 12,
                                                        color: Colors.white),
                                                  if (_selectedZones
                                                      .contains(z))
                                                    SizedBox(width: 4),
                                                  Text(
                                                    z,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _selectedZones
                                                              .contains(z)
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
              SizedBox(height: 90),
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
              Text(
                'En publiant, vous acceptez nos Conditions d\'utilisation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.mutedForeground),
              ),
              SizedBox(height: 10),
              AppButton(
                label: 'Publier l\'annonce',
                onTap: () {
                  Navigator.of(context).maybePop();
                },
                icon: Icons.upload_outlined,
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
                SizedBox(width: 6),
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
