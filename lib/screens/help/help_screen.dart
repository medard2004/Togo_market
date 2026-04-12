import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../animations/togo_animation_system.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expanded;

  final _faqs = [
    (
      'Comment publier une annonce ?',
      'Appuyez sur le bouton "Vendre" en bas de l\'écran, remplissez le formulaire avec les infos du produit et publiez votre annonce gratuitement.'
    ),
    (
      'Comment contacter un vendeur ?',
      'Cliquez sur "Discuter avec le vendeur" depuis la page produit pour démarrer une conversation directe.'
    ),
    (
      'Comment payer en toute sécurité ?',
      'Nous recommandons de payer en personne lors du retrait. N\'envoyez jamais d\'argent avant d\'avoir reçu le produit.'
    ),
    (
      'Comment signaler un problème ?',
      'Utilisez le bouton "Signaler" sur la page du produit ou contactez notre support via le chat d\'aide.'
    ),
    (
      'Comment modifier mon profil ?',
      'Allez dans Profil → Modifier le profil. Vous pouvez changer votre nom, photo et zone de livraison.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Aide & Support'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final faq = _faqs[i];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _expanded = _expanded == i ? null : i),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(faq.$1,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Icon(
                              _expanded == i
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.mutedForeground,
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: TogoMotion.accordion,
                          curve: TogoMotion.accordionCurve,
                          alignment: Alignment.topLeft,
                          clipBehavior: Clip.hardEdge,
                          child: _expanded == i
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    faq.$2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppTheme.mutedForeground,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: AppButton(
              label: 'Contacter le support',
              icon: Icons.chat_bubble_rounded,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
