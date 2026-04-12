import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0; // 0: Articles, 1: Commandes, 2: Messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildCircleBtn(
                    Icons.arrow_back,
                    Colors.black,
                    Colors.white,
                    onTap: () => Get.back(),
                  ),
                  const Text(
                    'Mon Espace Vendeur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  _buildCircleBtn(
                    Icons.settings_outlined,
                    AppTheme.primary,
                    AppTheme.primaryLight,
                    onTap: () => Get.toNamed('/shop-settings'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Shop Card ──────────────────────────────────────────────
                    _buildShopCard(),
                    const SizedBox(height: 24),

                    // ── Tab Navigation ────────────────────────────────────────
                    _buildTabSelector(),
                    const SizedBox(height: 24),

                    // ── Tab Content ───────────────────────────────────────────
                    Column(
                      key: ValueKey(_tabIndex),
                      children: [
                        if (_tabIndex == 0) ...[
                          _buildAddButton(),
                          const SizedBox(height: 24),
                          _buildArticlesTab(),
                        ] else if (_tabIndex == 1)
                          _buildOrdersTab()
                        else
                          _buildMessagesTab(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color iconColor, Color bg, {VoidCallback? onTap}) {
    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: bg == Colors.white ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildShopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_outlined,
                color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kofi Tech Shop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: AppTheme.mutedForeground),
                    Text(' Tokoin, Lomé',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Text('3 articles',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                    Text(' • ',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(' 4.8',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          TogoPressableScale(
            onTap: () => Get.toNamed('/store-config'),
            child: const Text(
              'Modifier',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.grid_view_outlined, 'Articles'),
          _buildTabItem(1, Icons.inventory_2_outlined, 'Commandes'),
          _buildTabItem(2, Icons.chat_bubble_outline_outlined, 'Messages'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: isActive ? Colors.white : AppTheme.mutedForeground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const AddProductScreen()),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Ajouter un article',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TogoSlideUp(
          child: const Text(
            '3 articles actifs',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildProductTile(
            'iPhone 13 Pro Max 256Go',
            '350 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&h=400&fit=crop',
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 200),
          child: _buildProductTile(
            'Canapé 3 places cuir',
            '85 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop',
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 300),
          child: _buildProductTile(
            'Laptop HP EliteBook',
            '220 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop',
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        TogoSlideUp(
          child: _buildOrderTile(
            'iPhone 13 Pro Max 256Go',
            'Kafui A.',
            '350 000 F',
            'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=200&h=200&fit=crop',
            'En attente',
            isPending: true,
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildOrderTile(
            'Canapé 3 places cuir',
            'Mawuli K.',
            '85 000 F',
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&h=200&fit=crop',
            'Acceptée',
            isPending: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        TogoSlideUp(
          child: _buildMessageTile(
            'Kofi Mensah',
            'Oui, il est toujours disponible !',
            '10:32',
            'iPhone 13 Pro Max 256Go',
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
            unreadCount: 2,
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildMessageTile(
            'Ama Koffi',
            'Je peux faire 13 000 FCFA',
            'Hier',
            'Robe Ankara colorée',
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(
      String title, String buyer, String price, String img, String status,
      {bool isPending = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                    imageUrl: img,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending
                                ? AppTheme.primaryLight
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPending ? AppTheme.primary : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text('Acheteur: $buyer',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.mutedForeground)),
                    const SizedBox(height: 2),
                    Text(price,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TogoPressableScale(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Accepter',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TogoPressableScale(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined,
                              color: AppTheme.destructive, size: 20),
                          SizedBox(width: 8),
                          Text('Refuser',
                              style: TextStyle(
                                  color: AppTheme.destructive,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageTile(String name, String message, String time,
      String product, String avatar,
      {int unreadCount = 0}) {
    return TogoPressableScale(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.mutedForeground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppTheme.primary, shape: BoxShape.circle),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(product,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(
      String title, String price, String cond, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: img,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cond,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TogoPressableScale(
                onTap: () {},
                child: _buildActionBtn(Icons.edit_outlined),
              ),
              const SizedBox(width: 8),
              TogoPressableScale(
                onTap: () {},
                child: _buildActionBtn(Icons.delete_outline, isDelete: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, {bool isDelete = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          size: 18, color: isDelete ? AppTheme.destructive : AppTheme.primary),
    );
  }
}
