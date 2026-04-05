import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../widgets/app_loader.dart';
import '../../Api/provider/auth_controller.dart';
import 'reset_password_screen.dart';

class ForgotPasswordPhoneScreen extends StatefulWidget {
  const ForgotPasswordPhoneScreen({super.key});

  @override
  State<ForgotPasswordPhoneScreen> createState() => _ForgotPasswordPhoneScreenState();
}

class _ForgotPasswordPhoneScreenState extends State<ForgotPasswordPhoneScreen> {
  final _phoneCtrl = TextEditingController();
  final _authController = Get.find<AuthController>();

  void _onSend() async {
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

    final phoneToUpdate = phone.startsWith('+228') ? phone : '+228$phone';

    try {
      await AppLoader.wrap(
        context,
        () => _authController.requestPasswordReset(phoneToUpdate),
        message: 'Envoi du code...',
      );
      AppToasts.success(context, "Code envoyé", "Un code de réinitialisation a été envoyé par SMS.");
      Get.to(() => ResetPasswordScreen(telephone: phoneToUpdate));
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton retour
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
                          Icons.lock_reset,
                          size: r.s(32),
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: r.s(24)),
                    Center(
                      child: Text(
                        'Mot de passe oublié ?',
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
                        'Entrez le numéro de téléphone associé à votre compte. Nous vous enverrons un code de réinitialisation.',
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
                      child: Row(
                        children: [
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
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
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
                    ValueListenableBuilder(
                      valueListenable: _phoneCtrl,
                      builder: (_, __, ___) {
                        final enabled = _phoneCtrl.text.length >= 8;
                        return GestureDetector(
                          onTap: enabled ? _onSend : null,
                          child: Container(
                            width: double.infinity,
                            height: r.s(50),
                            decoration: BoxDecoration(
                              color: enabled ? AppTheme.primary : AppTheme.muted,
                              borderRadius: BorderRadius.circular(r.rad(25)),
                            ),
                            child: Center(
                              child: Text(
                                'Envoyer le code',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
