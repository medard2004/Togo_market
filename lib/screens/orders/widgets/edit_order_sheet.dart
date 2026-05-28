import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/widgets/togo_button.dart';
import '../../../utils/responsive.dart';

class EditOrderSheet extends StatefulWidget {
  final OrderModel order;
  final Function(Map<String, dynamic>) onSave;

  const EditOrderSheet({super.key, required this.order, required this.onSave});

  @override
  State<EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<EditOrderSheet> {
  late TextEditingController _qtyCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _notesCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.order.quantity.toString());
    _phoneCtrl = TextEditingController(text: widget.order.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.order.deliveryAddress ?? '');
    _notesCtrl = TextEditingController(text: widget.order.notes ?? '');
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'quantity': int.tryParse(_qtyCtrl.text) ?? widget.order.quantity,
        'phone': _phoneCtrl.text,
        'delivery_address': _addressCtrl.text,
        'notes': _notesCtrl.text,
      });
      Get.back();
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
      padding: EdgeInsets.all(r.s(20)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: r.s(40),
                  height: r.s(4),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(r.rad(2)),
                  ),
                ),
              ),
              SizedBox(height: r.s(20)),
              Text(
                'Modifier la commande',
                style: TextStyle(
                  fontSize: r.fs(18),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              SizedBox(height: r.s(20)),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.mutedForeground),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Veuillez entrer une quantité';
                  if (int.tryParse(val) == null || int.parse(val) < 1) return 'Quantité invalide';
                  return null;
                },
              ),
              SizedBox(height: r.s(16)),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.mutedForeground),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Veuillez entrer un numéro';
                  return null;
                },
              ),
              SizedBox(height: r.s(16)),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.mutedForeground),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Veuillez entrer une adresse';
                  return null;
                },
              ),
              SizedBox(height: r.s(16)),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: r.s(24)),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Enregistrer les modifications',
                  onTap: _submit,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
