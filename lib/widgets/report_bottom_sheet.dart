import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Api/provider/auth_controller.dart';
import '../Api/services/report_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_toasts.dart';
import '../utils/responsive.dart';

class ReportBottomSheet extends StatefulWidget {
  final String type; // 'product' or 'shop'
  final String targetId;

  const ReportBottomSheet({
    super.key,
    required this.type,
    required this.targetId,
  });

  static void show(BuildContext context, {required String type, required String targetId}) {
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authCtrl == null || !authCtrl.isAuthenticated) {
      AppToasts.error(context, 'Connexion requise', 'Vous devez être connecté pour effectuer un signalement.');
      Get.toNamed('/auth');
      return;
    }

    final r = R(context);
    Get.bottomSheet(
      ReportBottomSheet(type: type, targetId: targetId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String? _selectedReason;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isLoading = false;

  List<String> get _reasons {
    if (widget.type == 'product') {
      return [
        'Arnaque',
        'Faux produit',
        'Image trompeuse',
        'Produit interdit',
        'Prix abusif',
        'Spam',
        'Autre'
      ];
    } else if (widget.type == 'chat') {
      return [
        'Spam',
        'Arnaque',
        'Harcèlement',
        'Contenu offensant',
        'Tentative de fraude',
        'Autre'
      ];
    } else {
      return [
        'Arnaque',
        'Comportement suspect',
        'Non livraison',
        'Faux produits',
        'Spam',
        'Mauvaise pratique',
        'Autre'
      ];
    }
  }

  String get _title {
    if (widget.type == 'product') return 'Signaler ce produit';
    if (widget.type == 'chat') return 'Signaler cette discussion';
    return 'Signaler cette boutique';
  }

  Future<void> _submitReport(R r) async {
    if (_selectedReason == null) {
      AppToasts.error(context, 'Erreur', 'Veuillez sélectionner un motif de signalement.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ReportService.to.submitReport(
        type: widget.type,
        targetId: widget.targetId,
        reason: _selectedReason!,
        comment: _commentCtrl.text.trim(),
      );
      
      Get.back(); // Fermer le bottom sheet
      
      if (mounted) {
        AppToasts.success(context, 'Signalement envoyé', 'Merci pour votre vigilance. Notre équipe va examiner ce contenu.');
      }
    } catch (e) {
      if (mounted) {
        AppToasts.error(context, 'Erreur', 'Impossible d\'envoyer le signalement. Veuillez réessayer plus tard.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(24))),
      ),
      padding: EdgeInsets.fromLTRB(
        r.s(20),
        r.s(20),
        r.s(20),
        MediaQuery.of(context).viewInsets.bottom + r.s(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: r.s(40),
                height: r.s(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(r.rad(2)),
                ),
              ),
            ),
            SizedBox(height: r.s(20)),
            
            // Header
            Text(
              _title,
              style: TextStyle(
                fontSize: r.fs(20),
                fontWeight: FontWeight.w800,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(8)),
            Text(
              'Aidez-nous à protéger notre communauté en signalant les contenus inappropriés ou frauduleux.',
              style: TextStyle(
                fontSize: r.fs(14),
                color: AppTheme.mutedForeground,
                height: 1.5,
              ),
            ),
            SizedBox(height: r.s(24)),
            
            // Reasons list
            Text(
              'Motif du signalement',
              style: TextStyle(
                fontSize: r.fs(15),
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(12)),
            Wrap(
              spacing: r.s(8),
              runSpacing: r.s(8),
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(10)),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.muted,
                      borderRadius: BorderRadius.circular(r.rad(20)),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.foreground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: r.s(24)),
            
            // Comment
            Text(
              'Commentaire (Optionnel)',
              style: TextStyle(
                fontSize: r.fs(15),
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
              ),
            ),
            SizedBox(height: r.s(12)),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Précisez votre signalement...',
                hintStyle: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                filled: true,
                fillColor: AppTheme.muted.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(r.s(16)),
              ),
            ),
            SizedBox(height: r.s(32)),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: r.s(54),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submitReport(r),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.rad(16)),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Envoyer le signalement',
                        style: TextStyle(
                          fontSize: r.fs(16),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
