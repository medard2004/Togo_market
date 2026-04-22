import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _chatCtrl = Get.find<ChatController>();

  final _quickReplies = [
    '👀 Toujours disponible ?',
    '💰 Meilleur prix ?',
    '📦 Livraison possible ?',
    '📸 Plus de photos ?',
    '🤝 Négociable ?',
  ];

  late Product? _activeProduct;
  bool _showProductPreview = false;

  @override
  void initState() {
    super.initState();
    final convId = Get.parameters['id'] ?? 'c1';
    _chatCtrl.loadConversation(convId);

    _activeProduct =
        (Get.arguments is Product) ? Get.arguments as Product : null;
    _showProductPreview = _activeProduct != null;

    // Auto-fill context message
    if (_showProductPreview) {
      _msgCtrl.text = 'Bonjour, je suis intéressé par votre annonce.';
    }
  }

  void _send([String? text]) {
    final content = text ?? _msgCtrl.text.trim();
    if (content.isEmpty) return; // Prevent sending empty messages

    _msgCtrl.clear();
    final convId = Get.parameters['id'] ?? 'c1';

    // Send message with product context if it's the first one or specifically attached
    _chatCtrl.sendMessage(convId, content, 's1',
        productId: _showProductPreview ? _activeProduct?.id : null);

    // Clear product preview after sending
    if (_showProductPreview) {
      setState(() => _showProductPreview = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final seller = getSellerById('s1');
    final product = (Get.arguments is Product)
        ? Get.arguments as Product
        : getProductById('p1');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 18),
          onPressed: Get.back,
        ),
        title: Row(
          children: [
            if (seller != null)
              CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(seller.avatar),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller?.shopName ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  if (seller != null)
                    Text(
                      'Répond en ${seller.responseTime}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.mutedForeground),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (product != null)
            GestureDetector(
              onTap: () => Get.toNamed('/product/${product.id}'),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _chatCtrl.currentMessages.length +
                    (_chatCtrl.isTyping.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _chatCtrl.currentMessages.length) {
                    return _TypingIndicator(seller: seller);
                  }
                  final msg = _chatCtrl.currentMessages[i];
                  return _MessageBubble(
                      message: msg, sellerAvatar: seller?.avatar ?? '');
                },
              );
            }),
          ),
          // Quick replies
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    _quickReplies[i],
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Input
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 4, 16, MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: AppTheme.border.withOpacity(0.3))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activeProduct != null && _showProductPreview)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _ProductInputPreview(
                      product: _activeProduct!,
                      onClose: () =>
                          setState(() => _showProductPreview = false),
                    ),
                  ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {}, // Add attachment logic here later
                      child: Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.add,
                            color: AppTheme.primary, size: r.s(24)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _msgCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Écrivez un message...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            fillColor: Colors.transparent,
                            filled: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: r.s(48),
                        height: r.s(48),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowPrimary,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final String sellerAvatar;

  const _MessageBubble({required this.message, required this.sellerAvatar});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final isMe = message.isMe as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: sellerAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(sellerAvatar)
                  : null,
              child: sellerAvatar.isEmpty
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primary : AppTheme.cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight:
                    isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
              boxShadow: isMe ? null : AppTheme.shadowCard,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.productId != null)
                  _MessageProductPreview(
                      productId: message.productId!, isMe: isMe),
                if ((message.content as String).isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: message.productId != null ? r.s(8) : 0),
                    child: Text(
                      message.content as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppTheme.foreground,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  message.timestamp as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final dynamic seller;

  const _TypingIndicator({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (seller != null)
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  CachedNetworkImageProvider(seller.avatar as String),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 200),
                const SizedBox(width: 4),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0, end: -6).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.mutedForeground,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ProductInputPreview extends StatelessWidget {
  final Product product;
  final VoidCallback onClose;

  const _ProductInputPreview({required this.product, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      padding: EdgeInsets.all(r.s(6)),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(r.rad(14)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(r.rad(10)),
            child: CachedNetworkImage(
              imageUrl: product.image,
              width: r.s(32),
              height: r.s(32),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: r.s(10)),
          Expanded(
            child: Text(
              'Réponse à : ${product.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.fs(12),
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close_rounded,
                size: r.s(16), color: AppTheme.primary),
          ),
          SizedBox(width: r.s(4)),
        ],
      ),
    );
  }
}

class _MessageProductPreview extends StatelessWidget {
  final String productId;
  final bool isMe;

  const _MessageProductPreview({required this.productId, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final product = getProductById(productId);
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Get.toNamed('/product/$productId'),
      child: Container(
        margin: EdgeInsets.only(bottom: r.s(6)),
        padding: EdgeInsets.all(r.s(2)),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(18)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(r.rad(16)),
              child: CachedNetworkImage(
                imageUrl: product.image,
                height: r.s(110),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.s(10)),
              child: Column(
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.fs(13),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                  ),
                  SizedBox(height: r.s(4)),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.s(10), vertical: r.s(3)),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(r.rad(20)),
                    ),
                    child: Text(
                      '${formatPrice(product.price).replaceAll(' F', '')} FCFA',
                      style: TextStyle(
                        fontSize: r.fs(11),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
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
