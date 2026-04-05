import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,      label: 'Accueil',  route: '/home'),
    _NavItem(icon: Icons.search,             label: 'Chercher', route: '/search'),
    _NavItem(icon: Icons.add,                label: 'Vendre',   route: '/store-settings'),
    _NavItem(icon: Icons.chat_bubble_outline,label: 'Chat',     route: '/messages'),
    _NavItem(icon: Icons.person_outline,     label: 'Profil',   route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: r.bottomNavH,
          child: Row(
            children: List.generate(_items.length, (i) {
              // ── Bouton central Vendre ──────────────────────────────────────
              if (i == 2) {
                final btnSize = (r.bottomNavH * 0.82).clamp(44.0, 58.0);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(_items[i].route),
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, -r.s(10)),
                        child: Container(
                          width: btnSize,
                          height: btnSize,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: r.s(24)),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // ── Onglets normaux ────────────────────────────────────────────
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () { if (!isActive) Get.offNamed(_items[i].route); },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(r.s(5)),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(r.rad(10)),
                        ),
                        child: Icon(
                          _items[i].icon,
                          size: r.s(20),
                          color: isActive ? AppTheme.primary : AppTheme.mutedForeground,
                        ),
                      ),
                      SizedBox(height: r.s(2)),
                      Text(
                        _items[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.fs(10),
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppTheme.primary : AppTheme.mutedForeground,
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
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
