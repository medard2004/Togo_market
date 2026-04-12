import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;
  const ProfileStatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.mutedForeground)),
            ],
          ),
        ),
      );
}
