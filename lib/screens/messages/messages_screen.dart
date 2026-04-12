import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../utils/responsive.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/filter_modal.dart';

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
    _ConvItem(
        name: 'Koffi Mensah',
        time: '14:20',
        msg: 'C\'est toujours disponible à Lom...',
        unread: 1,
        img:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&crop=face',
        productImg:
            'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=80&h=80&fit=crop'),
    _ConvItem(
        name: 'Essi Gado',
        time: 'Dim.',
        msg: 'Je peux voir d\'autres photos ?',
        unread: 1,
        img:
            'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&h=80&fit=crop&crop=face',
        productImg:
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=80&h=80&fit=crop'),
    _ConvItem(
        name: 'Amivi Lawson',
        time: 'Hier',
        msg: 'Merci, je passe la prendre à 17h.',
        unread: 0,
        img:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&crop=face',
        productImg:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=80&h=80&fit=crop'),
    _ConvItem(
        name: 'Kodjo Aziamble',
        time: 'Lun.',
        msg: 'Quel est votre dernier prix svp ?',
        unread: 0,
        img:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=face',
        productImg:
            'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=80&h=80&fit=crop'),
    _ConvItem(
        name: 'Yao Kouame',
        time: '12 Oct.',
        msg: 'D\'accord, c\'est noté.',
        unread: 0,
        img:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&crop=face',
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
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.muted.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
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
                      onTap: () => _showFilterModal(context),
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
                  ? Center(
                      child: Text('Aucun message',
                          style: TextStyle(
                              color: AppTheme.mutedForeground,
                              fontSize: r.fs(14))))
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(24)),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: r.s(8)),
                      itemBuilder: (_, i) => ConversationTile(
                        item: _filtered[i],
                        r: r,
                        isSelectionMode: _isSelectionMode,
                        isSelected:
                            _selectedMessages.contains(_filtered[i].name),
                        onSelectionChanged: () =>
                            _toggleMessageSelection(_filtered[i].name),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isSelectionMode
          ? _buildSelectionActionBar(context)
          : const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    final r = R(context);
    final allSelected = _selectedMessages.length == _filtered.length;
    final hasSelection = _selectedMessages.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
          r.hPad,
          r.s(12),
          r.hPad,
          r.s(12) + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
                  color: hasSelection
                      ? AppTheme.destructive
                      : AppTheme.muted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.rad(12)),
                ),
                child: Center(
                  child: Text(
                    'Supprimer',
                    style: TextStyle(
                      fontSize: r.fs(14),
                      fontWeight: FontWeight.w600,
                      color:
                          hasSelection ? Colors.white : AppTheme.mutedForeground,
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
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        selectedSort: _selectedSort,
        showOnlineOnly: _showOnlineOnly,
        showUnreadOnly: _showUnreadOnly,
        onSortChanged: (value) => setState(() => _selectedSort = value),
        onOnlineOnlyChanged: (value) => setState(() => _showOnlineOnly = value),
        onUnreadOnlyChanged: (value) => setState(() => _showUnreadOnly = value),
        onFiltersApplied: () => setState(() => _hasActiveFilters =
            _selectedSort != 'date_desc' || _showOnlineOnly || _showUnreadOnly),
      ),
    );
  }
}

// Modèle de données conversation mock
class _ConvItem {
  final String name, time, msg, img;
  final int unread;
  final String? productImg;
  const _ConvItem(
      {required this.name,
      required this.time,
      required this.msg,
      required this.img,
      required this.unread,
      required this.productImg});
}
