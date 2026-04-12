import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

class SellerStatBox extends StatelessWidget {
  final String label, value;
  final R r;
  final bool valueSmall;
  const SellerStatBox(
      {super.key,
      required this.label,
      required this.value,
      required this.r,
      this.valueSmall = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: r.s(14)),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(r.rad(14)),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: r.fs(11),
                      color: AppTheme.mutedForeground,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: r.s(4)),
              Text(value,
                  style: TextStyle(
                    fontSize: valueSmall ? r.fs(14) : r.fs(20),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  )),
            ],
          ),
        ),
      );
}
