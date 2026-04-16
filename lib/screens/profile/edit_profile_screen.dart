import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/app_controller.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<AppController>();
    _nameController = TextEditingController(text: ctrl.userName.value);
    _locationController = TextEditingController(text: ctrl.userLocation.value);
    _bioController = TextEditingController(text: ctrl.userBio.value);
    _emailController = TextEditingController(text: ctrl.userEmail.value);
    _phoneController = TextEditingController(text: ctrl.userPhone.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Get.find<AppController>();
    ctrl.userName.value = _nameController.text.trim();
    ctrl.userLocation.value = _locationController.text.trim();
    ctrl.userBio.value = _bioController.text.trim();
    ctrl.userEmail.value = _emailController.text.trim();
    ctrl.userPhone.value = _phoneController.text.trim();

    Get.snackbar(
      'Succès',
      'Profil mis à jour avec succès',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.foreground),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: Get.back,
        ),
        actions: [
          // Ajouter un texte enregistrer de cette couleur AppTheme.primary juste un texte pas vraiment un bouton
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          children: [
            // ── Photo de Profil ──────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() => Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: AppTheme.shadowCard,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    ctrl.userAvatar.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: TogoPressableScale(
                          onTap: () {
                            // Ici on pourrait ouvrir un sélecteur d'image
                            Get.snackbar(
                              'Info',
                              'Sélecteur d\'image bientôt disponible',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tapotez pour changer la photo',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.mutedForeground),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Champs de formulaire ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informations de base'),
                  const SizedBox(height: 16),
                  _buildField('Nom complet', _nameController,
                      icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildField('Email', _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildField('Téléphone', _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildField('Localisation', _locationController,
                      icon: Icons.location_on_outlined),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Bio ──────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('À propos de vous'),
                  const SizedBox(height: 16),
                  _buildBioField(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Bouton Sauvegarder ──────────────────────────────────────────
            TogoPressableScale(
              onTap: _saveProfile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.shadowPrimary,
                ),
                child: const Center(
                  child: Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.primary,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedForeground),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppTheme.primary.withOpacity(0.7))
                : null,
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biographie',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedForeground),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _bioController,
              builder: (context, value, child) {
                final count = value.text.length;
                return Text(
                  '$count/150',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: count > 140 ? Colors.red : AppTheme.mutedForeground,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioController,
          maxLength: 150,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, height: 1.5),
          decoration: InputDecoration(
            counterText:
                "", // On cache le compteur par défaut car on a le nôtre
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            hintText: 'Décrivez-vous en quelques mots...',
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
