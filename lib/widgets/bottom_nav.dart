import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../screens/seller/sell_choice_sheet.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(
      icon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'ACCUEIL',
      route: '/home',
    ),
    _NavItem(
      icon: Icons.search_rounded,
      inactiveIcon: Icons.search_rounded,
      label: 'RECHERCHE',
      route: '/search',
    ),
    _NavItem(
      icon: Icons.add,
      inactiveIcon: Icons.add,
      label: 'VENDRE',
      route: '/sell-choice',
    ),
    _NavItem(
      icon: Icons.forum_rounded,
      inactiveIcon: Icons.forum_outlined,
      label: 'MESSAGES',
      route: '/messages',
    ),
    _NavItem(
      icon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'PROFIL',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(30))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: r.s(72).clamp(68.0, 84.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_items.length, (i) {
              final isActive = currentIndex == i;
              final item = _items[i];

              // ── Bouton central Vendre ──────────────────────────────────────
              if (i == 2) {
                final btnSize = r.s(54).clamp(50.0, 62.0);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => SellChoiceSheet.show(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: -r.s(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Base du bouton (Cercle blanc pour la bordure + Ombre)
                              Container(
                                width: btnSize + r.s(8),
                                height: btnSize + r.s(8),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.25),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  // Coeur du bouton (Orange)
                                  child: Container(
                                    width: btnSize,
                                    height: btnSize,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: r.s(34),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: r.s(5)),
                              Text(
                                'VENDRE',
                                style: TextStyle(
                                  fontSize: r.fs(9),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black54,
                                  letterSpacing: 0.8,
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

              // ── Onglets normaux ────────────────────────────────────────────
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isActive) Get.offNamed(item.route);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(r.s(10)),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primary.withOpacity(0.12)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isActive ? item.icon : item.inactiveIcon,
                            size: r.s(24),
                            color:
                                isActive ? AppTheme.primary : Colors.black54),
                      ),
                      SizedBox(height: r.s(4)),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: r.fs(9),
                          fontWeight:
                              isActive ? FontWeight.w900 : FontWeight.w700,
                          color: isActive ? AppTheme.primary : Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.route,
  });
}
