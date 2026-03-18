import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';

// ── Messages Screen ───────────────────────────────────────────────────────────
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final convs = mockConversations;
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Messages (${convs.length})',
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: convs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final conv = convs[i];
          final seller = getSellerById(conv.sellerId);
          final product = getProductById(conv.productId);
          return GestureDetector(
            onTap: () => Get.toNamed('/chat/${conv.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: seller != null
                            ? CachedNetworkImageProvider(seller.avatar)
                            : null,
                      ),
                      if (conv.unread > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conv.unread}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seller?.shopName ?? 'Boutique',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        conv.time,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.mutedForeground),
                      ),
                      const SizedBox(height: 4),
                      if (product != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

// ── Order Screen ──────────────────────────────────────────────────────────────
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _deliveryMode = 'retrait';
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final product = getProductById(args?['productId'] ?? 'p1');

    if (_confirmed) {
      return Scaffold(
          resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: const Text('✅',
                      style: TextStyle(fontSize: 72)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Commande confirmée !',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Le vendeur sera notifié immédiatement.',
                style: TextStyle(
                    fontSize: 14, color: AppTheme.mutedForeground),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Commander'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary
            if (product != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
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
                          Text(product.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            formatPrice(product.price),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.muted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(product.condition,
                                style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text('Mode de récupération',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...[
              ('livraison', '🛵 Livraison à domicile'),
              ('retrait', '🤝 Retrait en main propre'),
            ].map((opt) => GestureDetector(
                  onTap: () => setState(() => _deliveryMode = opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _deliveryMode == opt.$1
                          ? AppTheme.primaryLight
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _deliveryMode == opt.$1
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: _deliveryMode == opt.$1 ? 2 : 1,
                      ),
                    ),
                    child: Text(opt.$2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _deliveryMode == opt.$1
                              ? AppTheme.primary
                              : AppTheme.foreground,
                        )),
                  ),
                )),
            const SizedBox(height: 10),
            const Text('Téléphone',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: '+228 90 00 00 00',
              ),
            ),
            if (_deliveryMode == 'livraison') ...[
              const SizedBox(height: 16),
              const Text('Adresse de livraison',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Quartier, rue, repère...',
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: AppTheme.shadowCardLg,
        ),
        child: AppButton(
          label: '✅ Confirmer la commande',
          onTap: () {
            setState(() => _confirmed = true);
            Future.delayed(const Duration(seconds: 3), () {
              Get.offAllNamed('/home');
            });
          },
        ),
      ),
    );
  }
}

// ── Seller Profile Screen ─────────────────────────────────────────────────────
class SellerScreen extends StatelessWidget {
  const SellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? 's1';
    final seller = getSellerById(id);
    if (seller == null) {
      return Scaffold(body: Center(child: Text('Vendeur introuvable')));
    }
    final products =
        mockProducts.where((p) => p.sellerId == id).toList();

    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: AppBackButton(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: AppTheme.shadowCardLg,
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundImage:
                              CachedNetworkImageProvider(seller.avatar),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      seller.shopName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      seller.name,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.mutedForeground),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < seller.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppTheme.mutedForeground),
                        Text(seller.location,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.mutedForeground)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: '💬 Discuter',
                      onTap: () => Get.toNamed('/chat/c1'),
                    ),
                    const SizedBox(height: 16),
                    // Stats
                    Row(
                      children: [
                        _Stat('${products.length}', 'Annonces'),
                        _Stat('${(seller.rating * 10).round()}', 'Ventes'),
                        _Stat(
                            '${seller.rating}★', 'Note'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Produits',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          ProductCard(product: products[i]),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
