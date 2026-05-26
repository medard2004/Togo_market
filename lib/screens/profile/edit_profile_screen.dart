import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

import '../../Api/provider/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../../widgets/user_avatar.dart';
import 'change_email_screen.dart';
import 'change_phone_screen.dart';
import '../../../utils/image_optimization_service.dart';
import '../map/unified_map_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _quartierController;
  late final TextEditingController _detailsController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int? _villeId;
  bool _gpsLoading = false;

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    _nameController = TextEditingController(text: user?.nom ?? '');

    // Pré-remplir la ville, le quartier et les détails depuis l'adresse existante
    final adresses = user?.adresses;
    String detailsText = '';
    String quartierText = '';
    if (adresses != null && adresses.isNotEmpty) {
      final firstAdresse = adresses.first;
      if (firstAdresse is Map) {
        detailsText = firstAdresse['details']?.toString() ?? '';
        // Try to get quartier name from nested relation
        final quartierData = firstAdresse['quartier'];
        if (quartierData is Map) {
          quartierText = quartierData['nom']?.toString() ?? '';
        }
      }
    }
    
    // Find ville from user profileQuartierId
    final quartierId = user?.profileQuartierId;
    if (quartierId != null && quartierId > 0) {
      for (var v in authCtrl.locations) {
        final q = v.quartiers.firstWhereOrNull((q) => q.id == quartierId);
        if (q != null) {
          _villeId = v.id;
          if (quartierText.isEmpty) quartierText = q.nom;
          break;
        }
      }
    }
    _quartierController = TextEditingController(text: quartierText);
    _detailsController = TextEditingController(text: detailsText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quartierController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (image != null) {
        final optimizedFile = await ImageOptimizationService.optimizeImage(File(image.path));
        setState(() {
          _selectedImage = optimizedFile;
        });
      }
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text('Erreur'),
        description: const Text("Impossible d'ouvrir la galerie."),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authCtrl = Get.find<AuthController>();
      await authCtrl.updateProfile(
        nom: _nameController.text.trim(),
        details: _detailsController.text.trim(),
        villeId: _villeId,
        quartier: _quartierController.text.trim(),
        photoPath: _selectedImage?.path,
      );

      Get.back();
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: const Text('Profil mis à jour'),
        description: const Text('Vos modifications ont été enregistrées avec succès.'),
        autoCloseDuration: const Duration(seconds: 4),
      );
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text('Erreur'),
        description: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  Future<void> _handleGpsRequest() async {
    final result = await Get.to(() => const UnifiedMapScreen());
    if (result != null && result is Map) {
      setState(() => _gpsLoading = true);
      try {
        final authCtrl = Get.find<AuthController>();
        final location = await authCtrl.getCurrentLocationAndMatch(
          lat: result['latitude'],
          lon: result['longitude']
        );
        if (location != null && mounted) {
          setState(() {
            _villeId = location['villeId'];
            // Fill quartier text from reverse geocoding
            final rawQuartier = location['rawQuartier']?.toString() ?? '';
            if (rawQuartier.isNotEmpty) {
              _quartierController.text = rawQuartier;
            }
            if (result['address'] != null && result['address'].toString().isNotEmpty && result['address'] != "Recherche de l'adresse...") {
              _detailsController.text = result['address'];
            }
          });
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: const Text('Position trouvée'),
            description: const Text('Votre zone a été pré-remplie.'),
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.warning,
            style: ToastificationStyle.flat,
            title: const Text('Non trouvée'),
            description: const Text('Impossible de déterminer votre zone automatiquement.'),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        if (mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: const Text('Erreur'),
            description: const Text('Problème lors de la recherche de la zone.'),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      } finally {
        if (mounted) setState(() => _gpsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: Get.back,
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          children: [
            // Avatar Section
            Center(
              child: Obx(() {
                final user = Get.find<AuthController>().currentUser.value;
                return Column(
                  children: [
                    Stack(
                      children: [
                        _selectedImage != null
                            ? CircleAvatar(
                                radius: 55,
                                backgroundImage: FileImage(_selectedImage!),
                              )
                            : UserAvatar(
                                url: user?.avatarUrl,
                                name: user?.nom ?? '',
                                radius: 55,
                              ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Appuyez pour changer la photo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 32),

            // ── Informations personnelles ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField('Nom complet', _nameController,
                      hintText: 'Koffi Mensah', icon: Icons.person_outline),
                  const SizedBox(height: 18),
                  Obx(() {
                    final authCtrl = Get.find<AuthController>();
                    final user = authCtrl.currentUser.value;
                    final isSocial = user?.isSocialLogin ?? false;
                    final emailText = user?.email ?? 'Non défini';

                    if (isSocial) {
                      return _buildReadOnlyField(
                        'Email (lié à ${user?.providerName ?? "réseau social"})',
                        emailText,
                        icon: Icons.email_outlined,
                        locked: true,
                      );
                    } else {
                      final hasEmail =
                          user?.email != null && user!.email!.isNotEmpty;
                      return _buildReadOnlyField(
                        'Email',
                        hasEmail ? emailText : 'Ajouter un email',
                        icon: Icons.email_outlined,
                        onTap: () => Get.to(() => const ChangeEmailScreen()),
                      );
                    }
                  }),
                  const SizedBox(height: 18),
                  Obx(() {
                    final authCtrl = Get.find<AuthController>();
                    return _buildReadOnlyField(
                      'Téléphone',
                      authCtrl.currentUser.value?.telephone ?? 'Non défini',
                      icon: Icons.phone_android_outlined,
                      onTap: () => Get.to(() => const ChangePhoneScreen()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Localisation ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localisation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton choisir ma localisation
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _gpsLoading ? null : _handleGpsRequest,
                      icon: _gpsLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                          : const Icon(Icons.location_on, color: AppTheme.primary),
                      label: const Text('Choisir ma localisation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Ville
                  const Text(
                    'Ville / Commune',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final authCtrl = Get.find<AuthController>();
                    final villes = authCtrl.locations;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _villeId,
                          isExpanded: true,
                          hint: const Text('Sélectionner une ville'),
                          items: villes
                              .map((v) => DropdownMenuItem(
                                  value: v.id, child: Text(v.nom)))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _villeId = v;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // TextField Quartier / Zone
                  const Text(
                    'Quartier / Zone',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quartierController,
                    decoration: InputDecoration(
                      hintText: 'ex. Adidogomé, Agoè...',
                      filled: true,
                      fillColor: AppTheme.muted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TextField Détails
                  const Text(
                    'Détails supplémentaires (facultatif)',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      hintText:
                          'Ex: Derrière la station Total, portail bleu...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Bouton Enregistrer ────────────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Champ de saisie (requis) ──────────────────────────────────────────────
  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppTheme.primary)
                : null,
            filled: true,
            fillColor: AppTheme.muted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ── Champ en lecture seule (avec action optionnelle) ──────────────────────
  Widget _buildReadOnlyField(
    String label,
    String value, {
    IconData? icon,
    VoidCallback? onTap,
    bool locked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        GestureDetector(
          onTap: locked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: locked ? AppTheme.muted.withValues(alpha: 0.6) : AppTheme.muted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 20,
                      color: locked
                          ? AppTheme.mutedForeground
                          : AppTheme.primary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: locked
                          ? AppTheme.mutedForeground
                          : AppTheme.foreground,
                    ),
                  ),
                ),
                locked
                    ? Icon(Icons.lock_outline_rounded,
                        size: 16, color: AppTheme.mutedForeground)
                    : Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppTheme.mutedForeground),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
