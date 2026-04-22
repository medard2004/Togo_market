import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReturnPolicyScreen extends StatefulWidget {
  const ReturnPolicyScreen({super.key});

  @override
  State<ReturnPolicyScreen> createState() => _ReturnPolicyScreenState();
}

class _ReturnPolicyScreenState extends State<ReturnPolicyScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> controllers;
  late List<Animation<double>> animations;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    animations = controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
            ))
        .toList();

    Future.delayed(const Duration(milliseconds: 200), () {
      for (var controller in controllers) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Politique de retour',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: AppTheme.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ScaleTransition(
                scale: animations[0],
                alignment: Alignment.topCenter,
                child: _buildHeaderBanner(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cards = [
                    _CardData(
                      icon: Icons.schedule,
                      title: 'Délai de retour',
                      number: '1',
                      content:
                          'Les clients ont 14 jours à compter de la réception du produit pour demander un retour.',
                    ),
                    _CardData(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Conditions d\'acceptation',
                      number: '2',
                      bullets: [
                        'Le produit doit être retourné dans son état d\'origine',
                        'L\'emballage et les accessoires doivent être complets',
                        'Les produits personnalisés ou sanitaires peuvent être exclus',
                      ],
                    ),
                    _CardData(
                      icon: Icons.directions_run,
                      title: 'Procédure de retour',
                      number: '3',
                      bullets: [
                        'Contactez le vendeur via le chat ou le bouton de retour',
                        'Expliquez le motif et joignez des photos si nécessaire',
                        'Le vendeur vérifiera et confirmera les prochaines étapes',
                      ],
                    ),
                    _CardData(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Remboursement',
                      number: '4',
                      content:
                          'Une fois le retour accepté et le produit reçu, le remboursement est traité dans un délai de 5 à 7 jours ouvrés.',
                    ),
                    _CardData(
                      icon: Icons.support_agent,
                      title: 'Support client',
                      number: '5',
                      content:
                          'Pour toute question, contactez le service client depuis l\'espace vendeur ou l\'aide intégrée.',
                    ),
                  ];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FadeTransition(
                      opacity: animations[index + 1],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: controllers[index + 1],
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: _PolicyCardWidget(data: cards[index]),
                      ),
                    ),
                  );
                },
                childCount: 5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: _buildActionButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Politique de retour',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Permettez à vos clients de retourner leurs achats en toute confiance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isHovered
                      ? AppTheme.primary.withOpacity(0.9)
                      : AppTheme.primary,
                  isHovered
                      ? AppTheme.primary.withOpacity(0.75)
                      : AppTheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(isHovered ? 0.4 : 0.2),
                  blurRadius: isHovered ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: isHovered ? 18 : 16,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'J\'ai compris',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (isHovered) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String number;
  final String? content;
  final List<String>? bullets;

  _CardData({
    required this.icon,
    required this.title,
    required this.number,
    this.content,
    this.bullets,
  });
}

class _PolicyCardWidget extends StatefulWidget {
  final _CardData data;

  const _PolicyCardWidget({required this.data});

  @override
  State<_PolicyCardWidget> createState() => _PolicyCardWidgetState();
}

class _PolicyCardWidgetState extends State<_PolicyCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? AppTheme.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isHovered ? 20 : 10,
              offset: isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isHovered
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.08),
                    AppTheme.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primary.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? AppTheme.primary
                          : AppTheme.primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? AppTheme.primary
                          : AppTheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.data.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: widget.data.content != null
                  ? Text(
                      widget.data.content!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    )
                  : Column(
                      children: widget.data.bullets!
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key !=
                                        widget.data.bullets!.length - 1
                                    ? 14
                                    : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      right: 14,
                                    ),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primary,
                                            AppTheme.primary.withOpacity(0.7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
