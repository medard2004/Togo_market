import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../Api/model/product_model.dart';
import '../utils/app_toasts.dart';
import '../Api/services/produit_service.dart';
import 'app_controller.dart';
import '../Api/core/api_client.dart';
import '../utils/boutique_category_filter.dart';
import '../widgets/category_picker_bottom_sheet.dart';
import 'boutique_controller.dart';

class ProductFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final condition = 'Neuf'.obs;
  final isPriceNegotiable = false.obs;
  final selectedCategory = RxnInt(); // Using int for DB ID consistency

  final images = <XFile>[].obs;
  final existingImages = <String>[].obs; 
  final existingImageIds = <int>[].obs;

  final isLoading = false.obs;
  final isPickingImage = false.obs; // Prevention flag for PlatformException

  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  void initForAdd() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    condition.value = 'Neuf';
    isPriceNegotiable.value = false;
    selectedCategory.value = null; // Reset to null so user must select 
    images.clear();
    existingImages.clear();
    existingImageIds.clear();
  }

  void initForEdit(Product product) {
    titleController.text = product.title;
    descriptionController.text = product.description;
    priceController.text =
        product.price == 0 ? '' : product.price.toStringAsFixed(0);
    condition.value = product.condition;
    isPriceNegotiable.value = product.isPriceNegotiable;
    selectedCategory.value = int.tryParse(product.category);
    if (Get.isRegistered<BoutiqueController>() && Get.isRegistered<AppController>()) {
      final b = Get.find<BoutiqueController>().myBoutique.value;
      final ids = parseBoutiqueCategoryIds(b?.categories);
      final flat = Get.find<AppController>().allFlatCategories;
      final catId = selectedCategory.value;
      if (ids.isEmpty || catId == null || !isProductCategoryAllowedForBoutique(catId, ids, flat)) {
        selectedCategory.value = null;
      }
    }
    images.clear();
    existingImages.clear();
    existingImageIds.clear();
    
    // Extract both URLs and their corresponding IDs from rawImages
    for (var rawImg in product.rawImages) {
       existingImages.add(rawImg['chemin_image'] ?? '');
       if (rawImg['id'] != null) {
         existingImageIds.add(rawImg['id'] as int);
       }
    }
  }

  Future<void> pickImages() async {
    if (isPickingImage.value) return; // Guard against rapid clicks

    if (images.length + existingImages.length >= 5) {
      if (Get.context != null) {
        AppToasts.warning(Get.context!, 'Limite atteinte',
            'Vous ne pouvez ajouter que 5 images maximum.');
      }
      return;
    }

    try {
      isPickingImage.value = true;
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (picked.isNotEmpty) {
        // Calculate how many we can take
        final availableSlots = 5 - (images.length + existingImages.length);
        if (picked.length > availableSlots) {
          if (Get.context != null) {
            AppToasts.info(Get.context!, 'Limite dépassée',
                'Seules les premières $availableSlots images ont été ajoutées.');
          }
        }
        final toAdd = <XFile>[];
        for (var file in picked.take(availableSlots)) {
          final fileSize = await File(file.path).length();
          if (fileSize > 5242880) {
            // 5 Mo = 5242880 bytes
            if (Get.context != null) {
              AppToasts.warning(Get.context!, 'Image trop volumineuse',
                  '${file.name} dépasse 5 Mo et a été ignorée.');
            }
          } else {
            toAdd.add(file);
          }
        }
        images.addAll(toAdd);
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    } finally {
      isPickingImage.value = false;
    }
  }

  void removeNewImage(int index) {
    images.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImages.removeAt(index);
    if (index < existingImageIds.length) {
      existingImageIds.removeAt(index);
    }
  }

  Future<void> submitProduct() async {
    if (!formKey.currentState!.validate()) return;

    if (images.isEmpty) {
      if (Get.context != null) {
        AppToasts.error(
            Get.context!, 'Erreur', 'Veuillez ajouter au moins une image.');
      }
      return;
    }

    if (selectedCategory.value == null) {
      if (Get.context != null) {
        AppToasts.error(
            Get.context!, 'Erreur', 'Veuillez sélectionner une catégorie.');
      }
      return;
    }

    // Ensure user has a boutique before publishing store product
    if (Get.isRegistered<BoutiqueController>()) {
      final bc = Get.find<BoutiqueController>();
      if (bc.myBoutique.value == null) {
        // Redirect user to create/configure boutique flow
        await bc.goToMyBoutique();
        return;
      }
      final boutique = bc.myBoutique.value!;
      final allowedIds = parseBoutiqueCategoryIds(boutique.categories);
      if (allowedIds.isEmpty) {
        if (Get.context != null) {
          AppToasts.warning(
            Get.context!,
            'Catégories manquantes',
            'Ajoutez d’abord les catégories de votre boutique dans les paramètres.',
          );
        }
        return;
      }
      if (Get.isRegistered<AppController>()) {
        final flat = Get.find<AppController>().allFlatCategories;
        if (!isProductCategoryAllowedForBoutique(
            selectedCategory.value!, allowedIds, flat)) {
          if (Get.context != null) {
            AppToasts.error(
              Get.context!,
              'Erreur',
              'Choisissez une catégorie parmi celles de votre boutique.',
            );
          }
          return;
        }
      }
    }

    isLoading.value = true;

    try {
      final formDataMap = {
        'titre': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'prix': priceController.text.trim(),
        'prix_negociable': isPriceNegotiable.value ? 1 : 0,
        'etat': condition.value,
        'categorie_id': selectedCategory.value,
      };

      final data = dio.FormData.fromMap(formDataMap);

      for (var file in images) {
        data.files.add(
          MapEntry(
            'images[]',
            await dio.MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      await ProduitService.to.addStoreProduct(data);

      if (Get.context != null) {
        AppToasts.success(
            Get.context!, 'Succès', 'Annonce publiée avec succès !');
      }

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().onInit(); // refresh products
      }
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().fetchProduits(); // refresh global products
      }

      Get.back(); // Pop screen
    } catch (e) {
      // More explicit error handling for common API exceptions
      if (e is ValidationException) {
        if (Get.context != null) AppToasts.error(Get.context!, 'Erreur', e.message);
      } else if (e is UnauthorizedException) {
        if (Get.context != null) AppToasts.error(Get.context!, 'Erreur', e.message);
        // Force re-authentication
        Get.offAllNamed('/auth');
      } else {
        if (Get.context != null) {
          AppToasts.error(Get.context!, 'Erreur', 'Échec de la publication : $e');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String productId) async {
    if (!formKey.currentState!.validate()) return;

    if (images.isEmpty && existingImages.isEmpty) {
      if (Get.context != null) {
        AppToasts.error(Get.context!, 'Erreur', 'Un produit doit avoir au moins une image.');
      }
      return;
    }

    if (selectedCategory.value == null) {
      if (Get.context != null) {
        AppToasts.error(
            Get.context!, 'Erreur', 'Veuillez sélectionner une catégorie.');
      }
      return;
    }

    if (Get.isRegistered<BoutiqueController>() && Get.isRegistered<AppController>()) {
      final boutique = Get.find<BoutiqueController>().myBoutique.value;
      if (boutique != null) {
        final allowedIds = parseBoutiqueCategoryIds(boutique.categories);
        if (allowedIds.isEmpty) {
          if (Get.context != null) {
            AppToasts.warning(
              Get.context!,
              'Catégories manquantes',
              'Ajoutez d’abord les catégories de votre boutique dans les paramètres.',
            );
          }
          return;
        }
        final flat = Get.find<AppController>().allFlatCategories;
        if (!isProductCategoryAllowedForBoutique(
            selectedCategory.value!, allowedIds, flat)) {
          if (Get.context != null) {
            AppToasts.error(
              Get.context!,
              'Erreur',
              'Choisissez une catégorie parmi celles de votre boutique.',
            );
          }
          return;
        }
      }
    }

    isLoading.value = true;

    try {
      // In Laravel PUT with multipart/form-data doesn't always work nicely,
      // it's best to use POST and add _method=PUT.
      final formDataMap = {
        '_method': 'PUT',
        'titre': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'prix': priceController.text.trim(),
        'prix_negociable': isPriceNegotiable.value ? 1 : 0,
        'etat': condition.value,
        'categorie_id': selectedCategory.value,
      };

      final data = dio.FormData.fromMap(formDataMap);

      // Nouvelles images
      for (var file in images) {
        data.files.add(
          MapEntry(
            'nouvelles_images[]',
            await dio.MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      // Images à garder (IDs pour que l'API Laravel ne les supprime pas)
      for (var id in existingImageIds) {
        data.fields.add(MapEntry('images_a_garder[]', id.toString()));
      }

      await ProduitService.to.updateProduct(productId, data);

      if (Get.context != null) {
        AppToasts.success(Get.context!, 'Succès', 'Produit mis à jour avec succès !');
      }

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().onInit();
      }
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().fetchProduits();
      }

      Get.back();
    } catch (e) {
      if (Get.context != null) {
        AppToasts.error(Get.context!, 'Erreur', 'Mise à jour échouée : $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Ouvre le sélecteur limité aux catégories de la boutique (règle B : sous-arbres).
  Future<void> openBoutiqueCategoryPicker(BuildContext context) async {
    if (!Get.isRegistered<AppController>() || !Get.isRegistered<BoutiqueController>()) {
      AppToasts.error(
        context,
        'Erreur',
        'Impossible de charger les catégories. Redémarrez l’application ou reconnectez-vous.',
      );
      return;
    }
    final appCtrl = Get.find<AppController>();
    final bc = Get.find<BoutiqueController>();

    await bc.silentRefreshMyBoutique();

    final boutique = bc.myBoutique.value;

    if (boutique == null) {
      bc.goToMyBoutique();
      return;
    }

    final allowedIds = parseBoutiqueCategoryIds(boutique.categories);
    if (allowedIds.isEmpty) {
      AppToasts.warning(
        context,
        'Catégories manquantes',
        'Définissez les catégories de votre boutique (Paramètres > Modifier la boutique) avant de publier un article.',
      );
      return;
    }

    final filtered = filterCategoryTreeForBoutiqueProducts(
      appCtrl.categories,
      allowedIds,
    );
    if (filtered.isEmpty) {
      AppToasts.warning(
        context,
        'Catégories',
        'Aucune catégorie compatible avec votre configuration. Vérifiez les paramètres de la boutique.',
      );
      return;
    }

    CategoryPickerBottomSheet.show(
      context,
      categories: filtered,
      onCategorySelected: (cat) {
        selectedCategory.value = cat.id;
      },
    );
  }
}
