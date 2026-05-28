import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../models/order_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/app_toasts.dart';
import '../../controllers/order_controller.dart';

class RefundRequestScreen extends StatefulWidget {
  final OrderModel order;
  const RefundRequestScreen({super.key, required this.order});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _descriptionCtrl = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedReason;
  bool _isLoading = false;

  final List<String> _reasons = [
    'Produit non reçu',
    'Mauvais produit',
    'Produit défectueux',
    'Produit différent de la description',
    'Autre'
  ];

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 70,
      );
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked.map((x) => File(x.path)));
          // Limit to 5 images max
          if (_images.length > 5) {
            _images.removeRange(5, _images.length);
            AppToasts.error(context, 'Limite atteinte', 'Vous ne pouvez ajouter que 5 photos maximum.');
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur sélection image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      AppToasts.error(context, 'Attention', 'Veuillez sélectionner un motif de remboursement.');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final formData = dio.FormData.fromMap({
        'reason': _selectedReason,
        'description': _descriptionCtrl.text,
      });

      for (var i = 0; i < _images.length; i++) {
        formData.files.add(MapEntry(
          'images[$i]',
          await dio.MultipartFile.fromFile(_images[i].path),
        ));
      }

      await OrderController.to.requestRefund(context, widget.order, formData);
      Get.back(); // Retour à la page des détails
    } catch (e) {
      // Les erreurs sont gérées dans le contrôleur
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text('Demander un remboursement',
            style: TextStyle(fontSize: r.fs(16), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(8), r.hPad, r.s(160)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Container(
              padding: EdgeInsets.all(r.s(16)),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.rad(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: r.s(20)),
                  SizedBox(width: r.s(12)),
                  Expanded(
                    child: Text(
                      'Votre demande de remboursement sera analysée par le vendeur puis par notre équipe pour vous garantir une solution équitable.',
                      style: TextStyle(fontSize: r.fs(13), color: Colors.blue.shade700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(24)),

            // Motif
            Text('MOTIF DE LA DEMANDE',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w700, color: AppTheme.mutedForeground, letterSpacing: 1.0)),
            SizedBox(height: r.s(8)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: r.s(12)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  hint: Text('Sélectionnez un motif', style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
                  items: _reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason, style: TextStyle(fontSize: r.fs(14), color: AppTheme.foreground)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedReason = val;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: r.s(24)),

            // Description
            Text('EXPLICATION DÉTAILLÉE',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w700, color: AppTheme.mutedForeground, letterSpacing: 1.0)),
            SizedBox(height: r.s(8)),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _descriptionCtrl,
                maxLines: 4,
                style: TextStyle(fontSize: r.fs(14), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  hintText: 'Expliquez en détail le problème rencontré avec la commande...',
                  hintStyle: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground),
                ),
              ),
            ),
            SizedBox(height: r.s(24)),

            // Preuves
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PREUVES (PHOTOS)',
                    style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w700, color: AppTheme.mutedForeground, letterSpacing: 1.0)),
                Text('${_images.length}/5',
                    style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
              ],
            ),
            SizedBox(height: r.s(8)),
            Wrap(
              spacing: r.s(8),
              runSpacing: r.s(8),
              children: [
                ...List.generate(_images.length, (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(r.rad(8)),
                        child: Image.file(
                          _images[index],
                          width: r.s(70),
                          height: r.s(70),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: r.s(14)),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_images.length < 5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: r.s(70),
                      height: r.s(70),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(r.rad(8)),
                        border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppTheme.primary, size: r.s(24)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(16), r.hPad, r.s(20) + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: r.s(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.rad(16))),
            ),
            child: _isLoading
                ? SizedBox(width: r.s(20), height: r.s(20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Envoyer la demande', style: TextStyle(fontWeight: FontWeight.w700, fontSize: r.fs(15))),
          ),
        ),
      ),
    );
  }
}
