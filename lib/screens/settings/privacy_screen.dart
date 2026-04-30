import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Confidentialité'),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Protection des données',
              content:
                  'Chez Togo Market, la protection de vos données personnelles est notre priorité. Nous utilisons des technologies de pointe pour sécuriser vos informations.',
            ),
            SizedBox(height: 24),
            _buildSection(
              title: 'Collecte d\'informations',
              content:
                  'Nous collectons uniquement les informations nécessaires au bon fonctionnement de l\'application : nom, téléphone et localisation pour la livraison.',
            ),
            SizedBox(height: 24),
            _buildSection(
              title: 'Partage avec des tiers',
              content:
                  'Vos données ne sont jamais vendues à des tiers. Elles sont uniquement partagées avec les vendeurs et livreurs pour finaliser vos transactions.',
            ),
            SizedBox(height: 24),
            _buildSection(
              title: 'Vos droits',
              content:
                  'Vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données. Vous pouvez exercer ces droits depuis votre profil.',
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Dernière mise à jour : 27 Avril 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.foreground,
          ),
        ),
      ],
    );
  }
}
