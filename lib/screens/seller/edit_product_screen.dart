import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// import '../../data/mock_data.dart';
import '../../Api/model/product_model.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/product_form_controller.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/category_picker_bottom_sheet.dart';
import '../../utils/category_icon_helper.dart';
import '../../Api/config/api_constants.dart';
// Note: We reuse FormSubmitBottomBar from add_product_screen.dart or recreate it here.
import 'add_product_screen.dart' show FormSubmitBottomBar;

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _controller = Get.put(ProductFormController());
  Product? _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? _loadProductById();
    
    if (_product != null) {
      _controller.initForEdit(_product!);
    } else {
      // Intéressant de fermer si introuvable
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) Get.back();
      });
    }
  }

  Product? _loadProductById() {
    final id = Get.parameters['id'];
    if (id == null || id.isEmpty) return null;
    
    // 1. Chercher dans le Dashboard (mes articles)
    if (Get.isRegistered<DashboardController>()) {
      final p = Get.find<DashboardController>().myProducts.firstWhereOrNull((prod) => prod.id.toString() == id);
      if (p != null) return p;
    }
    
    // 2. Chercher dans l'AppController (produits globaux)
    if (Get.isRegistered<AppController>()) {
      return Get.find<AppController>().products
          .firstWhereOrNull((p) => p.id.toString() == id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Modifier un produit')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppTheme.mutedForeground),
              const SizedBox(height: 16),
              const Text('Produit introuvable', style: TextStyle(fontSize: 16, color: AppTheme.mutedForeground)),
              const SizedBox(height: 24),
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
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Modifier le produit'),
          leading: const BackButton(),
        ),
        body: Form(
          key: _controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos section
                TogoSlideUp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Photos de l\'article', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Obx(() {
                             final count = _controller.existingImages.length + _controller.images.length;
                             return Text('$count/5', style: TextStyle(fontSize: 12, color: count == 0 ? Colors.red : AppTheme.primary));
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Ajoutez au moins 1 photo (5 maximum).', style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
                      const SizedBox(height: 12),
                      Obx(() {
                        final totalCurrentImages = _controller.existingImages.length + _controller.images.length;
                        
                        if (totalCurrentImages == 0) {
                          return TogoPressableScale(
                            onTap: _controller.pickImages,
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primary, style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 32, color: AppTheme.primary),
                                  SizedBox(height: 8),
                                  Text('Appuyez pour ajouter des photos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              // Existing Images
                              ...List.generate(
                                _controller.existingImages.length,
                                (i) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiConstants.resolveImageUrl(_controller.existingImages[i]),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(color: AppTheme.muted, width: 80, height: 80),
                                        errorWidget: (_, __, ___) => Container(color: AppTheme.muted, width: 80, height: 80, child: const Icon(Icons.broken_image, color: AppTheme.mutedForeground)),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4, right: 4,
                                      child: GestureDetector(
                                        onTap: () => _controller.removeExistingImage(i),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // New Images
                              ...List.generate(
                                _controller.images.length,
                                (i) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_controller.images[i].path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4, right: 4,
                                      child: GestureDetector(
                                        onTap: () => _controller.removeNewImage(i),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Add Button (if less than 5)
                              if (totalCurrentImages < 5)
                                TogoPressableScale(
                                  onTap: _controller.pickImages,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.primary, style: BorderStyle.solid),
                                    ),
                                    child: const Icon(Icons.add, color: AppTheme.primary, size: 28),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre
                TogoSlideUp(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Titre', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller.titleController,
                        validator: (v) => v == null || v.isEmpty ? 'Le titre est requis' : null,
                        decoration: const InputDecoration(hintText: 'Ex: iPhone 13 Pro Max 256Go'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TogoSlideUp(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller.descriptionController,
                        maxLines: 4,
                        validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
                        decoration: const InputDecoration(hintText: 'Ex: Je vends mon appareil en très bon état...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prix & Categorie
                TogoSlideUp(
                  delay: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix (FCFA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _controller.priceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Prix requis' : null,
                              decoration: const InputDecoration(hintText: 'Ex: 450000'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Catégorie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                final rootCats = Get.find<AppController>().categories;
                                CategoryPickerBottomSheet.show(
                                  context,
                                  categories: rootCats,
                                  onCategorySelected: (cat) {
                                    _controller.selectedCategory.value = cat.id;
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  border: Border.all(color: AppTheme.border),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Obx(() {
                                  final selectedId = _controller.selectedCategory.value;
                                  if (selectedId == null) {
                                    return const Row(
                                      children: [
                                        Expanded(
                                          child: Text('Sélectionner', style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
                                        ),
                                        Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.mutedForeground),
                                      ],
                                    );
                                  }
                                  final appCtrl = Get.find<AppController>();
                                  final allFlat = appCtrl.allFlatCategories;
                                  final matchingCat = allFlat.firstWhereOrNull((c) => c.id == selectedId);
                                  if (matchingCat == null) {
                                    return const Row(
                                      children: [
                                        Expanded(
                                          child: Text('Sélectionner', style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
                                        ),
                                        Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.mutedForeground),
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      Icon(CategoryIconHelper.getIcon(matchingCat.slug), size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(matchingCat.nom, style: const TextStyle(fontSize: 12, color: AppTheme.foreground), overflow: TextOverflow.ellipsis),
                                      ),
                                      const Icon(Icons.edit, size: 14, color: AppTheme.primary),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prix type (Fixe/Négociable)
                TogoSlideUp(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Type de prix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriceTypeToggle(false, 'Fixe', Icons.flash_on_rounded),
                          const SizedBox(width: 8),
                          _buildPriceTypeToggle(true, 'Négociable', Icons.handshake_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Etat
                TogoSlideUp(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('État', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final c in ['Neuf', 'Occasion'])
                            Expanded(
                              child: Obx(() => TogoPressableScale(
                                onTap: () => _controller.condition.value = c,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(right: c == 'Neuf' ? 6 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _controller.condition.value == c ? AppTheme.primaryLight : AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _controller.condition.value == c ? AppTheme.primary : AppTheme.border,
                                      width: _controller.condition.value == c ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _controller.condition.value == c ? AppTheme.primary : AppTheme.foreground)),
                                  ),
                                ),
                              )),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FormSubmitBottomBar(
          controller: _controller,
          label: 'Enregistrer les modifications',
          icon: Icons.save_outlined,
          onSubmit: () => _controller.updateProduct(_product!.id.toString()),
        ),
      ),
    );
  }

  Widget _buildPriceTypeToggle(bool isNegotiable, String label, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = _controller.isPriceNegotiable.value == isNegotiable;
        return TogoPressableScale(
          onTap: () => _controller.isPriceNegotiable.value = isNegotiable,
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
                  Icon(icon, size: 16, color: isSelected ? AppTheme.primary : AppTheme.foreground),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primary : AppTheme.foreground)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
