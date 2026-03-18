import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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
  final List<TextEditingController> _otpCtrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(4, (_) => FocusNode());
  String _selectedZone = 'Tokoin';
  int _otpTimer = 30;
  bool _timerActive = true;
  final Set<String> _selectedInterests = {};

  final _zones = ['Agbalépédo','Bè','Tokoin','Adidogomé','Avépozo','Nyékonakpoè','Amadahomé','Kégué'];
  final _interests = [
    {'id': 'mode',        'label': 'Mode',          'emoji': '👗'},
    {'id': 'electronique','label': 'Électronique',  'emoji': '📱'},
    {'id': 'maison',      'label': 'Maison',         'emoji': '🏠'},
    {'id': 'beaute',      'label': 'Beauté',         'emoji': '💄'},
    {'id': 'friperie',    'label': 'Friperie',       'emoji': '👕'},
    {'id': 'services',    'label': 'Alimentation',   'emoji': '🍽️'},
  ];

  void _startTimer() {
    setState(() { _otpTimer = 30; _timerActive = true; });
    Stream.periodic(const Duration(seconds: 1), (i) => i).take(30).listen((i) {
      if (mounted) setState(() { _otpTimer = 29 - i; if (_otpTimer <= 0) _timerActive = false; });
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) _otpFocus[index + 1].requestFocus();
    final code = _otpCtrls.map((c) => c.text).join();
    if (code.length == 4) Future.delayed(const Duration(milliseconds: 200), () => setState(() => _step = 'profile'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // resizeToAvoidBottomInset évite l'overflow clavier
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 'welcome':   return _WelcomeStep(onContinue: () => setState(() => _step = 'phone'));
      case 'phone':     return _PhoneStep(ctrl: _phoneCtrl, onBack: () => setState(() => _step = 'welcome'), onSend: () { _startTimer(); setState(() => _step = 'otp'); });
      case 'otp':       return _OtpStep(ctrls: _otpCtrls, focusNodes: _otpFocus, timer: _otpTimer, timerActive: _timerActive, onChanged: _onOtpChanged, onResend: _startTimer, onBack: () => setState(() => _step = 'phone'));
      case 'profile':   return _ProfileStep(nameCtrl: _nameCtrl, zones: _zones, selectedZone: _selectedZone, onZoneChanged: (v) => setState(() => _selectedZone = v!), onBack: () => setState(() => _step = 'otp'), onContinue: () => setState(() => _step = 'interests'));
      case 'interests': return _InterestsStep(interests: _interests, selected: _selectedInterests, onToggle: (id) => setState(() { if (_selectedInterests.contains(id)) _selectedInterests.remove(id); else _selectedInterests.add(id); }), onFinish: () { Get.find<AppController>().login(); Get.offAllNamed('/home'); });
      default:          return const SizedBox.shrink();
    }
  }
}

// ── Welcome Step ──────────────────────────────────────────────────────────────
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onContinue;
  const _WelcomeStep({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(r.s(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
        child: IntrinsicHeight(
          child: Column(
            children: [
              SizedBox(height: r.s(20)),
              Container(
                width: r.s(72), height: r.s(72),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(r.rad(20))),
                child: Icon(Icons.shopping_bag_outlined, size: r.s(36), color: AppTheme.primary),
              ),
              SizedBox(height: r.s(20)),
              Text('Achetez & Vendez\nau Togo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.fs(28), fontWeight: FontWeight.w800, color: AppTheme.foreground, height: 1.2)),
              SizedBox(height: r.s(24)),
              // Hero card
              Container(
                padding: EdgeInsets.all(r.s(16)),
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(r.rad(20)), boxShadow: AppTheme.shadowCard),
                child: Row(
                  children: [
                    SizedBox(
                      width: r.s(80), height: r.s(48),
                      child: Stack(children: [
                        _avatar('https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100&fit=crop', 0, r),
                        _avatar(null, r.s(24), r, isChat: true),
                        _avatar('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&fit=crop', r.s(48), r),
                      ]),
                    ),
                    SizedBox(width: r.s(12)),
                    Expanded(child: Text('Plus de 50 000 commerçants actifs sur Lomé',
                        style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.foreground))),
                  ],
                ),
              ),
              SizedBox(height: r.s(32)),
              AppButton(label: 'Continuer avec un numéro', onTap: onContinue, icon: Icons.phone),
              SizedBox(height: r.s(16)),
              Row(children: [
                const Expanded(child: Divider(color: AppTheme.border)),
                Padding(padding: EdgeInsets.symmetric(horizontal: r.s(12)),
                    child: Text('ou continuer avec', style: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground))),
                const Expanded(child: Divider(color: AppTheme.border)),
              ]),
              SizedBox(height: r.s(16)),
              Row(children: [
                _socialBtn(child: Text('G', style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w800, color: const Color(0xFF4285F4)))),
                SizedBox(width: r.s(12)),
                _socialBtn(child: Icon(Icons.facebook, color: const Color(0xFF1877F2), size: r.s(24))),
                SizedBox(width: r.s(12)),
                _socialBtn(child: Icon(Icons.apple, color: AppTheme.foreground, size: r.s(24))),
              ]),
              const Spacer(),
              Text("En continuant, vous acceptez nos Conditions d'utilisation",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.fs(11), color: AppTheme.mutedForeground)),
              SizedBox(height: r.s(16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url, double left, R r, {bool isChat = false}) => Positioned(
    left: left,
    child: Container(
      width: r.s(40), height: r.s(40),
      decoration: BoxDecoration(shape: BoxShape.circle, color: isChat ? AppTheme.primary : AppTheme.muted,
          border: Border.all(color: Colors.white, width: 2),
          image: url != null ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null),
      child: isChat ? Icon(Icons.chat_bubble, size: r.s(18), color: Colors.white) : null,
    ),
  );

  Widget _socialBtn({required Widget child}) => Expanded(
    child: Container(
      height: 52,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Center(child: child),
    ),
  );
}

// ── Phone Step ────────────────────────────────────────────────────────────────
class _PhoneStep extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onBack, onSend;
  const _PhoneStep({required this.ctrl, required this.onBack, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(r.s(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(onTap: onBack),
          SizedBox(height: r.s(32)),
          Text('Bienvenue sur\nTogo Market',
              style: TextStyle(fontSize: r.fs(28), fontWeight: FontWeight.w800, color: AppTheme.foreground, height: 1.2)),
          SizedBox(height: r.s(8)),
          Text('Entrez votre numéro pour continuer',
              style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
          SizedBox(height: r.s(32)),
          Text('Numéro de téléphone', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600)),
          SizedBox(height: r.s(8)),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(r.rad(16))),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(14)),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppTheme.border))),
                  child: Text('🇹🇬 +228', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '90 00 00 00', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: r.s(32)),
          ValueListenableBuilder(
            valueListenable: ctrl,
            builder: (_, __, ___) => Opacity(
              opacity: ctrl.text.length >= 8 ? 1 : 0.4,
              child: AppButton(label: 'Envoyer le code →', onTap: ctrl.text.length >= 8 ? onSend : () {}),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP Step ──────────────────────────────────────────────────────────────────
class _OtpStep extends StatelessWidget {
  final List<TextEditingController> ctrls;
  final List<FocusNode> focusNodes;
  final int timer;
  final bool timerActive;
  final Function(int, String) onChanged;
  final VoidCallback onResend, onBack;
  const _OtpStep({required this.ctrls, required this.focusNodes, required this.timer, required this.timerActive, required this.onChanged, required this.onResend, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final boxSize = ((MediaQuery.of(context).size.width - r.s(48) - r.s(48)) / 4).clamp(52.0, 72.0);
    return SingleChildScrollView(
      padding: EdgeInsets.all(r.s(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(onTap: onBack),
          SizedBox(height: r.s(32)),
          Text('Code de vérification', style: TextStyle(fontSize: r.fs(28), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
          SizedBox(height: r.s(8)),
          Text('Entrez le code envoyé par SMS', style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
          SizedBox(height: r.s(40)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) => SizedBox(
              width: boxSize, height: boxSize,
              child: TextField(
                controller: ctrls[i],
                focusNode: focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: r.fs(24), fontWeight: FontWeight.w800, color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.rad(14)), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r.rad(14)), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                  fillColor: AppTheme.muted, filled: true, counterText: '',
                ),
                onChanged: (v) => onChanged(i, v),
              ),
            )),
          ),
          SizedBox(height: r.s(24)),
          Center(
            child: timerActive
                ? Text('Renvoyer dans ${timer}s', style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground))
                : GestureDetector(onTap: onResend, child: Text('Renvoyer le code', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.primary))),
          ),
        ],
      ),
    );
  }
}

// ── Profile Step ──────────────────────────────────────────────────────────────
class _ProfileStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final List<String> zones;
  final String selectedZone;
  final ValueChanged<String?> onZoneChanged;
  final VoidCallback onBack, onContinue;
  const _ProfileStep({required this.nameCtrl, required this.zones, required this.selectedZone, required this.onZoneChanged, required this.onBack, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(r.s(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            AppBackButton(onTap: onBack),
            Text('Étape 1 sur 2', style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground)),
            TextButton(onPressed: onContinue, child: Text('Passer', style: TextStyle(color: AppTheme.mutedForeground, fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: r.s(24)),
          Text('Mon profil', style: TextStyle(fontSize: r.fs(28), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
          SizedBox(height: r.s(24)),
          Center(
            child: Container(
              width: r.s(100), height: r.s(100),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2), color: AppTheme.primaryLight),
              child: Icon(Icons.camera_alt_outlined, size: r.s(36), color: AppTheme.primary),
            ),
          ),
          SizedBox(height: r.s(24)),
          Text('Nom complet', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600)),
          SizedBox(height: r.s(8)),
          TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'ex. Koffi Mensah')),
          SizedBox(height: r.s(16)),
          Text('Quartier / Zone', style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600)),
          SizedBox(height: r.s(8)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.s(16)),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(r.rad(16))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedZone, isExpanded: true,
                items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: onZoneChanged,
              ),
            ),
          ),
          SizedBox(height: r.s(32)),
          AppButton(label: 'Continuer →', onTap: onContinue),
        ],
      ),
    );
  }
}

// ── Interests Step ────────────────────────────────────────────────────────────
class _InterestsStep extends StatelessWidget {
  final List<Map<String, String>> interests;
  final Set<String> selected;
  final Function(String) onToggle;
  final VoidCallback onFinish;
  const _InterestsStep({required this.interests, required this.selected, required this.onToggle, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Padding(
      padding: EdgeInsets.all(r.s(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Étape 2 sur 2', style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground)),
          SizedBox(height: r.s(8)),
          Text('Vos centres d\'intérêt', style: TextStyle(fontSize: r.fs(26), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
          SizedBox(height: r.s(6)),
          Text('Sélectionnez au moins 2 catégories', style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
          SizedBox(height: r.s(20)),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: r.s(12),
                crossAxisSpacing: r.s(12),
                childAspectRatio: 1.6,
              ),
              itemCount: interests.length,
              itemBuilder: (_, i) {
                final item = interests[i];
                final isSel = selected.contains(item['id']);
                return GestureDetector(
                  onTap: () => onToggle(item['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primaryLight : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(16)),
                      border: Border.all(color: isSel ? AppTheme.primary : AppTheme.border, width: 2),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(item['emoji']!, style: TextStyle(fontSize: r.fs(28))),
                      SizedBox(height: r.s(4)),
                      Text(item['label']!, style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600, color: isSel ? AppTheme.primary : AppTheme.foreground)),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: r.s(16)),
          AppButton(label: 'Terminer 🎉', onTap: onFinish),
          SizedBox(height: r.s(16)),
        ],
      ),
    );
  }
}
