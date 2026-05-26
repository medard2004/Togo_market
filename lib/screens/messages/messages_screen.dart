import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../utils/responsive.dart';
import 'widgets/filter_modal.dart';
import 'widgets/conversation_tile.dart';
import '../../Api/firebase/controllers/chat_controller.dart';
import '../../Api/provider/auth_controller.dart';
import '../../Api/config/api_constants.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Ã‰tat des filtres
  bool _hasActiveFilters = false;
  String _selectedSort =
      'date_desc'; // date_desc, date_asc, name_asc, name_desc
  bool _showOnlineOnly = false;
  bool _showUnreadOnly = false;

  // Ã‰tat de sÃ©lection multiple
  bool _isSelectionMode = false;

  final Set<String> _selectedMessages = {}; // Utilise le nom comme clé unique

  String get _currentUserId {
    final auth =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    return auth?.currentUser.value?.id.toString() ?? '';
  }

  // Modèle converti depuis Firestore
  List<_ConvItem> get _convItems {
    if (!Get.isRegistered<ChatController>()) return [];
    final chats = ChatController.to.userChats.toList();
    final myId = _currentUserId;
    final myUid = 'user_$myId';

    return chats.map((chat) {
      final otherName = chat.otherParticipantName(myUid);
      final otherAvatar = chat.otherParticipantAvatar(myUid);
      final resolvedAvatar = otherAvatar.isNotEmpty
          ? ApiConstants.resolveImageUrl(otherAvatar)
          : '';
      final productImg =
          chat.productImage != null && chat.productImage!.isNotEmpty
              ? ApiConstants.resolveImageUrl(chat.productImage!)
              : null;

      final otherUid = chat.otherParticipantUid(myUid);
      final isSentByMe = chat.lastMessageSenderId == myUid || chat.lastMessageSenderId == myId;
      final isSeenByOther = chat.unreadCounts[otherUid] == 0;

      return _ConvItem(
        id: chat.id,
        name: otherName,
        time:
            '${chat.lastMessageTime.hour.toString().padLeft(2, '0')}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
        rawTime: chat.lastMessageTime,
        msg: chat.lastMessage,
        unread: chat.unreadCountFor(myUid),
        img: resolvedAvatar,
        productImg: productImg,
        isSentByMe: isSentByMe,
        isSeenByOther: isSeenByOther,
      );
    }).toList();
  }

  List<_ConvItem> get _filtered {
    List<_ConvItem> filtered = List.from(_convItems);

    // Filtre par statut en ligne
    if (_showOnlineOnly) {
      // Pour la dÃ©mo, on considÃ¨re que certains utilisateurs sont en ligne
      final onlineNames = ['Koffi Mensah', 'Essi Gado', 'Amivi Lawson'];
      filtered = filtered.where((c) => onlineNames.contains(c.name)).toList();
    }

    // Filtre par non lus
    if (_showUnreadOnly) {
      filtered = filtered.where((c) => c.unread > 0).toList();
    }

    // Tri selon le critÃ¨re sÃ©lectionnÃ©
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'date_desc':
          // Tri par date dÃ©croissante (plus rÃ©cent d'abord)
          return b.rawTime.compareTo(a.rawTime);
        case 'date_asc':
          // Tri par date croissante (plus ancien d'abord)
          return a.rawTime.compareTo(b.rawTime);
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

  // MÃ©thodes pour la gestion de la sÃ©lection
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
      // Pour Firebase, on appellerait une méthode de suppression.
      // ChatService.to.deleteChats(_selectedMessages.toList());

      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Get.offAllNamed('/home');
        },
        child: Scaffold(
          backgroundColor: AppTheme.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(r.hPad, r.s(10), r.hPad, r.s(14)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            _isSelectionMode
                                ? '${_selectedMessages.length} sÃ©lectionnÃ©(s)'
                                : 'Messages',
                            style: TextStyle(
                                fontSize: r.fs(15),
                                fontWeight: FontWeight.w800,
                                color: AppTheme.foreground)),
                      ),
                      GestureDetector(
                        onTap: _toggleSelectionMode,
                        child: Container(
                          padding: EdgeInsets.all(r.s(3)),
                          decoration: BoxDecoration(
                            color: _isSelectionMode
                                ? AppTheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(r.rad(4)),
                          ),
                          child: Icon(
                            _isSelectionMode
                                ? Icons.close
                                : Icons.checklist_rounded,
                            size: r.s(18),
                            color: _isSelectionMode
                                ? AppTheme.primary
                                : AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // â”€â”€ Barre de recherche â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.hPad),
                  child: Container(
                    height: r.s(50).clamp(46.0, 56.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
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
                        // Container pour l'icÃ´ne avec fond colorÃ©
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
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: r.s(12)),
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

                // â”€â”€ Liste conversations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Expanded(
                  child: Obx(() {
                    if (_filtered.isEmpty) {
                      return Center(
                          child: Text('Aucun message',
                              style: TextStyle(
                                  color: AppTheme.mutedForeground,
                                  fontSize: r.fs(14))));
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(24)),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: r.s(8)),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleMessageSelection(_filtered[i].name);
                          } else {
                            Get.toNamed('/chat/${_filtered[i].id}?asBoutique=false');
                          }
                        },
                        child: ConversationTile(
                          item: _filtered[i],
                          r: r,
                          isSelectionMode: _isSelectionMode,
                          isSelected:
                              _selectedMessages.contains(_filtered[i].name),
                          onSelectionChanged: () =>
                              _toggleMessageSelection(_filtered[i].name),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _isSelectionMode
              ? _buildSelectionActionBar(context)
              : const BottomNavBar(currentIndex: 3),
        ));
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    final r = R(context);
    final allSelected = _selectedMessages.length == _filtered.length;
    final hasSelection = _selectedMessages.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(r.hPad, r.s(12), r.hPad,
          r.s(12) + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.border,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Tout sÃ©lectionner
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
                    allSelected
                        ? 'Tout dÃ©sÃ©lectionner'
                        : 'Tout sÃ©lectionner',
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
                      color: hasSelection
                          ? Colors.white
                          : AppTheme.mutedForeground,
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

// ModÃ¨le de donnÃ©es conversation mock
class _ConvItem {
  final String id, name, time, msg, img;
  final DateTime rawTime;
  final int unread;
  final String? productImg;
  final bool isSentByMe;
  final bool isSeenByOther;

  const _ConvItem({
    required this.id,
    required this.name,
    required this.time,
    required this.rawTime,
    required this.msg,
    required this.img,
    required this.unread,
    required this.productImg,
    this.isSentByMe = false,
    this.isSeenByOther = false,
  });
}
