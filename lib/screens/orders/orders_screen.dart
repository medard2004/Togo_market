import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _activeTab = 0; // 0 = Achats, 1 = Ventes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          'Mes commandes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // ── Tabs (Achats / Ventes) ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 54,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2EF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTabPill('Achats', 0),
                  _buildTabPill('Ventes', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1)),
          // ── Orders List ───────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _buildPurchasesList(),
                _buildSalesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.black : const Color(0xFF8E8E93),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasesList() {
    final purchases = [
      {
        'title': 'iPhone 13 Pro Max 256Go',
        'price': '350 000 F',
        'vendor': 'Koffi Mensah',
        'image': 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=200',
        'status': 'Confirmé',
        'statusColor': const Color(0xFFE8F5E9),
        'textColor': const Color(0xFF2E7D32),
      },
      {
        'title': 'Sneakers Nike Air Force',
        'price': '28 000 F',
        'vendor': 'Ama Koffi',
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
        'status': 'En attente',
        'statusColor': const Color(0xFFFFF7E6),
        'textColor': const Color(0xFFB45309),
      },
      {
        'title': 'Kit beauté complet',
        'price': '22 000 F',
        'vendor': 'Yao Attiogbé',
        'image': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=200',
        'status': 'Terminé',
        'statusColor': const Color(0xFFF2F2F7),
        'textColor': const Color(0xFF8E8E93),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: purchases.length,
      itemBuilder: (context, i) {
        final order = purchases[i];
        return _OrderCard(
          title: order['title'] as String,
          price: order['price'] as String,
          partnerLabel: 'Vendeur:',
          partnerName: order['vendor'] as String,
          image: order['image'] as String,
          status: order['status'] as String,
          statusColor: order['statusColor'] as Color,
          textColor: order['textColor'] as Color,
          isSale: false,
        );
      },
    );
  }

  Widget _buildSalesList() {
    final sales = [
      {
        'title': 'Canapé 3 places cuir',
        'price': '85 000 F',
        'buyer': 'Mawuli K.',
        'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200',
        'status': 'En attente',
        'statusColor': const Color(0xFFFFF7E6),
        'textColor': const Color(0xFFB45309),
      },
      {
        'title': 'Laptop HP EliteBook',
        'price': '220 000 F',
        'buyer': 'Kafui A.',
        'image': 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200',
        'status': 'Confirmé',
        'statusColor': const Color(0xFFE8F5E9),
        'textColor': const Color(0xFF2E7D32),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: sales.length,
      itemBuilder: (context, i) {
        final order = sales[i];
        return _OrderCard(
          title: order['title'] as String,
          price: order['price'] as String,
          partnerLabel: 'Acheteur:',
          partnerName: order['buyer'] as String,
          image: order['image'] as String,
          status: order['status'] as String,
          statusColor: order['statusColor'] as Color,
          textColor: order['textColor'] as Color,
          isSale: true,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String title;
  final String price;
  final String partnerLabel;
  final String partnerName;
  final String image;
  final String status;
  final Color statusColor;
  final Color textColor;
  final bool isSale;

  const _OrderCard({
    required this.title,
    required this.price,
    required this.partnerLabel,
    required this.partnerName,
    required this.image,
    required this.status,
    required this.statusColor,
    required this.textColor,
    required this.isSale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF262626),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                        children: [
                          TextSpan(text: '$partnerLabel '),
                          TextSpan(
                            text: partnerName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          if (isSale && status == 'En attente')
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline,
                    onTap: () {},
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Accepter',
                    onTap: () {},
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Refuser',
                    onTap: () {},
                    color: const Color(0xFFF2F2F7),
                    textColor: Colors.black,
                  ),
                ),
              ],
            )
          else
            _ActionButton(
              label: 'Chat',
              icon: Icons.chat_bubble_outline,
              onTap: () {},
              isOutline: true,
              width: double.infinity,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isOutline;
  final Color? color;
  final Color? textColor;
  final double? width;

  const _ActionButton({
    required this.label,
    this.icon,
    required this.onTap,
    this.isOutline = false,
    this.color,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 44,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : (color ?? AppTheme.primary),
          borderRadius: BorderRadius.circular(14),
          border: isOutline ? Border.all(color: AppTheme.primary) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isOutline ? AppTheme.primary : Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isOutline ? AppTheme.primary : (textColor ?? Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
