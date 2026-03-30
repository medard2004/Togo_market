import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/app_controller.dart';
import '../../utils/responsive.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _step = 'welcome';
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final List<String> _otpDigits = ['', '', '', ''];
  int _otpTimer = 45;
  bool _timerActive = true;
  String _selectedZone = '';
  final Set<String> _selectedInterests = {};

  final _zones = [
    'Agbalépédo',
    'Bè',
    'Tokoin',
    'Adidogomé',
    'Avépozo',
    'Nyékonakpoè',
    'Amadahomé',
    'Kégué',
  ];

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    setState(() {
      _otpTimer = 45;
      _timerActive = true;
    });
    Stream.periodic(const Duration(seconds: 1), (i) => i).take(45).listen((i) {
      if (mounted)
        setState(() {
          _otpTimer = 44 - i;
          if (_otpTimer <= 0) _timerActive = false;
        });
    });
  }

  void _onKeyPress(String key) {
    final filled = _otpDigits.where((d) => d.isNotEmpty).length;
    if (key == '⌫') {
      for (int i = 3; i >= 0; i--) {
        if (_otpDigits[i].isNotEmpty) {
          setState(() => _otpDigits[i] = '');
          return;
        }
      }
    } else if (filled < 4) {
      for (int i = 0; i < 4; i++) {
        if (_otpDigits[i].isEmpty) {
          setState(() => _otpDigits[i] = key);
          break;
        }
      }
      if (filled + 1 == 4) {
        Future.delayed(const Duration(milliseconds: 300),
            () => setState(() => _step = 'profile'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 'welcome':
        return _WelcomeStep(
          key: const ValueKey('welcome'),
          onContinue: () => setState(() => _step = 'phone'),
        );
      case 'phone':
        return _PhoneStep(
          key: const ValueKey('phone'),
          ctrl: _phoneCtrl,
          onBack: () => setState(() => _step = 'welcome'),
          onSend: () {
            _startTimer();
            setState(() => _step = 'otp');
          },
        );
      case 'otp':
        return _OtpStep(
          key: const ValueKey('otp'),
          digits: _otpDigits,
          timer: _otpTimer,
          timerActive: _timerActive,
          onKeyPress: _onKeyPress,
          onResend: _startTimer,
          onBack: () => setState(() => _step = 'phone'),
          onVerify: () => setState(() => _step = 'profile'),
        );
      case 'profile':
        return _ProfileStep(
          key: const ValueKey('profile'),
          nameCtrl: _nameCtrl,
          zones: _zones,
          selectedZone: _selectedZone,
          onZoneChanged: (v) => setState(() => _selectedZone = v ?? ''),
          onBack: () => setState(() => _step = 'otp'),
          onSkip: () => setState(() => _step = 'interests'),
          onContinue: () => setState(() => _step = 'interests'),
        );
      case 'interests':
        return _InterestsStep(
          key: const ValueKey('interests'),
          selected: _selectedInterests,
          onToggle: (id) => setState(() {
            if (_selectedInterests.contains(id))
              _selectedInterests.remove(id);
            else
              _selectedInterests.add(id);
          }),
          onBack: () => setState(() => _step = 'profile'),
          onSkip: () {
            Get.find<AppController>().login();
            Get.offAllNamed('/home');
          },
          onFinish: () {
            Get.find<AppController>().login();
            Get.offAllNamed('/home');
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
  const _WelcomeStep({super.key, required this.onContinue});

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
              onTap: () {},
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

            // Bouton Facebook
            _SocialButton(
              onTap: () {},
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.facebook,
                    color: const Color(0xFF1877F2), size: r.s(22)),
                SizedBox(width: r.s(10)),
                Text('Facebook',
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
  final VoidCallback onBack, onSend;
  const _PhoneStep(
      {super.key,
      required this.ctrl,
      required this.onBack,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton retour
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: r.s(40)),

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
                      'Entrez votre numéro pour recevoir un code de vérification',
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
                  SizedBox(height: r.s(24)),

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
                  const Spacer(),

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
                  SizedBox(height: r.s(16)),
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
// ║  STEP 3 — OTP                                        ║
// ╚══════════════════════════════════════════════════════╝
class _OtpStep extends StatelessWidget {
  final List<String> digits;
  final int timer;
  final bool timerActive;
  final Function(String) onKeyPress;
  final VoidCallback onResend, onBack, onVerify;
  const _OtpStep(
      {super.key,
      required this.digits,
      required this.timer,
      required this.timerActive,
      required this.onKeyPress,
      required this.onResend,
      required this.onBack,
      required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final filled = digits.where((d) => d.isNotEmpty).length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  'Vérification',
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

          SizedBox(height: r.s(24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Entrez le code à 4 chiffres envoyé au',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: r.fs(14), color: AppTheme.mutedForeground),
                ),
                Text(
                  '+228 XX XX XX XX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground),
                ),
                SizedBox(height: r.s(32)),

                // 4 cases OTP simples
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: r.s(6)),
                      width: r.s(44),
                      height: r.s(54),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(r.rad(8)),
                        border: Border.all(
                          color: AppTheme.border,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          digits[i],
                          style: TextStyle(
                            fontSize: r.fs(22),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: r.s(20)),

                // Timer / renvoyer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Vous n\'avez pas reçu le code ? ',
                        style: TextStyle(
                            fontSize: r.fs(13),
                            color: AppTheme.mutedForeground)),
                    GestureDetector(
                      onTap: timerActive ? null : onResend,
                      child: Text(
                        timerActive ? 'Renvoyer (${timer}s)' : 'Renvoyer',
                        style: TextStyle(
                          fontSize: r.fs(13),
                          fontWeight: FontWeight.w700,
                          color: timerActive
                              ? AppTheme.mutedForeground
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.s(32)),

                // Bouton vérifier simple
                GestureDetector(
                  onTap: filled == 4 ? onVerify : null,
                  child: Container(
                    width: double.infinity,
                    height: r.s(50),
                    decoration: BoxDecoration(
                      color: filled == 4 ? AppTheme.primary : AppTheme.muted,
                      borderRadius: BorderRadius.circular(r.rad(25)),
                    ),
                    child: Center(
                      child: Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: r.fs(15),
                          fontWeight: FontWeight.w700,
                          color: filled == 4
                              ? Colors.white
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: r.s(16)),

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
              ],
            ),
          ),

          // Clavier custom
          _NumericKeypad(onKey: onKeyPress, r: r),
          SizedBox(height: r.s(16)),
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
  final List<String> zones;
  final String selectedZone;
  final ValueChanged<String?> onZoneChanged;
  final VoidCallback onBack, onSkip, onContinue;
  const _ProfileStep(
      {super.key,
      required this.nameCtrl,
      required this.zones,
      required this.selectedZone,
      required this.onZoneChanged,
      required this.onBack,
      required this.onSkip,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SafeArea(
      child: Column(
        children: [
          _StepAppBar(
              title: 'Étape 1 sur 2',
              onBack: onBack,
              actionLabel: 'Passer',
              onAction: onSkip),

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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: r.s(16)),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedZone.isEmpty ? null : selectedZone,
                        isExpanded: true,
                        hint: Text('Sélectionnez votre zone',
                            style: TextStyle(
                                color: AppTheme.mutedForeground,
                                fontSize: r.fs(14))),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.mutedForeground, size: r.s(22)),
                        items: zones
                            .map((z) => DropdownMenuItem(
                                value: z,
                                child: Text(z,
                                    style: TextStyle(fontSize: r.fs(14)))))
                            .toList(),
                        onChanged: onZoneChanged,
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
  final Set<String> selected;
  final Function(String) onToggle;
  final VoidCallback onBack, onSkip, onFinish;

  const _InterestsStep(
      {super.key,
      required this.selected,
      required this.onToggle,
      required this.onBack,
      required this.onSkip,
      required this.onFinish});

  static const _interests = [
    {'id': 'mode', 'label': 'Mode', 'icon': Icons.checkroom},
    {
      'id': 'electronique',
      'label': 'Électronique',
      'icon': Icons.electrical_services
    },
    {'id': 'maison', 'label': 'Maison', 'icon': Icons.home},
    {'id': 'beaute', 'label': 'Beauté', 'icon': Icons.brush},
    {'id': 'friperie', 'label': 'Friperie', 'icon': Icons.recycling},
    {'id': 'alimentation', 'label': 'Alimentation', 'icon': Icons.restaurant},
  ];

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
                      itemCount: _interests.length,
                      itemBuilder: (_, i) {
                        final item = _interests[i];
                        final id = item['id'] as String;
                        final label = item['label'] as String;
                        final icon = item['icon'] as IconData;
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
  final VoidCallback onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _StepAppBar(
      {required this.title,
      required this.onBack,
      this.actionLabel,
      this.onAction});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      height: r.s(52),
      padding: EdgeInsets.symmetric(horizontal: r.s(16)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back,
                size: r.s(22), color: AppTheme.foreground),
          ),
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

/// Clavier numérique personnalisé (comme sur la maquette)
class _NumericKeypad extends StatelessWidget {
  final Function(String) onKey;
  final R r;
  const _NumericKeypad({required this.onKey, required this.r});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys
          .map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  if (key.isEmpty) return SizedBox(width: r.screenW / 3);
                  return GestureDetector(
                    onTap: () => onKey(key),
                    child: Container(
                      width: r.screenW / 3,
                      height: r.s(52).clamp(44, 60),
                      alignment: Alignment.center,
                      child: key == '⌫'
                          ? Icon(Icons.backspace_outlined,
                              size: r.s(22), color: AppTheme.foreground)
                          : Text(key,
                              style: TextStyle(
                                  fontSize: r.fs(22),
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.foreground)),
                    ),
                  );
                }).toList(),
              ))
          .toList(),
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
