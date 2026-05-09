import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';
import '../../Api/firebase/controllers/chat_controller.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/provider/auth_controller.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/config/api_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _chatCtrl = Get.find<ChatController>();

  bool _messageSentInThisSession = false;
  bool _isRecording = false;
  bool _isUploading = false;
  final _recorder = AudioRecorder();
  String? _recordingPath;

  final _quickReplies = [
    '👀 Toujours disponible ?',
    '💰 Meilleur prix ?',
    '📦 Livraison possible ?',
    '📸 Plus de photos ?',
    '🤝 Négociable ?',
  ];

  late Product? _activeProduct;
  bool _showProductPreview = false;

  String get _currentUserId {
    final auth = Get.find<AuthController>();
    return auth.currentUser.value?.id.toString() ?? '';
  }

  String get _actingUserId {
    if (Get.parameters['asBoutique'] == 'true') {
      if (Get.isRegistered<BoutiqueController>()) {
        final b = Get.find<BoutiqueController>().myBoutique.value;
        if (b != null) return b.id.toString();
      }
    }
    return _currentUserId;
  }

  String get _convId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    final convId = _convId;
    
    // Déterminer si l'utilisateur est acheteur (pour backward compat)
    final parts = convId.split('_');
    bool isBuyer = true;
    if (parts.length == 2) {
      isBuyer = parts[0] == _actingUserId || 
                int.tryParse(parts[0]).toString() == _actingUserId;
    }

    _chatCtrl.loadConversation(convId, isBuyer: isBuyer, actingUserId: _actingUserId);

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
    if (content.isEmpty) return;

    _msgCtrl.clear();
    final convId = _convId;
    final myId = _actingUserId;

    // Trouver l'ID du destinataire depuis la session Firestore
    final session = _chatCtrl.currentChatSession.value;
    String receiverId = '';
    if (session != null) {
      receiverId = session.otherParticipantId(myId);
    } else {
      // Fallback: extraire depuis l'ID de conversation
      final parts = convId.split('_');
      if (parts.length == 2) {
        receiverId = parts[0] == myId ? parts[1] : parts[0];
      }
    }

    _chatCtrl.sendMessage(
      convId, 
      myId, 
      receiverId, 
      content,
      productId: _showProductPreview ? _activeProduct?.id.toString() : null,
      isBuyerSending: true, // N'est plus utilisé dans le nouveau format
    );

    _messageSentInThisSession = true;

    // Clear product preview after sending
    if (_showProductPreview) {
      setState(() => _showProductPreview = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachOption(
                icon: Icons.photo_library_rounded,
                label: 'Galerie',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _AttachOption(
                icon: Icons.camera_alt_rounded,
                label: 'Caméra',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _AttachOption(
                icon: Icons.mic_rounded,
                label: 'Vocal',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _startRecording();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1200);
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final file = File(picked.path);
      final convId = _convId;
      final myId = _actingUserId;
      final session = _chatCtrl.currentChatSession.value;
      final receiverId = session?.otherParticipantId(myId) ?? '';
      if (receiverId.isEmpty) return;

      final url = await ChatService.to.uploadMedia(convId, file, 'image');

      _chatCtrl.sendMessage(
        convId, myId, receiverId, '',
        productId: _showProductPreview ? _activeProduct?.id.toString() : null,
        isBuyerSending: true,
        type: 'image',
        mediaUrl: url,
      );
      _messageSentInThisSession = true;
      if (_showProductPreview) setState(() => _showProductPreview = false);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'envoyer l\'image.');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = Directory.systemTemp;
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() {
        _isRecording = true;
        _recordingPath = path;
      });
    } else {
      Get.snackbar('Permission', 'Accès au microphone requis.');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    setState(() => _isUploading = true);
    try {
      final file = File(path);
      final convId = _convId;
      final myId = _actingUserId;
      final session = _chatCtrl.currentChatSession.value;
      final receiverId = session?.otherParticipantId(myId) ?? '';
      if (receiverId.isEmpty) return;

      // Calculer la durée approximative
      final player = AudioPlayer();
      await player.setSourceDeviceFile(path);
      final duration = await player.getDuration();
      final durationSec = (duration?.inSeconds ?? 0);
      player.dispose();

      final url = await ChatService.to.uploadMedia(convId, file, 'voice');

      _chatCtrl.sendMessage(
        convId, myId, receiverId, '',
        isBuyerSending: true,
        type: 'voice',
        mediaUrl: url,
        mediaDuration: durationSec,
      );
      _messageSentInThisSession = true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'envoyer le vocal.');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final myId = _actingUserId;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_messageSentInThisSession && _activeProduct != null) {
          Get.offAllNamed('/messages');
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final session = _chatCtrl.currentChatSession.value;
          
          // Résoudre le nom et l'avatar de l'interlocuteur
          String otherName = 'Chargement...';
          String otherAvatar = '';
          
          if (session != null) {
            otherName = session.otherParticipantName(myId);
            otherAvatar = session.otherParticipantAvatar(myId);
          } else if (_activeProduct != null) {
            // Fallback depuis le produit passé en argument
            final p = _activeProduct!;
            if (p.boutiqueObj != null) {
              otherName = p.boutiqueObj!.nom;
              otherAvatar = p.boutiqueObj!.logoUrl;
            } else if (p.userObj != null) {
              otherName = p.userObj!.nom ?? 'Vendeur';
              otherAvatar = p.userObj!.avatarUrl ?? '';
            }
          }
          
          final resolvedAvatar = otherAvatar.isNotEmpty 
              ? ApiConstants.resolveImageUrl(otherAvatar) 
              : '';
          
          // Image produit pour l'action de l'AppBar
          final productImage = session?.productImage ?? _activeProduct?.image;
          final productId = session?.productId ?? _activeProduct?.id.toString();

          return AppBar(
            backgroundColor: AppTheme.cardColor,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () {
                if (_messageSentInThisSession && _activeProduct != null) {
                  Get.offAllNamed('/messages');
                } else {
                  Get.back();
                }
              },
            ),
            title: Row(
              children: [
                if (resolvedAvatar.isNotEmpty)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(resolvedAvatar),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.muted,
                    child: Icon(Icons.person, size: 18, color: AppTheme.mutedForeground),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'En ligne',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (productImage != null && productImage.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (productId != null) Get.toNamed('/product/$productId');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(ApiConstants.resolveImageUrl(productImage)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: _scrollCtrl,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _chatCtrl.currentMessages.length,
                itemBuilder: (_, i) {
                  final msg = _chatCtrl.currentMessages[i];
                  final session = _chatCtrl.currentChatSession.value;
                  final otherAvatar = session?.otherParticipantAvatar(myId) ?? '';
                  return _MessageBubble(
                      message: msg, sellerAvatar: otherAvatar, isMe: msg.senderId == myId);
                },
              );
            }),
          ),
          // Quick replies
          Obx(() {
            if (_chatCtrl.currentMessages.isNotEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_quickReplies[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      _quickReplies[i],
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 8),
          // Input
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 4, 16, MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? null : _showAttachMenu,
                      child: Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child: Icon(_isRecording ? Icons.mic : Icons.add,
                            color: _isRecording ? Colors.red : AppTheme.primary, size: r.s(24)),
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
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 5,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                          ),
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
                    SizedBox(width: 8),
                    if (_isRecording)
                      GestureDetector(
                        onTap: _stopRecordingAndSend,
                        child: Container(
                          width: r.s(48),
                          height: r.s(48),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: Icon(Icons.stop, color: Colors.white, size: 20),
                        ),
                      )
                    else if (_isUploading)
                      Container(
                        width: r.s(48),
                        height: r.s(48),
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
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
                          child: Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final String sellerAvatar;
  final bool isMe;

  const _MessageBubble({required this.message, required this.sellerAvatar, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final msgType = message.type ?? 'text';
    
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
                  ? CachedNetworkImageProvider(ApiConstants.resolveImageUrl(sellerAvatar))
                  : null,
              child: sellerAvatar.isEmpty
                  ? Icon(Icons.person, size: 16)
                  : null,
            ),
            SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: msgType == 'image'
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                // Image
                if (msgType == 'image' && message.mediaUrl != null)
                  GestureDetector(
                    onTap: () => _showFullImage(context, message.mediaUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: message.mediaUrl!,
                        width: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 150,
                          color: AppTheme.muted,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 100,
                          color: AppTheme.muted,
                          child: Icon(Icons.broken_image, color: AppTheme.mutedForeground),
                        ),
                      ),
                    ),
                  ),
                // Voice
                if (msgType == 'voice' && message.mediaUrl != null)
                  _VoicePlayerWidget(
                    url: message.mediaUrl!,
                    duration: message.mediaDuration ?? 0,
                    isMe: isMe,
                  ),
                // Text
                if (msgType == 'text' && (message.content as String).isNotEmpty)
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
                SizedBox(height: 4),
                Padding(
                  padding: msgType == 'image' ? const EdgeInsets.symmetric(horizontal: 10, vertical: 2) : EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.mutedForeground,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          message.seen ? Icons.done_all : Icons.check,
                          size: 14,
                          color: message.seen ? Colors.blueAccent : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.foreground)),
        ],
      ),
    );
  }
}

class _VoicePlayerWidget extends StatefulWidget {
  final String url;
  final int duration;
  final bool isMe;

  const _VoicePlayerWidget({required this.url, required this.duration, required this.isMe});

  @override
  State<_VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<_VoicePlayerWidget> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.duration);
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted && dur.inSeconds > 0) setState(() => _totalDuration = dur);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _position = Duration.zero; });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_position.inSeconds == 0) {
        await _player.play(UrlSource(widget.url));
      } else {
        await _player.resume();
      }
      setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? _position.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: widget.isMe ? Colors.white : AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: widget.isMe ? Colors.white.withOpacity(0.2) : AppTheme.muted,
                  valueColor: AlwaysStoppedAnimation(widget.isMe ? Colors.white : AppTheme.primary),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isPlaying ? _formatDuration(_position) : _formatDuration(_totalDuration),
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isMe ? Colors.white.withOpacity(0.7) : AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
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
                  CachedNetworkImageProvider(ApiConstants.resolveImageUrl(seller.avatar as String)),
            ),
          SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4),
                _Dot(delay: 200),
                SizedBox(width: 4),
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
          decoration: BoxDecoration(
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
              imageUrl: ApiConstants.resolveImageUrl(product.image),
              width: r.s(32),
              height: r.s(32),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: r.s(32),
                height: r.s(32),
                color: AppTheme.muted,
                child: Icon(Icons.image_not_supported, size: r.s(16), color: AppTheme.mutedForeground),
              ),
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
    final appCtrl = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
    final product = appCtrl?.products.firstWhereOrNull((p) => p.id.toString() == productId) 
                    ?? getProductById(productId);
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Get.toNamed('/product/$productId'),
      child: Container(
        margin: EdgeInsets.only(bottom: r.s(6)),
        padding: EdgeInsets.all(r.s(2)),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(18)),
          boxShadow: [
            BoxShadow(
                color: AppTheme.border.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(r.rad(16)),
              child: CachedNetworkImage(
                imageUrl: ApiConstants.resolveImageUrl(product.image),
                height: r.s(110),
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: r.s(110),
                  width: double.infinity,
                  color: AppTheme.muted,
                  child: Icon(Icons.image_not_supported, size: r.s(30), color: AppTheme.mutedForeground),
                ),
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
