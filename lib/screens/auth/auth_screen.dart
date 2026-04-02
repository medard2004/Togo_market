import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/model/location_model.dart';
import '../../Api/model/category_model.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../widgets/app_loader.dart';

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

  @override
  void initState() {
    super.initState();
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
          else if (_step == 'interests') setState(() => _step = 'profile');
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
            if (phone.length != 8) {
              AppToasts.warning(context, "Format incorrect", "Le numéro doit être composé de exactement 8 chiffres.");
              return;
            }
            final RegExp prefixRegex = RegExp(r'^(9[0-3|6-9]|7[0-1|9])');
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
                  () => _authController.updateProfile(telephone: phoneToUpdate),
                  message: 'Association du numéro...',
                );
                setState(() => _step = 'profile');
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
              setState(() => _step = 'password');
            }
          },
        );
      case 'password':
        return _PasswordStep(
          key: const ValueKey('password'),
          ctrl: _passwordCtrl,
          obscureText: _obscurePassword,
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
                  setState(() => _step = 'profile');
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
      case 'profile':
        return Obx(() {
          final allQuartiers =
              _authController.locations.expand((v) => v.quartiers).toList();
          return _ProfileStep(
            key: const ValueKey('profile'),
            nameCtrl: _nameCtrl,
            detailsCtrl: _detailsCtrl,
            quartiers: allQuartiers,
            selectedQuartierId: _selectedQuartierId,
            onQuartierChanged: (v) => setState(() => _selectedQuartierId = v),
            onSkip: () {
              _authController.markOnboardingComplete();
              Get.offAllNamed('/home');
            },
            onContinue: () {
              if (_nameCtrl.text.isEmpty || _selectedQuartierId == null) {
                AppToasts.warning(context, "Attention", "Veuillez remplir tous les champs");
                return;
              }
              setState(() => _step = 'interests');
            },
          );
        });
      case 'interests':
        return Obx(() => _InterestsStep(
              key: const ValueKey('interests'),
              categories: _authController.categories,
              selected: _selectedInterests,
              onToggle: (id) => setState(() {
                if (_selectedInterests.contains(id)) {
                  _selectedInterests.remove(id);
                } else {
                  _selectedInterests.add(id);
                }
              }),
              onBack: () => setState(() => _step = 'profile'),
              onSkip: () {
                _authController.markOnboardingComplete();
                Get.offAllNamed('/home');
              },
              onFinish: () async {
                try {
                  final user = _authController.currentUser.value;
                  final isSocialCompleting = _authController.isAuthenticated &&
                      user != null &&
                      user.telephone.startsWith('tmp_');
                  String? phoneToUpdate;
                  if (isSocialCompleting && _phoneCtrl.text.isNotEmpty) {
                    phoneToUpdate = _phoneCtrl.text.startsWith('+228')
                        ? _phoneCtrl.text
                        : '+228${_phoneCtrl.text}';
                  }

                  await AppLoader.wrap(
                    context,
                    () => _authController.updateProfile(
                      nom: _nameCtrl.text,
                      telephone: phoneToUpdate,
                      quartierId: _selectedQuartierId ?? 0,
                      selectedCategories: _selectedInterests.toList(),
                      details: _detailsCtrl.text,
                    ),
                    message: 'Configuration de votre espace...',
                  );
                  _authController.markOnboardingComplete();
                  AppToasts.success(context, "Bienvenue", "Votre compte est entièrement configuré !");
                  Get.offAllNamed('/home');
                } catch (e) {
                  AppToasts.error(context, "Erreur", "Impossible de mettre à jour le profil");
                }
              },
            ));
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
  final VoidCallback onBack, onVerify, onToggleObscure;
  const _PasswordStep(
      {super.key,
      required this.ctrl,
      required this.obscureText,
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
// ║  STEP 4 — PROFILE                                    ║
// ╚══════════════════════════════════════════════════════╝
class _ProfileStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController detailsCtrl;
  final List<Quartier> quartiers;
  final int? selectedQuartierId;
  final ValueChanged<int?> onQuartierChanged;
  final VoidCallback onSkip, onContinue;
  const _ProfileStep(
      {super.key,
      required this.nameCtrl,
      required this.detailsCtrl,
      required this.quartiers,
      required this.selectedQuartierId,
      required this.onQuartierChanged,
      required this.onSkip,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: Column(
        children: [
          _StepAppBar(
              title: 'Étape 1 sur 2', actionLabel: 'Passer', onAction: onSkip),

          // Barre orange sous l'AppBar
          Container(height: 2, color: AppTheme.primary),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: r.s(24)),
                  Text('Créez votre profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: r.fs(26),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.foreground)),
                  SizedBox(height: r.s(6)),
                  Text('Aidez vos voisins à vous reconnaître sur le marché.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: r.fs(13), color: AppTheme.primary)),
                  SizedBox(height: r.s(28)),

                  // Avatar circulaire dashed
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: r.s(110),
                        height: r.s(110),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryLight,
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.4),
                              width: 2),
                        ),
                        child: Icon(Icons.person,
                            size: r.s(52),
                            color: AppTheme.primary.withOpacity(0.5)),
                      ),
                      Container(
                        width: r.s(32),
                        height: r.s(32),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.camera_alt,
                            size: r.s(16), color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: r.s(8)),
                  Text('Appuyez pour ajouter une photo',
                      style: TextStyle(
                          fontSize: r.fs(13),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                  SizedBox(height: r.s(28)),

                  // Nom complet
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Nom complet',
                          style: TextStyle(
                              fontSize: r.fs(13),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foreground))),
                  SizedBox(height: r.s(8)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      controller: nameCtrl,
                      style: TextStyle(fontSize: r.fs(14)),
                      decoration: InputDecoration(
                        hintText: 'ex. Koffi Mensah',
                        hintStyle: TextStyle(
                            color: AppTheme.mutedForeground,
                            fontSize: r.fs(14)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: r.s(16), vertical: r.s(14)),
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(16)),

                  // Quartier / Zone
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Quartier / Zone',
                          style: TextStyle(
                              fontSize: r.fs(13),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foreground))),
                  SizedBox(height: r.s(8)),
                  GestureDetector(
                    onTap: () {
                      _showZonePicker(context, quartiers, selectedQuartierId,
                          onQuartierChanged);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(16), vertical: r.s(14)),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(r.rad(12)),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedQuartierId != null
                                  ? quartiers
                                      .firstWhere(
                                          (q) => q.id == selectedQuartierId)
                                      .nom
                                  : 'Rechercher votre zone / quartier',
                              style: TextStyle(
                                fontSize: r.fs(14),
                                color: selectedQuartierId != null
                                    ? AppTheme.foreground
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: AppTheme.mutedForeground, size: r.s(22)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(16)),

                  // Détails Location
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Détails supplémentaires',
                          style: TextStyle(
                              fontSize: r.fs(13),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foreground))),
                  SizedBox(height: r.s(8)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      controller: detailsCtrl,
                      style: TextStyle(fontSize: r.fs(14)),
                      decoration: InputDecoration(
                        hintText: 'ex. Appartement, rue, repère...',
                        hintStyle: TextStyle(
                            color: AppTheme.mutedForeground,
                            fontSize: r.fs(14)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: r.s(16), vertical: r.s(14)),
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(32)),

                  // Bouton continuer
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
                      child: Center(
                        child: Text('Continuer →',
                            style: TextStyle(
                                fontSize: r.fs(15),
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: r.s(16)),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: r.fs(11), color: AppTheme.mutedForeground),
                      children: const [
                        TextSpan(text: 'En continuant vous acceptez '),
                        TextSpan(
                            text: 'Conditions d\'utilisation',
                            style: TextStyle(
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline)),
                        TextSpan(text: ' et\nnotre '),
                        TextSpan(
                            text: 'Politique de confidentialité',
                            style: TextStyle(
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                  SizedBox(height: r.s(24)),
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
// ║  STEP 5 — INTERESTS                                  ║
// ╚══════════════════════════════════════════════════════╝
class _InterestsStep extends StatelessWidget {
  final List<Category> categories;
  final Set<int> selected;
  final Function(int) onToggle;
  final VoidCallback onBack, onSkip, onFinish;

  const _InterestsStep(
      {super.key,
      required this.categories,
      required this.selected,
      required this.onToggle,
      required this.onBack,
      required this.onSkip,
      required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: Column(
        children: [
          _StepAppBar(
              title: 'Étape 2 sur 2',
              onBack: onBack,
              actionLabel: 'Passer',
              onAction: onSkip),
          Container(height: 2, color: AppTheme.primary),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.s(24)),
                  Text('Qu\'est-ce qui vous\nintéresse ?',
                      style: TextStyle(
                          fontSize: r.fs(26),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.foreground,
                          height: 1.2)),
                  SizedBox(height: r.s(8)),
                  Text(
                      'Sélectionnez vos catégories préférées pour personnaliser votre flux.',
                      style: TextStyle(
                          fontSize: r.fs(13), color: AppTheme.mutedForeground)),
                  SizedBox(height: r.s(24)),

                  // Grille 2 colonnes
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: r.s(12),
                        crossAxisSpacing: r.s(12),
                        childAspectRatio: 1.55,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (_, i) {
                        final item = categories[i];
                        final id = item.id;
                        final label = item.nom;
                        final icon =
                            Icons.label_outline; // Fallback generic icon
                        final isSel = selected.contains(id);
                        return GestureDetector(
                          onTap: () => onToggle(id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(r.rad(16)),
                              border: Border.all(
                                color:
                                    isSel ? AppTheme.primary : AppTheme.border,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: r.s(42),
                                  height: r.s(42),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppTheme.primary
                                        : AppTheme.muted,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    size: r.s(22),
                                    color: isSel
                                        ? Colors.white
                                        : AppTheme.foreground,
                                  ),
                                ),
                                SizedBox(height: r.s(10)),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: r.fs(13),
                                    fontWeight: FontWeight.w600,
                                    color: isSel
                                        ? AppTheme.primary
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Terminer
          Padding(
            padding: EdgeInsets.fromLTRB(r.s(24), r.s(12), r.s(24), r.s(24)),
            child: GestureDetector(
              onTap: onFinish,
              child: Container(
                width: double.infinity,
                height: r.s(54).clamp(48, 60),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(30)),
                  boxShadow: AppTheme.shadowPrimary,
                ),
                child: Center(
                  child: Text('Terminer',
                      style: TextStyle(
                          fontSize: r.fs(15),
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  COMPOSANTS PARTAGÉS                                 ║
// ╚══════════════════════════════════════════════════════╝

/// AppBar réutilisable pour les étapes internes
class _StepAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _StepAppBar(
      {required this.title, this.onBack, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      height: r.s(52),
      padding: EdgeInsets.symmetric(horizontal: r.s(16)),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back,
                  size: r.s(22), color: AppTheme.foreground),
            )
          else
            SizedBox(width: r.s(22)),
          Expanded(
            child: Center(
              child: Text(title,
                  style: TextStyle(
                      fontSize: r.fs(16),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary)),
            )
          else
            SizedBox(width: r.s(40)),
        ],
      ),
    );
  }
}

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

    // Simplified G shape using arcs
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.3, 3.77,
        true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.47, 1.05,
        true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 4.52, 0.79,
        true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 5.31, 1.25,
        true, paint);

    // Masque central blanc
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.62, paint);

    // Rectangle blanc pour le G
    paint.color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(
            center.dx, center.dy - radius * 0.25, radius * 0.9, radius * 0.5),
        paint);
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

void _showZonePicker(BuildContext context, List<Quartier> quartiers,
    int? currentId, ValueChanged<int?> onSelected) {
  final r = R(context);
  final searchCtrl = TextEditingController();
  final rxQuartiers = RxList<Quartier>(quartiers);

  searchCtrl.addListener(() {
    final query = searchCtrl.text.toLowerCase();
    if (query.isEmpty) {
      rxQuartiers.assignAll(quartiers);
    } else {
      rxQuartiers.assignAll(
          quartiers.where((q) => q.nom.toLowerCase().contains(query)));
    }
  });

  Get.bottomSheet(
    Container(
      height: r.screenH * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(24))),
      ),
      child: Column(
        children: [
          SizedBox(height: r.s(12)),
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(10))),
          SizedBox(height: r.s(16)),
          Text('Choisissez votre zone',
              style: TextStyle(
                  fontSize: r.fs(18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          SizedBox(height: r.s(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s(20)),
            child: Container(
              decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                  border: Border.all(color: AppTheme.border)),
              child: TextField(
                controller: searchCtrl,
                style: TextStyle(fontSize: r.fs(14)),
                decoration: InputDecoration(
                  hintText: 'Rechercher un quartier...',
                  hintStyle: TextStyle(
                      color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.mutedForeground),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: r.s(14)),
                ),
              ),
            ),
          ),
          SizedBox(height: r.s(12)),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: rxQuartiers.length,
                  itemBuilder: (context, i) {
                    final q = rxQuartiers[i];
                    final isSel = q.id == currentId;
                    return ListTile(
                      title: Text(q.nom,
                          style: TextStyle(
                              fontSize: r.fs(15),
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel
                                  ? AppTheme.primary
                                  : AppTheme.foreground)),
                      trailing: isSel
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.primary)
                          : null,
                      onTap: () {
                        onSelected(q.id);
                        Get.back();
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
