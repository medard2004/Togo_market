import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Politique de retour'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Permettez à vos clients de retourner leurs achats en toute confiance. '
              'Cette politique décrit les délais, conditions et étapes pour un retour simple et transparent.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('1. Délai de retour'),
          const SizedBox(height: 10),
          const Text(
            'Les clients ont 14 jours à compter de la réception du produit pour demander un retour.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('2. Conditions d’acceptation'),
          const SizedBox(height: 10),
          _buildBullet(
            'Le produit doit être retourné dans son état d’origine.',
          ),
          _buildBullet(
            'L’emballage et les accessoires doivent être complets.',
          ),
          _buildBullet(
            'Les produits personnalisés ou sanitaires peuvent être exclus.',
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('3. Procédure de retour'),
          const SizedBox(height: 10),
          _buildBullet(
            'Contactez le vendeur via le chat ou le bouton de retour dans la commande.',
          ),
          _buildBullet(
            'Expliquez le motif du retour et joignez des photos si nécessaire.',
          ),
          _buildBullet(
            'Le vendeur vérifiera la demande et confirmera les prochaines étapes.',
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('4. Remboursement'),
          const SizedBox(height: 10),
          const Text(
            'Une fois le retour accepté et le produit reçu, le remboursement est traité dans un délai de 5 à 7 jours ouvrés.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('5. Support client'),
          const SizedBox(height: 10),
          const Text(
            'Pour toute question, contactez le service client depuis l’espace vendeur ou l’aide intégrée.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
