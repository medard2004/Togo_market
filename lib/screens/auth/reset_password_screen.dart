import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../widgets/app_loader.dart';
import '../../Api/provider/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String telephone;

  const ResetPasswordScreen({super.key, required this.telephone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _resendTimer = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendTimer = 59);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onResendCode() async {
    if (_resendTimer > 0) return;
    try {
      await AppLoader.wrap(
        context,
        () => _authController.requestPasswordReset(widget.telephone),
        message: 'Renvoi du code...',
      );
      AppToasts.success(context, "Code renvoyé", "Un nouveau code a été envoyé.");
      _startTimer();
    } catch (e) {
      String errorMsg = e.toString().replaceAll(RegExp(r'^(ValidationException: |Exception: )'), "");
      AppToasts.error(context, "Erreur", errorMsg);
    }
  }

  void _onConfirm() async {
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (code.length != 6) {
      AppToasts.warning(context, "Code incomplet", "Veuillez entrer le code à 6 chiffres.");
      return;
    }
    if (password.length < 6) {
      AppToasts.warning(context, "Mot de passe faible", "Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }
    if (password != confirmPassword) {
      AppToasts.error(context, "Erreur", "Les mots de passe ne correspondent pas.");
      return;
    }

    try {
      await AppLoader.wrap(
        context,
        () => _authController.resetPassword(widget.telephone, code, password),
        message: 'Réinitialisation...',
      );
      AppToasts.success(context, "Succès", "Votre mot de passe a été réinitialisé.");
      // Retour à l'écran de login
      Get.offAllNamed('/auth'); // ou la route qui mène au login propre
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.toLowerCase().contains("exception")) {
        errorMsg = errorMsg.replaceAll(RegExp(r'^(ValidationException: |Exception: )'), "");
      }
      AppToasts.error(context, "Erreur", errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    
    final defaultPinTheme = PinTheme(
      width: r.s(56),
      height: r.s(56),
      textStyle: TextStyle(
        fontSize: r.fs(22),
        color: AppTheme.foreground,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(r.rad(12)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppTheme.primary),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(r.s(16)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
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
                          Icons.vpn_key_outlined,
                          size: r.s(32),
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: r.s(24)),
                    Center(
                      child: Text(
                        'Réinitialiser votre mot de passe',
                        textAlign: TextAlign.center,
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
                        'Entrez le code à 6 chiffres reçu par SMS au ${widget.telephone}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: r.fs(14),
                          color: AppTheme.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: r.s(40)),
                    
                    // Pinput for OTP
                    Center(
                      child: Pinput(
                        length: 6,
                        controller: _codeCtrl,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: defaultPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) => print(pin),
                      ),
                    ),
                    SizedBox(height: r.s(32)),

                    // New Password Field
                    _buildPasswordField(
                      controller: _passwordCtrl,
                      hint: 'Nouveau mot de passe',
                      obscure: _obscurePassword,
                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      r: r,
                    ),
                    SizedBox(height: r.s(16)),

                    // Confirm Password Field
                    _buildPasswordField(
                      controller: _confirmPasswordCtrl,
                      hint: 'Confirmer le nouveau mot de passe',
                      obscure: _obscureConfirmPassword,
                      onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      r: r,
                    ),
                    SizedBox(height: r.s(32)),

                    // Validation Button
                    ValueListenableBuilder(
                      valueListenable: _codeCtrl,
                      builder: (_, __, ___) {
                        return ValueListenableBuilder(
                          valueListenable: _passwordCtrl,
                          builder: (_, __, ___) {
                            return ValueListenableBuilder(
                                valueListenable: _confirmPasswordCtrl,
                                builder: (_, __, ___) {
                                  final enabled = _codeCtrl.text.length == 6 &&
                                      _passwordCtrl.text.length >= 6 &&
                                      _confirmPasswordCtrl.text.length >= 6;
                                  return GestureDetector(
                                    onTap: enabled ? _onConfirm : null,
                                    child: Container(
                                      width: double.infinity,
                                      height: r.s(50),
                                      decoration: BoxDecoration(
                                        color: enabled ? AppTheme.primary : AppTheme.muted,
                                        borderRadius: BorderRadius.circular(r.rad(25)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Confirmer',
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
                                });
                          },
                        );
                      },
                    ),
                    SizedBox(height: r.s(24)),

                    // Resend Code
                    Center(
                      child: GestureDetector(
                        onTap: _onResendCode,
                        child: Text(
                          _resendTimer > 0 
                              ? 'Renvoyer dans 0:${_resendTimer.toString().padLeft(2, '0')}s'
                              : 'Renvoyer le code',
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w600,
                            color: _resendTimer > 0 ? AppTheme.mutedForeground : AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: r.s(40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required R r,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(12)),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          fontSize: r.fs(15),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.mutedForeground,
            fontSize: r.fs(15),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
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
    );
  }
}
