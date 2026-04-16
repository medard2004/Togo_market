import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';

class SellerHelpCenterScreen extends StatefulWidget {
  const SellerHelpCenterScreen({super.key});

  @override
  State<SellerHelpCenterScreen> createState() => _SellerHelpCenterScreenState();
}

class _SellerHelpCenterScreenState extends State<SellerHelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _expandedFaq;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.storefront_rounded,
      'title': 'Ma Boutique',
      'color': const Color(0xFF4F46E5),
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Livraisons',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Icons.payments_outlined,
      'title': 'Paiements',
      'color': const Color(0xFFF59E0B),
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Performance',
      'color': const Color(0xFFEC4899),
    },
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Comment sont calculées les commissions ?',
      'a': 'Togo Market prélève une commission de 5% uniquement sur les ventes réussies. L\'inscription et la mise en ligne d\'articles restent gratuites.'
    },
    {
      'q': 'Comment demander un retrait de mes gains ?',
      'a': 'Allez dans votre portefeuille vendeur et cliquez sur "Retirer". Les fonds sont transférés via Flooz ou TMoney sous 24h.'
    },
    {
      'q': 'Quels sont les délais de livraison conseillés ?',
      'a': 'Nous recommandons d\'expédier les commandes sous 48h pour maintenir une bonne note de performance.'
    },
    {
      'q': 'Comment booster la visibilité de mes produits ?',
      'a': 'Utilisez des photos de haute qualité et remplissez précisément les descriptions. Les vendeurs ayant de bonnes notes sont mis en avant.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar Premium ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFFF8C42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Centre d\'aide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comment pouvons-nous vous aider ?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Search & Content ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Overlay
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.shadowCardLg,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une solution...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                  child: Text(
                    'Catégories d\'aide',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),

                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      return TogoSlideUp(
                        delay: Duration(milliseconds: i * 100),
                        child: _HelpCategoryCard(
                          icon: cat['icon'],
                          title: cat['title'],
                          color: cat['color'],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // FAQ Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                  child: Text(
                    'Questions fréquentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final faq = _faqs[i];
                      final isExpanded = _expandedFaq == i;
                      return TogoSlideUp(
                        delay: Duration(milliseconds: 400 + (i * 100)),
                        child: GestureDetector(
                          onTap: () => setState(() => _expandedFaq = isExpanded ? null : i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isExpanded ? AppTheme.primary : AppTheme.border,
                                width: isExpanded ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          faq['q']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isExpanded ? AppTheme.primary : AppTheme.foreground,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: isExpanded ? AppTheme.primary : AppTheme.mutedForeground,
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                          child: Text(
                                            faq['a']!,
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
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Support Contact Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TogoSlideUp(
                    delay: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.headset_mic_rounded, size: 40, color: AppTheme.primary),
                          const SizedBox(height: 12),
                          const Text(
                            'Besoin d\'une assistance directe ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Notre équipe support est disponible\n7j/7 de 8h à 20h.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Lancer le chat support',
                            icon: Icons.chat_outlined,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          TogoPressableScale(
                            onTap: () {},
                            child: const Text(
                              'Nous appeler directement',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _HelpCategoryCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
