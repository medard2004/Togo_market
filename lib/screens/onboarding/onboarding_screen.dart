import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../Api/provider/auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentSlide = 0;

  final _slides = [
    _SlideData(
      image:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&h=450&fit=crop',
      title1: 'Achetez & Vendez',
      title2: 'facilement au Togo',
      subtitle: 'Des milliers de produits disponibles près de chez vous à Lomé.',
      badge1: _Badge('LIVRAISON RAPIDE', Alignment.topRight, Icons.local_shipping),
      badge2: _Badge('VENDEURS VÉRIFIÉS', Alignment.bottomLeft, Icons.verified),
    ),
    _SlideData(
      image:
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600&h=450&fit=crop',
      title1: 'Discutez avec les',
      title2: 'vendeurs en direct',
      subtitle:
          'Négociez le prix, posez vos questions, tout en temps réel.',
      badge1: _Badge('NOUVEAU MESSAGE', Alignment.topRight, Icons.chat),
      badge2: _Badge('DIRECT CHAT', Alignment.bottomLeft, Icons.flash_on),
      isChat: true,
    ),
    _SlideData(
      image:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=600&h=450&fit=crop',
      title1: 'Devenez vendeur',
      title2: 'et gagnez plus',
      subtitle:
          'Publiez vos annonces gratuitement et touchez des milliers d\'acheteurs.',
      badge1: _Badge('50K+ VENDEURS', Alignment.topRight, Icons.shopping_bag),
      badge2: _Badge('FAIT AU TOGO', Alignment.bottomLeft, Icons.flag),
      titleIcon: Icons.attach_money,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentSlide < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      Get.find<AuthController>().markOnboardingComplete();
      Get.offNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity: _currentSlide > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: () {
                        Get.find<AuthController>().markOnboardingComplete();
                        Get.offNamed('/auth');
                      },
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: AppTheme.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.find<AuthController>().markOnboardingComplete();
                      Get.offNamed('/auth');
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentSlide = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.primary,
                      dotColor: AppTheme.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Slide text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(_currentSlide),
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_slides[_currentSlide].title1}\n',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground,
                                ),
                              ),
                              if (_slides[_currentSlide].titleIcon != null)
                                WidgetSpan(
                                  child: Icon(
                                    _slides[_currentSlide].titleIcon,
                                    size: 24,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              TextSpan(
                                text: _slides[_currentSlide].title2,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _slides[_currentSlide].subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CTA
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.shadowPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSlide < 2 ? 'Continuer' : 'Commencer',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(
                            width: 5,
                          ),


                          if (_currentSlide < 2) ...[
                            const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                          ],
                          if (_currentSlide == 2) ...[
                            const Icon(Icons.rocket_launch, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                          ],
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _SlideData slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: slide.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => Container(color: AppTheme.muted),
              ),
            ),
            // Overlay for chat slide
            if (slide.isChat)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _chatBubble('Bonjour ! Le prix est négociable ?', true),
                      const SizedBox(height: 6),
                      _chatBubble('Oui ! 10% de réduction pour vous 😊', false),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send,
                                size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            // Floating badges
            _FloatingBadge(badge: slide.badge1),
            _FloatingBadge(badge: slide.badge2),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : AppTheme.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isMe ? Colors.white : AppTheme.foreground,
          ),
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final _Badge badge;

  const _FloatingBadge({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: badge.alignment == Alignment.topRight ? 12 : null,
      bottom: badge.alignment == Alignment.bottomLeft ? 12 : null,
      left: badge.alignment == Alignment.bottomLeft ? 12 : null,
      right: badge.alignment == Alignment.topRight ? 12 : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.shadowCard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge.icon != null) ...[
              Icon(badge.icon, size: 12, color: AppTheme.foreground),
              const SizedBox(width: 4),
            ],
            Text(
              badge.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final String image;
  final String title1;
  final String title2;
  final String subtitle;
  final _Badge badge1;
  final _Badge badge2;
  final bool isChat;
  final IconData? titleIcon;

  const _SlideData({
    required this.image,
    required this.title1,
    required this.title2,
    required this.subtitle,
    required this.badge1,
    required this.badge2,
    this.isChat = false,
    this.titleIcon,
  });
}

class _Badge {
  final String label;
  final Alignment alignment;
  final IconData? icon;

  const _Badge(this.label, this.alignment, [this.icon]);
}
