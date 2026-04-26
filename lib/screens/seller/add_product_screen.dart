import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/product_form_controller.dart';
import '../../controllers/app_controller.dart';
import '../../utils/category_icon_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _controller = Get.put(ProductFormController());

  @override
  void initState() {
    super.initState();
    _controller.initForAdd();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Ajouter un produit'),
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
                          Obx(() => Text('${_controller.images.length}/5', style: TextStyle(fontSize: 12, color: _controller.images.isEmpty ? Colors.red : AppTheme.primary))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Ajoutez au moins 1 photo (5 maximum).', style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
                      const SizedBox(height: 4),
                      const Text('Formats : JPEG, PNG, WebP • Taille max : 5 Mo par image',
                          style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (_controller.images.isEmpty) {
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt_outlined, size: 32, color: AppTheme.primary),
                                  const SizedBox(height: 8),
                                  const Text('Appuyez pour ajouter des photos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
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
                              ...List.generate(_controller.images.length, (i) => Stack(
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
                              )),
                              if (_controller.images.length < 5)
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
                        decoration: const InputDecoration(hintText: 'Ex: Je vends mon iPhone 13 Pro Max en très bon état, acheté il y a 6 mois...'),
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
                              onTap: () => _controller.openBoutiqueCategoryPicker(context),
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
                                          child: Text('Sélectionner',
                                              style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
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
                                          child: Text('Sélectionner',
                                              style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
                                        ),
                                        Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.mutedForeground),
                                      ],
                                    );
                                  }
                                  
                                  return Row(
                                    children: [
                                      Icon(
                                        CategoryIconHelper.getIcon(matchingCat.slug),
                                        size: 16,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          matchingCat.nom,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.foreground),
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
          label: "Publier l'annonce",
          icon: Icons.upload_outlined,
          onSubmit: _controller.submitProduct,
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

class FormSubmitBottomBar extends StatelessWidget {
  final ProductFormController controller;
  final String label;
  final IconData icon;
  final VoidCallback onSubmit;

  const FormSubmitBottomBar({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: AppTheme.shadowCardLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('En publiant, vous acceptez nos Conditions d\'utilisation', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppTheme.mutedForeground)),
          const SizedBox(height: 10),
          Obx(() => AppButton(
            label: controller.isLoading.value ? 'Chargement...' : label,
            isLoading: controller.isLoading.value,
            onTap: controller.isLoading.value ? () {} : onSubmit,
            icon: icon,
          )),
        ],
      ),
    );
  }
}
