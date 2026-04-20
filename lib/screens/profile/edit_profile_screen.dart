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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.currentUser.value;
    _nameController = TextEditingController(text: user?.nom ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        setState(() {
          _selectedImage = File(image.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
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

            // Form Section
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
                  const Text(
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
                      // Inscription via Google/Social : email non modifiable
                      return _buildReadOnlyField(
                        'Email (lié à ${user?.providerName ?? "réseau social"})',
                        emailText,
                        icon: Icons.email_outlined,
                        locked: true,
                      );
                    } else {
                      // Inscription par téléphone : peut ajouter/modifier l'email
                      final hasEmail = user?.email != null && user!.email!.isNotEmpty;
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
            const SizedBox(height: 32),

            // Bottom Save Button
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
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
            style: const TextStyle(
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
              color: locked ? AppTheme.muted.withOpacity(0.6) : AppTheme.muted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: locked ? AppTheme.mutedForeground : AppTheme.primary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: locked ? AppTheme.mutedForeground : AppTheme.foreground,
                    ),
                  ),
                ),
                locked
                    ? const Icon(Icons.lock_outline_rounded,
                        size: 16, color: AppTheme.mutedForeground)
                    : const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppTheme.mutedForeground),
              ],
            ),
          ),
        ),
      ],
    );
  }


}
