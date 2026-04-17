import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/model/location_model.dart';
import '../../Api/model/category_model.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../widgets/app_loader.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authController = Get.find<AuthController>();
  String _step = 'welcome';
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  int? _selectedQuartierId;
  final Set<int> _selectedInterests = {};
  bool _obscurePassword = true;
  bool _isLoginFlow = false;
  String? _selectedProfilePhotoPath;

  @override
  void initState() {
    super.initState();
  }

  /// Nom à envoyer avec la mise à jour du téléphone (flux Google + tmp_) : le backend exige `nom`.
  String _resolvedNomForSocialProfile() {
    final fromField = _nameCtrl.text.trim();
    if (fromField.isNotEmpty) return fromField;
    final user = _authController.currentUser.value;
    final fromUser = user?.nom?.trim();
    if (fromUser != null && fromUser.isNotEmpty) return fromUser;
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }
    return 'Utilisateur';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(
        onWillPop: () async {
          if (_step == 'welcome') return true;
          if (_step == 'phone')
            setState(() => _step = 'welcome');
          else if (_step == 'password')
            setState(() => _step = 'phone');
          else if (_step == 'profile')
            Get.offAllNamed('/home');
          else if (_step == 'interests') Get.offAllNamed('/profile-setup');
          return false;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 'welcome':
        return _WelcomeStep(
          key: const ValueKey('welcome'),
          onContinue: () => setState(() => _step = 'phone'),
          onGoogleSign: () async {
            try {
              await AppLoader.wrap(
                context,
                () => _authController.loginWithGoogle(),
                message: 'Authentification Google...',
              );
              if (_authController.isAuthenticated) {
                final user = _authController.currentUser.value;
                if (user != null && user.telephone.startsWith('tmp_')) {
                  // Nouveau compte social ou numéro manquant
                  _nameCtrl.text = user.nom ?? '';
                  setState(() => _step = 'phone');
                } else {
                  _authController.markOnboardingComplete();
                  AppToasts.success(context, "Succès", "Connexion réussie !");
                  Get.offAllNamed('/home');
                }
              }
            } catch (e) {
              print('Erreur Google Auth: $e');
              final errorStr = e.toString().toLowerCase();
              if (!errorStr.contains('cancel') && !errorStr.contains('annul') && !errorStr.contains('abort')) {
                AppToasts.error(context, "Erreur", "Connexion échouée: $e");
              }
            }
          },
        );
      case 'phone':
        final isSocialCompleting = _authController.isAuthenticated &&
            _authController.currentUser.value != null &&
            _authController.currentUser.value!.telephone.startsWith('tmp_');
        return _PhoneStep(
          key: const ValueKey('phone'),
          ctrl: _phoneCtrl,
          onBack: isSocialCompleting
              ? null
              : () => setState(() => _step = 'welcome'),
          onSend: () async {
            final phone = _phoneCtrl.text.trim();
            if (phone.isEmpty) {
              AppToasts.error(context, "Erreur", "Veuillez entrer un numéro de téléphone.");
              return;
            }
            if (!RegExp(r'^\d+$').hasMatch(phone)) {
              AppToasts.error(context, "Erreur", "Le numéro ne doit contenir que des chiffres.");
              return;
            }
            if (phone.length != 8) {
              AppToasts.warning(context, "Format incorrect", "Le numéro doit être composé de exactement 8 chiffres.");
              return;
            }
            final RegExp prefixRegex = RegExp(r'^(90|91|92|93|96|97|98|99|70|71|79)');
            if (!prefixRegex.hasMatch(phone)) {
              AppToasts.error(context, "Réseau inconnu", "Le numéro doit commencer par 90-93, 96-99 (Togocel) ou 70-71, 79 (Moov).");
              return;
            }

            final phoneToUpdate =
                phone.startsWith('+228') ? phone : '+228$phone';

            final confirmed = await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: AppTheme.cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text("Confirmer le numéro",
                    style: TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                content: Text(
                    "Voulez-vous vérifier et utiliser ce numéro :\n$phoneToUpdate ?",
                    style: TextStyle(
                        color: AppTheme.mutedForeground, fontSize: 14)),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text("Modifier",
                        style: TextStyle(color: AppTheme.mutedForeground)),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text("Confirmer",
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            if (isSocialCompleting) {
              try {
                await AppLoader.wrap(
                  context,
                  () => _authController.linkSocialPhone(
                    phoneToUpdate,
                    _resolvedNomForSocialProfile(),
                  ),
                  message: 'Association du numéro...',
                );
                Get.offAllNamed('/profile-setup');
              } catch (e) {
                String errorMsg = e.toString();
                if (errorMsg.contains("taken") ||
                    errorMsg.toLowerCase().contains("déjà") ||
                    errorMsg.contains("already")) {
                  errorMsg = "Ce numéro est déjà utilisé par un autre compte.";
                } else if (errorMsg.toLowerCase().contains("exception")) {
                  errorMsg = errorMsg.replaceAll(
                      RegExp(r'^(ValidationException: |Exception: )'), "");
                }
                AppToasts.error(context, "Erreur", errorMsg);
              }
            } else {
              try {
                await AppLoader.wrap(
                  context,
                  () => _authController.verifyPhone(phoneToUpdate),
                  message: 'Vérification du numéro...',
                );
                // Si ça réussit, le numéro est disponible -> Inscription
                setState(() {
                  _isLoginFlow = false;
                  _step = 'password';
                });
              } catch (e) {
                String errorMsg = e.toString();
                if (errorMsg.contains("taken") ||
                    errorMsg.toLowerCase().contains("déjà") ||
                    errorMsg.contains("already") || 
                    errorMsg.toLowerCase().contains("utilisé")) {
                  // Déjà utilisé -> Connexion
                  setState(() {
                    _isLoginFlow = true;
                    _step = 'password';
                  });
                } else {
                  String msg = errorMsg.replaceAll(RegExp(r'^(ValidationException: |Exception: )'), "");
                  AppToasts.error(context, "Erreur", msg);
                }
              }
            }
          },
        );
      case 'password':
        return _PasswordStep(
          key: const ValueKey('password'),
          ctrl: _passwordCtrl,
          obscureText: _obscurePassword,
          isLoginFlow: _isLoginFlow,
          onToggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onBack: () => setState(() => _step = 'phone'),
          onVerify: () async {
            try {
              final phoneStr = _phoneCtrl.text.startsWith('+228')
                  ? _phoneCtrl.text
                  : '+228${_phoneCtrl.text}';
              try {
                // Tentative de connexion
                await AppLoader.wrap(
                  context,
                  () => _authController.login(phoneStr, _passwordCtrl.text),
                  message: 'Connexion en cours...',
                );
                _authController.markOnboardingComplete();
                AppToasts.success(context, "Succès", "Connexion réussie ! Bienvenue sur Togo Market.");
                Get.offAllNamed('/home');
              } catch (loginError) {
                // La connexion a échoué. Tentative d'inscription.
                try {
                  await AppLoader.wrap(
                    context,
                    () => _authController.register(phoneStr, _passwordCtrl.text),
                    message: 'Création de votre compte...',
                  );
                  AppToasts.success(context, "Inscription réussie", "Compte créé ! Veuillez compléter votre profil.");
                  Get.offAllNamed('/profile-setup');
                } catch (registerError) {
                  // L'inscription a échoué (Probablement car le numéro existe déjà)
                  String errorMsg = registerError.toString();
                  if (errorMsg.contains("taken") ||
                      errorMsg.toLowerCase().contains("déjà") ||
                      errorMsg.contains("already")) {
                    AppToasts.error(context, "Accès refusé", "Mot de passe incorrect ou numéro déjà utilisé.");
                  } else {
                    AppToasts.error(context, "Erreur d'inscription", errorMsg.replaceAll(RegExp(r'^(ValidationException: |Exception: )'), ""));
                  }
                }
              }
            } catch (e) {
              AppToasts.error(context, "Erreur", "Connexion/Inscription échouée");
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  STEP 1 — WELCOME                                    ║
// ╚══════════════════════════════════════════════════════╝
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onGoogleSign;
  const _WelcomeStep(
      {super.key, required this.onContinue, required this.onGoogleSign});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: r.s(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: r.s(40)),

            // Logo
            Container(
              width: r.s(72),
              height: r.s(72),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(r.rad(20)),
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: r.s(36), color: AppTheme.primary),
            ),
            SizedBox(height: r.s(24)),

            // Titre
            Text(
              'Achetez & Vendez\nau Togo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fs(25),
                fontWeight: FontWeight.w900,
                color: AppTheme.foreground,
                height: 1.15,
              ),
            ),
            SizedBox(height: r.s(8)),
            Text(
              'Le moyen le plus simple d\'échanger avec\nvos voisins par chat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: r.fs(14),
                  color: AppTheme.mutedForeground,
                  height: 1.4),
            ),
            SizedBox(height: r.s(28)),

            // Avatars superposés + badge
            Column(
              children: [
                SizedBox(
                  height: r.s(64),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Avatar gauche
                      Positioned(
                        left: r.screenW / 2 - r.s(90),
                        child: _Avatar(
                            url:
                                'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100&fit=crop',
                            size: r.s(52)),
                      ),
                      // Avatar centre (chat)
                      Positioned(
                        left: r.screenW / 2 - r.s(62),
                        child: Container(
                          width: r.s(56),
                          height: r.s(56),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(Icons.chat_bubble,
                              size: r.s(24), color: Colors.white),
                        ),
                      ),
                      // Avatar droite
                      Positioned(
                        left: r.screenW / 2 - r.s(30),
                        child: _Avatar(
                            url:
                                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&fit=crop',
                            size: r.s(52)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.s(12)),
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: r.s(14), vertical: r.s(6)),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(r.rad(20)),
                  ),
                  child: Text(
                    'Plus de 50k commerçants actifs',
                    style: TextStyle(
                      fontSize: r.fs(12),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: r.s(32)),

            // Bouton principal
            GestureDetector(
              onTap: onContinue,
              child: Container(
                width: double.infinity,
                height: r.s(54).clamp(48, 60),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(30)),
                  boxShadow: AppTheme.shadowPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: r.s(18)),
                    SizedBox(width: r.s(8)),
                    Text(
                      'Continuer avec un numéro',
                      style: TextStyle(
                          fontSize: r.fs(15),
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: r.s(20)),

            // Séparateur
            Row(children: [
              const Expanded(child: Divider(color: AppTheme.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.s(12)),
                child: Text('OU CONTINUER AVEC',
                    style: TextStyle(
                        fontSize: r.fs(11),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedForeground,
                        letterSpacing: 0.5)),
              ),
              const Expanded(child: Divider(color: AppTheme.border)),
            ]),
            SizedBox(height: r.s(16)),

            // Bouton Google
            _SocialButton(
              onTap: onGoogleSign,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _GoogleIcon(size: r.s(20)),
                SizedBox(width: r.s(10)),
                Text('Google',
                    style: TextStyle(
                        fontSize: r.fs(15),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.foreground)),
              ]),
            ),
            SizedBox(height: r.s(10)),

            // Bouton Apple
            _SocialButton(
              onTap: () {},
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.apple, color: AppTheme.foreground, size: r.s(22)),
                SizedBox(width: r.s(10)),
                Text('Apple',
                    style: TextStyle(
                        fontSize: r.fs(15),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.foreground)),
              ]),
            ),

            SizedBox(height: r.s(24)),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    fontSize: r.fs(11), color: AppTheme.mutedForeground),
                children: const [
                  TextSpan(text: 'En continuant, vous acceptez nos '),
                  TextSpan(
                      text: 'Conditions\nd\'utilisation',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                  TextSpan(text: ' et notre '),
                  TextSpan(
                      text: 'Politique de confidentialité',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                ],
              ),
            ),
            SizedBox(height: r.s(32)),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  STEP 2 — PHONE                                      ║
// ╚══════════════════════════════════════════════════════╝
class _PhoneStep extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback? onBack;
  final VoidCallback onSend;
  const _PhoneStep(
      {super.key, required this.ctrl, this.onBack, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton retour
          if (onBack != null)
            Padding(
              padding: EdgeInsets.all(r.s(16)),
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: r.s(36),
                  height: r.s(36),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: r.s(18),
                    color: AppTheme.foreground,
                  ),
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.s(20)),

                  // Icône simple
                  Center(
                    child: Container(
                      width: r.s(64),
                      height: r.s(64),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(16)),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        size: r.s(32),
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(24)),

                  // Titre
                  Center(
                    child: Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontSize: r.fs(24),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(8)),

                  // Description
                  Center(
                    child: Text(
                      'Entrez votre numéro pour continuer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.fs(14),
                        color: AppTheme.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(40)),

                  // Champ téléphone
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        // Préfixe
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.s(12),
                            vertical: r.s(14),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.muted,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(r.rad(12)),
                              bottomLeft: Radius.circular(r.rad(12)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '🇹🇬',
                                style: TextStyle(fontSize: r.fs(16)),
                              ),
                              SizedBox(width: r.s(4)),
                              Text(
                                '+228',
                                style: TextStyle(
                                  fontSize: r.fs(14),
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Input
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontSize: r.fs(15),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '00 00 00 00',
                              hintStyle: TextStyle(
                                color: AppTheme.mutedForeground,
                                fontSize: r.fs(15),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: false,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: r.s(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.s(32)),

                  // Bouton envoyer
                  ValueListenableBuilder(
                    valueListenable: ctrl,
                    builder: (_, __, ___) {
                      final enabled = ctrl.text.length >= 8;
                      return GestureDetector(
                        onTap: enabled ? onSend : null,
                        child: Container(
                          width: double.infinity,
                          height: r.s(50),
                          decoration: BoxDecoration(
                            color: enabled ? AppTheme.primary : AppTheme.muted,
                            borderRadius: BorderRadius.circular(r.rad(25)),
                          ),
                          child: Center(
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                fontSize: r.fs(15),
                                fontWeight: FontWeight.w700,
                                color: enabled
                                    ? Colors.white
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: r.s(40)),

                  // Conditions
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: r.fs(11),
                          color: AppTheme.mutedForeground,
                        ),
                        children: const [
                          TextSpan(text: 'En continuant, vous acceptez nos '),
                          TextSpan(
                            text: 'Conditions d\'utilisation',
                            style: TextStyle(
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' et notre\n'),
                          TextSpan(
                            text: 'Politique de confidentialité',
                            style: TextStyle(
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  STEP 3 — PASSWORD                                   ║
// ╚══════════════════════════════════════════════════════╝
class _PasswordStep extends StatelessWidget {
  final TextEditingController ctrl;
  final bool obscureText;
  final bool isLoginFlow;
  final VoidCallback onBack, onVerify, onToggleObscure;
  const _PasswordStep(
      {super.key,
      required this.ctrl,
      required this.obscureText,
      required this.isLoginFlow,
      required this.onBack,
      required this.onVerify,
      required this.onToggleObscure});

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar simple
          Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: r.s(36),
                    height: r.s(36),
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: r.s(20),
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: r.fs(20),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.s(20)),
                  Center(
                    child: Container(
                      width: r.s(64),
                      height: r.s(64),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(16)),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: r.s(32),
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(24)),
                  Center(
                    child: Text(
                      'Entrez votre mot de passe',
                      style: TextStyle(
                        fontSize: r.fs(24),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(8)),
                  Center(
                    child: Text(
                      'Sert pour la connexion et l\'inscription',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.fs(14),
                        color: AppTheme.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(40)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      controller: ctrl,
                      obscureText: obscureText,
                      style: TextStyle(
                        fontSize: r.fs(15),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mot de passe sécurisé',
                        hintStyle: TextStyle(
                          color: AppTheme.mutedForeground,
                          fontSize: r.fs(15),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.mutedForeground,
                            size: r.s(20),
                          ),
                          onPressed: onToggleObscure,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: r.s(16), vertical: r.s(16)),
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(32)),
                  ValueListenableBuilder(
                    valueListenable: ctrl,
                    builder: (_, __, ___) {
                      final enabled = ctrl.text.length >= 6;
                      return GestureDetector(
                        onTap: enabled ? onVerify : null,
                        child: Container(
                          width: double.infinity,
                          height: r.s(50),
                          decoration: BoxDecoration(
                            color: enabled ? AppTheme.primary : AppTheme.muted,
                            borderRadius: BorderRadius.circular(r.rad(25)),
                          ),
                          child: Center(
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                fontSize: r.fs(15),
                                fontWeight: FontWeight.w700,
                                color: enabled
                                    ? Colors.white
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: r.s(24)),
                  if (isLoginFlow)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Get.to(() => const ForgotPasswordPhoneScreen());
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: r.s(40)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


// ╔══════════════════════════════════════════════════════╗
// ║  COMPOSANTS PARTAGÉS (Remplacés pour _WelcomeStep)   ║
// ╚══════════════════════════════════════════════════════╝

/// Bouton réseau social
class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _SocialButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: r.s(50).clamp(44, 58),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(12)),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      ),
    );
  }
}

/// Icône Google SVG-like
class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.3, 3.77, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.47, 1.05, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 4.52, 0.79, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 5.31, 1.25, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.62, paint);
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(center.dx, center.dy - radius * 0.25, radius * 0.9, radius * 0.5), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Avatar circulaire avec image réseau
class _Avatar extends StatelessWidget {
  final String url;
  final double size;
  const _Avatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      );
}

