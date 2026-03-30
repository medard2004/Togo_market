import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';

// ╔══════════════════════════════════════════════════════╗
// ║  SELLER PROFILE  (Boutique d'Elegance mockup)        ║
// ╚══════════════════════════════════════════════════════╝
class SellerScreen extends StatelessWidget {
  const SellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? 's1';
    final seller = getSellerById(id);
    if (seller == null) {
      return Scaffold(body: Center(child: Text('Vendeur introuvable')));
    }
    final products = mockProducts.where((p) => p.sellerId == id).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar + bannière dégradée ───────────────────────────────────
          SliverAppBar(
            expandedHeight: r.s(120),
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(r.s(8)),
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, size: r.s(20), color: Colors.white),
                ),
              ),
            ),
            title: Text(seller.shopName,
                style: TextStyle(fontSize: r.fs(16), fontWeight: FontWeight.w700, color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(Icons.ios_share_outlined, size: r.s(22), color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFFF8C42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Carte info boutique (chevauche la bannière) ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(0), r.s(16), 0),
              child: Transform.translate(
                offset: Offset(0, -r.s(1)),
                child: Container(
                  padding: EdgeInsets.all(r.s(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(r.rad(20)),
                    boxShadow: AppTheme.shadowCardLg,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Logo boutique
                          Container(
                            width: r.s(64), height: r.s(64),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(r.rad(14)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(r.rad(14)),
                              child: CachedNetworkImage(
                                imageUrl: seller.avatar,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: AppTheme.muted, highlightColor: Colors.white,
                                  child: Container(color: AppTheme.muted),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.s(14)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(seller.shopName,
                                    style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
                                SizedBox(height: r.s(4)),
                                Row(children: [
                                  Icon(Icons.star, size: r.s(14), color: Colors.amber),
                                  SizedBox(width: r.s(4)),
                                  Text('${seller.rating} (124 avis)',
                                      style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
                                ]),
                                SizedBox(height: r.s(3)),
                                Row(children: [
                                  Icon(Icons.location_on_outlined, size: r.s(13), color: AppTheme.mutedForeground),
                                  SizedBox(width: r.s(2)),
                                  Flexible(child: Text(seller.location,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground))),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.s(14)),
                      // Bouton Discuter
                      GestureDetector(
                        onTap: () => Get.toNamed('/chat/c1'),
                        child: Container(
                          width: double.infinity,
                          height: r.s(48).clamp(44, 54),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(r.rad(12)),
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, color: Colors.white, size: r.s(18)),
                              SizedBox(width: r.s(8)),
                              Text('Discuter avec le vendeur',
                                  style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(14), r.s(16), 0),
              child: Row(
                children: [
                  _StatBox(label: 'Ventes', value: '1.2k', r: r),
                  SizedBox(width: r.s(10)),
                  _StatBox(label: 'Réponse', value: '< 1h', r: r),
                  SizedBox(width: r.s(10)),
                  _StatBox(label: 'Actif', value: 'Maintenant', r: r, valueSmall: true),
                ],
              ),
            ),
          ),

          // ── En-tête Articles + Filtrer ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(22), r.s(16), r.s(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Articles (${products.length})',
                      style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(7)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(20)),
                      ),
                      child: Row(children: [
                        Icon(Icons.tune, size: r.s(14), color: AppTheme.primary),
                        SizedBox(width: r.s(4)),
                        Text('Filtrer',
                            style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grille produits ──────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.s(16), 0, r.s(16), r.s(40)),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: r.s(16),
                crossAxisSpacing: r.s(12),
                childAspectRatio: _gridRatio(context),
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SellerProductCard(product: products[i], r: r),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _gridRatio(BuildContext context) {
    final r = R(context);
    final colW = (r.screenW - r.s(16) * 2 - r.s(12)) / 2;
    final imgH = colW; // carré
    final infoH = r.s(52);
    return colW / (imgH + infoH);
  }
}

// ── Stat box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value;
  final R r;
  final bool valueSmall;
  const _StatBox({required this.label, required this.value, required this.r, this.valueSmall = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: r.s(14)),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(r.rad(14)),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(fontSize: r.fs(11), color: AppTheme.mutedForeground, fontWeight: FontWeight.w500)),
              SizedBox(height: r.s(4)),
              Text(value,
                  style: TextStyle(
                    fontSize: valueSmall ? r.fs(14) : r.fs(20),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  )),
            ],
          ),
        ),
      );
}

// ── Seller product card (image carrée + titre + prix primaire) ────────────────
class _SellerProductCard extends StatelessWidget {
  final dynamic product;
  final R r;
  const _SellerProductCard({required this.product, required this.r});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carrée avec favori + badge NOUVEAU
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(r.rad(14)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.image as String,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppTheme.muted, highlightColor: Colors.white,
                      child: Container(color: AppTheme.muted),
                    ),
                  ),
                ),
              ),
              // Badge NOUVEAU si condition == 'Neuf'
              if (product.condition == 'Neuf')
                Positioned(
                  bottom: r.s(8), left: r.s(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: r.s(8), vertical: r.s(3)),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(r.rad(6)),
                    ),
                    child: Text('NOUVEAU',
                        style: TextStyle(fontSize: r.fs(9), fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              // Bouton cœur
              Positioned(
                top: r.s(8), right: r.s(8),
                child: Obx(() {
                  final fav = ctrl.isFavorite(product.id as String);
                  return GestureDetector(
                    onTap: () => ctrl.toggleFavorite(product.id as String),
                    child: Container(
                      width: r.s(32), height: r.s(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowCard,
                      ),
                      child: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        size: r.s(16),
                        color: fav ? AppTheme.primary : AppTheme.mutedForeground,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: r.s(8)),
          Text(product.title as String,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
          SizedBox(height: r.s(2)),
          Text(formatPrice(product.price as double),
              style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ],
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  MESSAGES LIST  (maquette Body.png)                  ║
// ╚══════════════════════════════════════════════════════╝
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // État des filtres
  bool _hasActiveFilters = false;
  String _selectedSort = 'date_desc'; // date_desc, date_asc, name_asc, name_desc
  bool _showOnlineOnly = false;
  bool _showUnreadOnly = false;

  // État de sélection multiple
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {}; // Utilise le nom comme clé unique
  final _mockConvs = [
    _ConvItem(name: 'Koffi Mensah',   time: '14:20', msg: 'C\'est toujours disponible à Lom...', unread: 1,
        img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&crop=face',
        productImg: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=80&h=80&fit=crop'),
    _ConvItem(name: 'Essi Gado',      time: 'Dim.',  msg: 'Je peux voir d\'autres photos ?',   unread: 1,
        img: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&h=80&fit=crop&crop=face',
        productImg: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=80&h=80&fit=crop'),
    _ConvItem(name: 'Amivi Lawson',   time: 'Hier',  msg: 'Merci, je passe la prendre à 17h.', unread: 0,
        img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&crop=face',
        productImg: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=80&h=80&fit=crop'),
    _ConvItem(name: 'Kodjo Aziamble', time: 'Lun.',  msg: 'Quel est votre dernier prix svp ?', unread: 0,
        img: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=face',
        productImg: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=80&h=80&fit=crop'),
    _ConvItem(name: 'Yao Kouame',     time: '12 Oct.',msg: 'D\'accord, c\'est noté.',           unread: 0,
        img: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&crop=face',
        productImg: null),
  ];

  List<_ConvItem> get _filtered {
    List<_ConvItem> filtered = List.from(_mockConvs);

    // Filtre par statut en ligne
    if (_showOnlineOnly) {
      // Pour la démo, on considère que certains utilisateurs sont en ligne
      final onlineNames = ['Koffi Mensah', 'Essi Gado', 'Amivi Lawson'];
      filtered = filtered.where((c) => onlineNames.contains(c.name)).toList();
    }

    // Filtre par non lus
    if (_showUnreadOnly) {
      filtered = filtered.where((c) => c.unread > 0).toList();
    }

    // Tri selon le critère sélectionné
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'date_desc':
          // Tri par date décroissante (plus récent d'abord)
          return b.time.compareTo(a.time);
        case 'date_asc':
          // Tri par date croissante (plus ancien d'abord)
          return a.time.compareTo(b.time);
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        default:
          return 0;
      }
    });

    return filtered;
  }

  // Méthodes pour la gestion de la sélection
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedMessages.clear();
      }
    });
  }

  void _toggleMessageSelection(String messageName) {
    setState(() {
      if (_selectedMessages.contains(messageName)) {
        _selectedMessages.remove(messageName);
      } else {
        _selectedMessages.add(messageName);
      }
    });
  }

  void _selectAllMessages() {
    setState(() {
      if (_selectedMessages.length == _filtered.length) {
        _selectedMessages.clear();
      } else {
        _selectedMessages.addAll(_filtered.map((msg) => msg.name));
      }
    });
  }

  void _deleteSelectedMessages() {
    setState(() {
      // Dans une vraie app, on supprimerait de la base de données
      // Ici on simule en filtrant la liste mock
      _mockConvs.removeWhere((msg) => _selectedMessages.contains(msg.name));
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, r.s(20), r.hPad, r.s(14)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isSelectionMode ? '${_selectedMessages.length} sélectionné(s)' : 'Messages',
                      style: TextStyle(fontSize: r.fs(26), fontWeight: FontWeight.w800, color: AppTheme.foreground)
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleSelectionMode,
                    child: Container(
                      padding: EdgeInsets.all(r.s(8)),
                      decoration: BoxDecoration(
                        color: _isSelectionMode ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(r.rad(8)),
                      ),
                      child: Icon(
                        _isSelectionMode ? Icons.close : Icons.checklist_rounded,
                        size: r.s(24),
                        color: _isSelectionMode ? AppTheme.primary : AppTheme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Barre de recherche ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.hPad),
              child: Container(
                height: r.s(50).clamp(46.0, 56.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.muted.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Container pour l'icône avec fond coloré
                    Container(
                      width: r.s(48),
                      height: r.s(48),
                      margin: EdgeInsets.all(r.s(1)),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.rad(14)),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        size: r.s(22),
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(width: r.s(4)),
                    // Champ de texte
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: r.fs(15),
                          color: AppTheme.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Rechercher une conversation...',
                          hintStyle: TextStyle(
                            fontSize: r.fs(14),
                            color: AppTheme.mutedForeground,
                            fontWeight: FontWeight.w400,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: r.s(12)),
                        ),
                      ),
                    ),
                    // Bouton filtre optionnel
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        width: r.s(40),
                        height: r.s(40),
                        margin: EdgeInsets.only(right: r.s(4)),
                        decoration: BoxDecoration(
                          color: _hasActiveFilters
                              ? AppTheme.primary.withOpacity(0.1)
                              : AppTheme.muted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(r.rad(12)),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          size: r.s(18),
                          color: _hasActiveFilters
                              ? AppTheme.primary
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: r.s(14)),

            // ── Liste conversations ──────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text('Aucun message', style: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14))))
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(24)),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: r.s(8)),
                      itemBuilder: (_, i) => _ConvTile(
                        item: _filtered[i],
                        r: r,
                        isSelectionMode: _isSelectionMode,
                        isSelected: _selectedMessages.contains(_filtered[i].name),
                        onSelectionChanged: () => _toggleMessageSelection(_filtered[i].name),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isSelectionMode
          ? _buildSelectionActionBar()
          : const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSelectionActionBar() {
    final r = R(context);
    final allSelected = _selectedMessages.length == _filtered.length;
    final hasSelection = _selectedMessages.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(r.hPad, r.s(12), r.hPad, r.s(12) + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Tout sélectionner
          Expanded(
            child: GestureDetector(
              onTap: _selectAllMessages,
              child: Container(
                height: r.s(44),
                decoration: BoxDecoration(
                  color: AppTheme.muted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.rad(12)),
                ),
                child: Center(
                  child: Text(
                    allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
                    style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: r.s(12)),
          // Bouton Supprimer
          Expanded(
            child: GestureDetector(
              onTap: hasSelection ? _deleteSelectedMessages : null,
              child: Container(
                height: r.s(44),
                decoration: BoxDecoration(
                  color: hasSelection ? AppTheme.destructive : AppTheme.muted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.rad(12)),
                ),
                child: Center(
                  child: Text(
                    'Supprimer',
                    style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color: hasSelection ? Colors.white : AppTheme.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modal de filtres
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedSort: _selectedSort,
        showOnlineOnly: _showOnlineOnly,
        showUnreadOnly: _showUnreadOnly,
        onSortChanged: (value) => setState(() => _selectedSort = value),
        onOnlineOnlyChanged: (value) => setState(() => _showOnlineOnly = value),
        onUnreadOnlyChanged: (value) => setState(() => _showUnreadOnly = value),
        onFiltersApplied: () => setState(() => _hasActiveFilters = _selectedSort != 'date_desc' || _showOnlineOnly || _showUnreadOnly),
      ),
    );
  }
}

// Modèle de données conversation mock
class _ConvItem {
  final String name, time, msg, img;
  final int unread;
  final String? productImg;
  const _ConvItem({required this.name, required this.time, required this.msg,
      required this.img, required this.unread, required this.productImg});
}

// Tuile d'une conversation
class _ConvTile extends StatelessWidget {
  final _ConvItem item;
  final R r;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const _ConvTile({
    required this.item,
    required this.r,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = item.unread > 0;
    return GestureDetector(
      onTap: isSelectionMode ? onSelectionChanged : () => Get.toNamed('/chat/c1'),
      child: Container(
        padding: EdgeInsets.all(r.s(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(16)),
          boxShadow: AppTheme.shadowCard,
          border: isSelectionMode && isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Checkbox en mode sélection
            if (isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelectionChanged?.call(),
                activeColor: AppTheme.primary,
              ),
              SizedBox(width: r.s(8)),
            ],

            // Avatar + badge non lu
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: r.s(26),
                  backgroundImage: CachedNetworkImageProvider(item.img),
                  backgroundColor: AppTheme.muted,
                ),
                if (hasUnread)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: r.s(12), height: r.s(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: r.s(12)),

            // Nom + dernier message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                      SizedBox(width: r.s(8)),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: r.fs(11),
                          color: hasUnread ? AppTheme.primary : AppTheme.mutedForeground,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.s(3)),
                  Text(
                    item.msg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs(13),
                      color: hasUnread ? AppTheme.foreground : AppTheme.mutedForeground,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Miniature produit
            if (item.productImg != null) ...[
              SizedBox(width: r.s(10)),
              ClipRRect(
                borderRadius: BorderRadius.circular(r.rad(10)),
                child: CachedNetworkImage(
                  imageUrl: item.productImg!,
                  width: r.s(46), height: r.s(46),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: r.s(46), height: r.s(46),
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(r.rad(10)),
                    ),
                    child: Icon(Icons.image_not_supported, size: r.s(18), color: AppTheme.mutedForeground),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(width: r.s(10)),
              Container(
                width: r.s(46), height: r.s(46),
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(r.rad(10)),
                ),
                child: Icon(Icons.image_not_supported_outlined, size: r.s(20), color: AppTheme.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  MODAL DE FILTRES (Design simple)                     ║
// ╚══════════════════════════════════════════════════════╝
class _FilterModal extends StatefulWidget {
  final String selectedSort;
  final bool showOnlineOnly;
  final bool showUnreadOnly;
  final Function(String) onSortChanged;
  final Function(bool) onOnlineOnlyChanged;
  final Function(bool) onUnreadOnlyChanged;
  final Function() onFiltersApplied;

  const _FilterModal({
    required this.selectedSort,
    required this.showOnlineOnly,
    required this.showUnreadOnly,
    required this.onSortChanged,
    required this.onOnlineOnlyChanged,
    required this.onUnreadOnlyChanged,
    required this.onFiltersApplied,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String _tempSelectedSort;
  late bool _tempShowOnlineOnly;
  late bool _tempShowUnreadOnly;

  @override
  void initState() {
    super.initState();
    _tempSelectedSort = widget.selectedSort;
    _tempShowOnlineOnly = widget.showOnlineOnly;
    _tempShowUnreadOnly = widget.showUnreadOnly;
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      margin: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.rad(20)),
        boxShadow: AppTheme.shadowCardLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header compact
          Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: Row(
              children: [
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: r.fs(18),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: r.s(24),
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tri rapide - boutons en ligne
                Text(
                  'Trier par',
                  style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(8)),
                Row(
                  children: [
                    _buildQuickSortButton('Récent', 'date_desc'),
                    SizedBox(width: r.s(8)),
                    _buildQuickSortButton('Ancien', 'date_asc'),
                    SizedBox(width: r.s(8)),
                    _buildQuickSortButton('A-Z', 'name_asc'),
                  ],
                ),

                SizedBox(height: r.s(16)),

                // Filtres - chips
                Text(
                  'Afficher',
                  style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(8)),
                Wrap(
                  spacing: r.s(8),
                  runSpacing: r.s(8),
                  children: [
                    _buildFilterChip('En ligne', _tempShowOnlineOnly, (value) {
                      setState(() => _tempShowOnlineOnly = value);
                    }),
                    _buildFilterChip('Non lus', _tempShowUnreadOnly, (value) {
                      setState(() => _tempShowUnreadOnly = value);
                    }),
                  ],
                ),

                SizedBox(height: r.s(20)),
              ],
            ),
          ),

          // Bouton Appliquer
          Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: GestureDetector(
              onTap: () {
                widget.onSortChanged(_tempSelectedSort);
                widget.onOnlineOnlyChanged(_tempShowOnlineOnly);
                widget.onUnreadOnlyChanged(_tempShowUnreadOnly);
                widget.onFiltersApplied();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: r.s(44),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(12)),
                ),
                child: Center(
                  child: Text(
                    'Appliquer les filtres',
                    style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSortButton(String label, String value) {
    final r = R(context);
    final isSelected = _tempSelectedSort == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tempSelectedSort = value),
        child: Container(
          height: r.s(36),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.rad(8)),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: r.fs(12),
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(bool) onChanged) {
    final r = R(context);
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(6)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.rad(16)),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.muted.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: r.fs(12),
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.foreground,
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════╗
// ║  ORDER SCREEN  — pixel-perfect maquette Frame_7      ║
// ╚══════════════════════════════════════════════════════╝
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // 'livraison' = côté gauche maquette | 'retrait' = côté droit
  String _mode = 'livraison';
  bool _confirmed = false;
  final _phoneCtrl = TextEditingController(text: '90 00 00 00');
  final _noteCtrl  = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final args = Get.arguments as Map<String, dynamic>?;
    final product = getProductById(args?['productId'] ?? 'p1');

    // ── Confirmation ─────────────────────────────────────────────────────────
    if (_confirmed) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (_, v, __) => Transform.scale(
                scale: v, child: Text('✅', style: TextStyle(fontSize: r.fs(72))),
              ),
            ),
            SizedBox(height: r.s(20)),
            Text('Commande confirmée !',
                style: TextStyle(fontSize: r.fs(22), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
            SizedBox(height: r.s(8)),
            Text('Le vendeur sera notifié immédiatement.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
          ]),
        ),
      );
    }

    // ── Montant formaté façon maquette : "745.000 FCFA" ──────────────────────
    String priceMain = '';
    if (product != null) {
      final v = product.price.toStringAsFixed(0);
      priceMain = v.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,

      // ── AppBar : bouton ← rond + titre centré ──────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: r.s(12)),
          child: GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.s(36), height: r.s(36),
              margin: EdgeInsets.symmetric(vertical: r.s(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowCard,
              ),
              child: Icon(Icons.arrow_back, size: r.s(18), color: AppTheme.foreground),
            ),
          ),
        ),
        title: Text('Commander',
            style: TextStyle(fontSize: r.fs(16), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
      ),

      // ── Body scrollable ───────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(8), r.hPad, r.s(160)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 1. Carte produit ─────────────────────────────────────────────
            if (product != null)
              Container(
                padding: EdgeInsets.all(r.s(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    // Image produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(10)),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: r.s(64), height: r.s(64),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: r.s(12)),
                    // Titre + prix (prix = chiffres en gras + FCFA petit)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600,
                                  color: AppTheme.foreground)),
                          SizedBox(height: r.s(5)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$priceMain ',
                                  style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w800,
                                      color: AppTheme.primary, fontFamily: 'PlusJakartaSans'),
                                ),
                                TextSpan(
                                  text: 'FCFA',
                                  style: TextStyle(fontSize: r.fs(11), fontWeight: FontWeight.w600,
                                      color: AppTheme.primary, fontFamily: 'PlusJakartaSans'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge quantité
                    Container(
                      width: r.s(32), height: r.s(32),
                      decoration: BoxDecoration(
                        color: AppTheme.muted,
                        borderRadius: BorderRadius.circular(r.rad(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text('x1',
                          style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600,
                              color: AppTheme.mutedForeground)),
                    ),
                  ],
                ),
              ),

            SizedBox(height: r.s(22)),

            // ── 2. Mode de réception ─────────────────────────────────────────
            // Icône camion pour livraison, icône caisse pour retrait
            Row(children: [
              Icon(
                _mode == 'livraison'
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                size: r.s(18), color: AppTheme.primary,
              ),
              SizedBox(width: r.s(7)),
              Text('Mode de réception',
                  style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(12)),

            // Option Livraison à domicile
            _OrderModeOption(
              value: 'livraison',
              groupValue: _mode,
              title: 'Livraison à domicile',
              subtitle: 'Recevez votre colis à Lomé & environs',
              onTap: () => setState(() => _mode = 'livraison'),
              r: r,
            ),
            SizedBox(height: r.s(10)),
            // Option Retrait en point de vente
            _OrderModeOption(
              value: 'retrait',
              groupValue: _mode,
              title: 'Retrait en point de vente',
              subtitle: 'Gratuit · Récupérez au Grand Marché',
              onTap: () => setState(() => _mode = 'retrait'),
              r: r,
            ),

            SizedBox(height: r.s(22)),

            // ── 3. Vos coordonnées ───────────────────────────────────────────
            Row(children: [
              Icon(Icons.person_outline, size: r.s(18), color: AppTheme.primary),
              SizedBox(width: r.s(7)),
              Text('Vos coordonnées',
                  style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ]),
            SizedBox(height: r.s(14)),

            // Label téléphone
            Text('NUMÉRO DE TÉLÉPHONE',
                style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground, letterSpacing: 0.7)),
            SizedBox(height: r.s(7)),

            // Champ téléphone : +228 | numéro | ✓
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Préfixe +228
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.s(14)),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: AppTheme.border)),
                      ),
                      alignment: Alignment.center,
                      child: Text('+228',
                          style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w500,
                              color: AppTheme.foreground)),
                    ),
                    // Champ numéro
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: r.fs(14), color: AppTheme.foreground),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: r.s(12), vertical: r.s(14)),
                          isDense: true,
                          hintText: '90 00 00 00',
                          hintStyle: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                        ),
                      ),
                    ),
                    // Icône check verte
                    Padding(
                      padding: EdgeInsets.only(right: r.s(12)),
                      child: Icon(Icons.check_circle_outline,
                          size: r.s(20), color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: r.s(14)),

            // Label champ note — change selon mode
            Text(
              _mode == 'livraison' ? 'QUARTIER & PRÉCISIONS' : 'NOTE OU PRÉCISIONS',
              style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600,
                  color: AppTheme.mutedForeground, letterSpacing: 0.7),
            ),
            SizedBox(height: r.s(7)),

            // Champ texte libre
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 4,
                style: TextStyle(fontSize: r.fs(13), color: AppTheme.foreground),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(r.s(14)),
                  isDense: true,
                  hintText: _mode == 'livraison'
                      ? 'Ex: Adidogomé, près de l\'église, portail bleu...'
                      : 'Indiquez l\'heure de votre passage ou toute autre précision utile...',
                  hintStyle: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground),
                ),
              ),
            ),

            SizedBox(height: r.s(14)),

            // ── 4. Bandeau paiement ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: r.s(12)),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(r.rad(12)),
                border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_outlined, size: r.s(16), color: AppTheme.primary),
                  SizedBox(width: r.s(7)),
                  Text(
                    _mode == 'livraison'
                        ? 'Paiement à la livraison uniquement'
                        : 'Paiement au moment du retrait',
                    style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600,
                        color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── 5. Footer fixe : ligne séparatrice + total + bouton + note ─────────
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        padding: EdgeInsets.fromLTRB(r.hPad, r.s(14), r.hPad,
            r.s(20) + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ligne total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Total à payer',
                    style: TextStyle(fontSize: r.fs(13), color: AppTheme.mutedForeground)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: product != null ? '$priceMain ' : '0 ',
                        style: TextStyle(fontSize: r.fs(20), fontWeight: FontWeight.w800,
                            color: AppTheme.foreground, fontFamily: 'PlusJakartaSans'),
                      ),
                      TextSpan(
                        text: 'FCFA',
                        style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w700,
                            color: AppTheme.foreground, fontFamily: 'PlusJakartaSans'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: r.s(12)),

            // Bouton Confirmer
            GestureDetector(
              onTap: () {
                setState(() => _confirmed = true);
                Future.delayed(const Duration(seconds: 3), () => Get.offAllNamed('/home'));
              },
              child: Container(
                width: double.infinity,
                height: r.s(54).clamp(50.0, 62.0),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(r.rad(30)),
                  boxShadow: AppTheme.shadowPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Confirmer la commande',
                        style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(width: r.s(6)),
                    Icon(Icons.arrow_forward_ios_rounded, size: r.s(13), color: Colors.white),
                  ],
                ),
              ),
            ),

            SizedBox(height: r.s(8)),

            // Note légale contextuelle
            Text(
              _mode == 'livraison'
                  ? 'En confirmant, vous vous engagez à réceptionner votre commande.'
                  : 'En confirmant, vous vous engagez à venir récupérer votre commande.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.fs(10), color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget : option radio mode livraison / retrait ────────────────────────────
class _OrderModeOption extends StatelessWidget {
  final String value, groupValue, title, subtitle;
  final VoidCallback onTap;
  final R r;
  const _OrderModeOption({
    required this.value, required this.groupValue,
    required this.title, required this.subtitle,
    required this.onTap, required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(14)),
        decoration: BoxDecoration(
          // Fond blanc dans les deux cas — seule la bordure change
          color: active ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(r.rad(14)),
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Bouton radio dessiné à la main
            Container(
              width: r.s(22), height: r.s(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppTheme.primary : const Color(0xFFBBB5B0),
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: active
                  ? Center(
                      child: Container(
                        width: r.s(11), height: r.s(11),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: r.s(14)),
            // Textes — titre toujours en noir/foreground (pas orange)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: FontWeight.w700,
                        // Titre reste foreground même quand actif — comme dans la maquette
                        color: AppTheme.foreground,
                      )),
                  SizedBox(height: r.s(2)),
                  Text(subtitle,
                      style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
