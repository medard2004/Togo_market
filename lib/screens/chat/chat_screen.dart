import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../map/unified_map_screen.dart';
import '../../utils/chat_media_cache_manager.dart';
import '../../theme/app_theme.dart';
import '../../Api/firebase/controllers/chat_controller.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/firebase/services/firebase_auth_bridge_service.dart';
import '../../Api/provider/auth_controller.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/config/api_constants.dart';
import '../../utils/image_optimization_service.dart';

enum VoiceRecordState {
  none,
  recording,
  paused,
  preview,
}

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
  bool _isUploading = false;
  bool _isBuyer = true;

  // Audio record variables
  final _recorder = AudioRecorder();
  String? _recordingPath;
  VoiceRecordState _recordState = VoiceRecordState.none;
  int _recordDuration = 0;
  Timer? _recordTimer;

  // Audio player preview variables
  final _previewPlayer = AudioPlayer();
  bool _isPreviewPlaying = false;
  Duration _previewPosition = Duration.zero;
  Duration _previewDuration = Duration.zero;

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
    if (_isActingAsBoutique) {
      if (Get.isRegistered<BoutiqueController>()) {
        final b = Get.find<BoutiqueController>().myBoutique.value;
        if (b != null) return b.id.toString();
      }
    }
    return _currentUserId;
  }

  String get _convId => Get.parameters['id'] ?? '';

  bool get _isActingAsBoutique {
    // 1. Si le paramètre URL force une valeur, on l'utilise
    final param = Get.parameters['asBoutique'];
    if (param != null) {
      return param == 'true';
    }

    // 2. Sinon, auto-détection robuste basée sur le chatId et la boutique de l'utilisateur
    final convId = _convId;
    if (convId.startsWith('shop_')) {
      if (Get.isRegistered<BoutiqueController>()) {
        final b = Get.find<BoutiqueController>().myBoutique.value;
        if (b != null) {
          final shopId = b.id.toString();
          final parts = convId.split('_');
          if (parts.length == 3) {
            return parts[1] == shopId || parts[2] == shopId;
          }
        }
      }
    }
    return false;
  }

  bool _isValidConvId(String convId) =>
      convId.isNotEmpty && convId.contains('_');

  void _showInvalidConversationError() {
    Get.snackbar(
      'Conversation invalide',
      'Impossible d\'envoyer le média. Rouvrez la discussion depuis le produit ou les messages.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void initState() {
    super.initState();
    ChatMediaCacheManager.init();
    final convId = _convId;

    if (_isValidConvId(convId) &&
        Get.isRegistered<FirebaseAuthBridgeService>()) {
      FirebaseAuthBridgeService.to
          .ensureSignedInForChat(
        convId,
        asBoutique: _isActingAsBoutique,
      )
          .catchError((e) {
        debugPrint('ChatScreen initState: ensureSignedInForChat failed: $e');
      });
    }

    // Déterminer si l'utilisateur est acheteur (pour backward compat)
    final parts = convId.split('_');
    if (parts.length == 3) {
      _isBuyer = parts[1] == _actingUserId ||
          int.tryParse(parts[1]).toString() == _actingUserId;
    } else if (parts.length == 2) {
      _isBuyer = parts[0] == _actingUserId ||
          int.tryParse(parts[0]).toString() == _actingUserId;
    }

    _chatCtrl.loadConversation(
      convId, 
      actingEntityId: _actingUserId,
      actingEntityType: _isActingAsBoutique ? 'shop' : 'user',
    );

    _activeProduct =
        (Get.arguments is Product) ? Get.arguments as Product : null;
    _showProductPreview = _activeProduct != null;

    // Auto-fill context message
    if (_showProductPreview) {
      _msgCtrl.text = 'Bonjour, je sei intéressé par votre annonce.';
    }

    // Écouter les événements du lecteur de prévisualisation vocale
    _previewPlayer.onPositionChanged.listen((pos) {
      if (mounted && _recordState == VoiceRecordState.preview) {
        setState(() => _previewPosition = pos);
      }
    });
    _previewPlayer.onDurationChanged.listen((dur) {
      if (mounted && _recordState == VoiceRecordState.preview) {
        setState(() => _previewDuration = dur);
      }
    });
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted && _recordState == VoiceRecordState.preview) {
        setState(() {
          _isPreviewPlaying = false;
          _previewPosition = Duration.zero;
        });
      }
    });
  }

  void _send([String? text]) {
    final content = text ?? _msgCtrl.text.trim();
    if (content.isEmpty) return;

    _msgCtrl.clear();
    final convId = _convId;
    final myId = _actingUserId;

    // Trouver l'ID du destinataire depuis la session Firestore
    final session = _chatCtrl.currentChatSession.value;
    final myUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
    String receiverId = '';
    String receiverEntityType = 'user';
    if (session != null) {
      final receiverUid = session.otherParticipantUid(myUid);
      final parts = receiverUid.split('_');
      if (parts.length >= 2) {
        receiverEntityType = parts[0];
        receiverId = parts.sublist(1).join('_');
      }
    } else {
      // Fallback: extraire depuis l'ID de conversation
      final parts = convId.split('_');
      if (parts.length == 3) {
        receiverId = parts[1] == myId ? parts[2] : parts[1];
      } else if (parts.length == 2) {
        receiverId = parts[0] == myId ? parts[1] : parts[0];
      }
    }

    _chatCtrl.sendMessage(
      convId,
      myId,
      _isActingAsBoutique ? 'shop' : 'user',
      receiverId,
      receiverEntityType,
      content,
      productId: _showProductPreview ? _activeProduct?.id.toString() : null,
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
              _AttachOption(
                icon: Icons.location_on_rounded,
                label: 'Position',
                color: Colors.green,
                onTap: () async {
                  Navigator.pop(context);
                  final res = await Get.to(() => const UnifiedMapScreen());
                  if (res != null && res is Map) {
                    final lat = res['latitude'] as double;
                    final lon = res['longitude'] as double;
                    final address = res['address'] as String;

                    final convId = _convId;
                    if (!_isValidConvId(convId)) {
                      _showInvalidConversationError();
                      return;
                    }
                    final myId = _actingUserId;
                    final session = _chatCtrl.currentChatSession.value;
                    final myUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
                    String receiverId = '';
                    String receiverEntityType = 'user';
                    if (session != null) {
                      final receiverUid = session.otherParticipantUid(myUid);
                      final parts = receiverUid.split('_');
                      if (parts.length >= 2) {
                        receiverEntityType = parts[0];
                        receiverId = parts[1];
                      }
                    }
                    if (receiverId.isEmpty) return;

                    await _chatCtrl.sendLocationMessage(
                      convId,
                      myId,
                      _isActingAsBoutique ? 'shop' : 'user',
                      receiverId,
                      receiverEntityType,
                      lat,
                      lon,
                      address,
                    );
                    _messageSentInThisSession = true;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultipleImagesPreview(List<File> initialFiles) {
    final textController = TextEditingController();
    final List<File> selectedFiles = List.from(initialFiles);

    Get.dialog(
      Dialog.fullscreen(
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            if (selectedFiles.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Get.isDialogOpen ?? false) Get.back();
              });
              return const SizedBox.shrink();
            }

            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  selectedFiles.length == 1
                      ? 'Prévisualiser l\'image'
                      : 'Prévisualiser (${selectedFiles.length} images)',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: selectedFiles.length == 1
                        ? InteractiveViewer(
                            maxScale: 4.0,
                            child: Center(
                              child: Image.file(
                                selectedFiles.first,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: selectedFiles.length,
                            itemBuilder: (context, index) {
                              final file = selectedFiles[index];
                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          selectedFiles.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: Colors.black87,
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: textController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                                maxLines: 4,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Ajouter une légende...',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              _uploadAndSendMultipleImages(
                                  selectedFiles, textController.text.trim());
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      useSafeArea: false,
    );
  }

  void _uploadAndSendMultipleImages(List<File> imageFiles, String caption) {
    if (imageFiles.isEmpty) return;

    final wasProductPreview = _showProductPreview;
    final productPreviewId = _activeProduct?.id.toString();

    if (_showProductPreview) {
      setState(() => _showProductPreview = false);
    }

    final convId = _convId;
    if (!_isValidConvId(convId)) {
      _showInvalidConversationError();
      return;
    }
    final myId = _actingUserId;
    final myUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
    final session = _chatCtrl.currentChatSession.value;
    String receiverId = '';
    String receiverEntityType = 'user';
    if (session != null) {
      final receiverUid = session.otherParticipantUid(myUid);
      final parts = receiverUid.split('_');
      if (parts.length >= 2) {
        receiverEntityType = parts[0];
        receiverId = parts.sublist(1).join('_');
      }
    }
    if (receiverId.isEmpty) return;

    _messageSentInThisSession = true;

    // Lancer chaque image en upload concurrentiel via le controller (Optimistic UI)
    for (int i = 0; i < imageFiles.length; i++) {
      final messageCaption = (i == 0) ? caption : '';
      _chatCtrl.uploadAndSendImage(
        convId,
        myId,
        _isActingAsBoutique ? 'shop' : 'user',
        receiverId,
        receiverEntityType,
        imageFiles[i],
        messageCaption,
        _isActingAsBoutique,
        productId: wasProductPreview && i == 0 ? productPreviewId : null,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      try {
        final pickedList =
            await picker.pickMultiImage(imageQuality: 70, maxWidth: 1200);
        if (pickedList.isEmpty) return;
        final files = pickedList.map((picked) => File(picked.path)).toList();
        _showMultipleImagesPreview(files);
      } catch (e) {
        debugPrint('Error picking multi image: $e');
        final picked = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 70, maxWidth: 1200);
        if (picked == null) return;
        _showMultipleImagesPreview([File(picked.path)]);
      }
    } else {
      final picked = await picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 1200);
      if (picked == null) return;
      _showMultipleImagesPreview([File(picked.path)]);
    }
  }

  void _startTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
    // NE PAS remettre _recordDuration à 0 ici !
    // La durée est utilisée comme fallback dans _sendVoiceNote
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = Directory.systemTemp;
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path);
      setState(() {
        _recordState = VoiceRecordState.recording;
        _recordingPath = path;
        _recordDuration = 0;
      });
      _startTimer();
    } else {
      Get.snackbar(
        'Permission requise',
        'Veuillez autoriser l\'accès au microphone dans les paramètres de votre appareil.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    _recordTimer?.cancel();
    setState(() {
      _recordState = VoiceRecordState.paused;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    _startTimer();
    setState(() {
      _recordState = VoiceRecordState.recording;
    });
  }

  String _cleanFilePath(String filePath) {
    if (filePath.startsWith('file://')) {
      try {
        return Uri.parse(filePath).toFilePath();
      } catch (e) {
        return filePath.replaceFirst('file://', '');
      }
    } else if (filePath.startsWith('file:')) {
      return filePath.replaceFirst('file:', '');
    }
    return filePath;
  }

  Future<void> _cancelRecording() async {
    await _recorder.stop();
    _stopTimer();
    if (_recordingPath != null) {
      final file = File(_cleanFilePath(_recordingPath!));
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _recordState = VoiceRecordState.none;
      _recordingPath = null;
      _recordDuration = 0;
    });
  }

  Future<void> _stopAndPreviewRecording() async {
    // Sauvegarder la durée AVANT de l'annuler
    final savedDuration = _recordDuration;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      debugPrint('Error stopping recorder: $e');
    }
    _stopTimer();

    // Utiliser le path retourné, ou celui stocké au début de l'enregistrement
    final finalPath = _cleanFilePath(path ?? _recordingPath ?? '');
    if (finalPath.isEmpty) {
      debugPrint(
          '❌ Aucun fichier audio trouvé après arrêt de l\'enregistrement');
      setState(() => _recordState = VoiceRecordState.none);
      return;
    }

    // Vérifier que le fichier existe
    final audioFile = File(finalPath);
    if (!await audioFile.exists()) {
      debugPrint('❌ Fichier audio introuvable: $finalPath');
      setState(() => _recordState = VoiceRecordState.none);
      return;
    }

    final fileSize = await audioFile.length();
    debugPrint(
        '✅ Audio enregistré: $finalPath (${fileSize}B, ${savedDuration}s)');

    // Durée : utiliser la durée du timer comme base fiable
    Duration duration =
        Duration(seconds: savedDuration > 0 ? savedDuration : 1);
    try {
      final player = AudioPlayer();
      await player.setSourceDeviceFile(finalPath);
      final dur = await player.getDuration();
      if (dur != null && dur.inSeconds > 0) {
        duration = dur;
      }
      player.dispose();
    } catch (e) {
      debugPrint('Impossible de lire la durée audio, utilisation du timer: $e');
    }

    setState(() {
      _recordState = VoiceRecordState.preview;
      _recordingPath = finalPath;
      _previewDuration = duration;
      _previewPosition = Duration.zero;
      _isPreviewPlaying = false;
    });
  }

  Future<void> _playPreview() async {
    if (_recordingPath == null) return;
    final cleanPath = _cleanFilePath(_recordingPath!);
    if (_isPreviewPlaying) {
      await _previewPlayer.pause();
      setState(() => _isPreviewPlaying = false);
    } else {
      await _previewPlayer.play(DeviceFileSource(cleanPath));
      setState(() => _isPreviewPlaying = true);
    }
  }

  Future<void> _deletePreview() async {
    await _previewPlayer.stop();
    if (_recordingPath != null) {
      final file = File(_cleanFilePath(_recordingPath!));
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _recordState = VoiceRecordState.none;
      _recordingPath = null;
      _isPreviewPlaying = false;
      _previewPosition = Duration.zero;
      _previewDuration = Duration.zero;
      _recordDuration = 0;
    });
  }

  Future<void> _sendVoiceNote() async {
    if (_recordingPath == null) return;
    await _previewPlayer.stop();
    final cleanPath = _cleanFilePath(_recordingPath!);

    setState(() {
      _isUploading = true;
      _recordState = VoiceRecordState.none;
    });

    try {
      final file = File(cleanPath);
      if (!await file.exists()) {
        throw Exception("Le fichier audio n'existe pas localement.");
      }

      final convId = _convId;
      if (!_isValidConvId(convId)) {
        _showInvalidConversationError();
        return;
      }
      final myId = _actingUserId;
      final myUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
      final session = _chatCtrl.currentChatSession.value;
      String receiverId = '';
      String receiverEntityType = 'user';
      if (session != null) {
        final receiverUid = session.otherParticipantUid(myUid);
        final parts = receiverUid.split('_');
        if (parts.length >= 2) {
          receiverEntityType = parts[0];
          receiverId = parts.sublist(1).join('_');
        }
      }
      if (receiverId.isEmpty) {
        throw Exception("Destinataire introuvable dans la session.");
      }

      final durationSec = _previewDuration.inSeconds > 0
          ? _previewDuration.inSeconds
          : (_recordDuration > 0 ? _recordDuration : 1);

      debugPrint(
          'Uploading voice note of duration: $durationSec s, file: ${file.path}');
      final url = await ChatService.to.uploadMedia(
        convId,
        file,
        'voice',
        asBoutique: _isActingAsBoutique,
      );
      debugPrint('Voice note uploaded successfully: $url');

      await _chatCtrl.sendMessage(
        convId,
        myId,
        _isActingAsBoutique ? 'shop' : 'user',
        receiverId,
        receiverEntityType,
        '',
        type: 'voice',
        mediaUrl: url,
        mediaDuration: durationSec,
      );
      _messageSentInThisSession = true;
    } catch (e) {
      debugPrint('❌ Error sending voice note: $e');
      final msg = e.toString().contains('Firebase')
          ? 'Connexion Firebase ou Storage refusée. Vérifiez la console Firebase (Storage + règles déployées).'
          : 'Impossible d\'envoyer le message vocal : $e';
      Get.snackbar(
        'Erreur d\'envoi',
        msg,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _recordingPath = null;
      });
    }
  }

  @override
  void dispose() {
    if (_isActingAsBoutique && Get.isRegistered<FirebaseAuthBridgeService>()) {
      FirebaseAuthBridgeService.to.signInWithBackendToken(asBoutique: false);
    }
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    _previewPlayer.dispose();
    _recordTimer?.cancel();
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
                final myUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
                otherName = session.otherParticipantName(myUid);
                otherAvatar = session.otherParticipantAvatar(myUid);
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
              final productImage =
                  session?.productImage ?? _activeProduct?.image;
              final productId =
                  session?.productId ?? _activeProduct?.id.toString();

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
                        backgroundImage:
                            CachedNetworkImageProvider(resolvedAvatar),
                      )
                    else
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.muted,
                        child: Icon(Icons.person,
                            size: 18, color: AppTheme.mutedForeground),
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
                        if (productId != null)
                          Get.toNamed('/product/$productId');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                ApiConstants.resolveImageUrl(productImage)),
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
                  final realMessages = _chatCtrl.currentMessages;
                  final pending = _chatCtrl.pendingMessages;
                  final totalCount = realMessages.length + pending.length;

                  return ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: totalCount,
                    itemBuilder: (_, i) {
                      final session = _chatCtrl.currentChatSession.value;
                      final itemMyUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
                      final otherAvatar =
                          session?.otherParticipantAvatar(itemMyUid) ?? '';

                      // Pending messages appear first (index 0..pending.length-1) since list is reversed
                      if (i < pending.length) {
                        final pm = pending[pending.length - 1 - i];
                        return _PendingMessageBubble(
                          pending: pm,
                          onRetry: () {
                            final convId = _convId;
                            final retryMyUid = '${_isActingAsBoutique ? 'shop' : 'user'}_$myId';
                            String receiverId = '';
                            String retryReceiverEntityType = 'user';
                            if (session != null) {
                              final receiverUid = session.otherParticipantUid(retryMyUid);
                              final parts = receiverUid.split('_');
                              if (parts.length >= 2) {
                                retryReceiverEntityType = parts[0];
                                receiverId = parts.sublist(1).join('_');
                              }
                            }
                            if (pm.type == 'image' && pm.originalFile != null) {
                              _chatCtrl.uploadAndSendImage(
                                convId,
                                myId,
                                _isActingAsBoutique ? 'shop' : 'user',
                                receiverId,
                                retryReceiverEntityType,
                                pm.originalFile!,
                                pm.content,
                                _isActingAsBoutique,
                                existing: pm,
                              );
                            } else if (pm.type == 'voice' &&
                                pm.originalFile != null) {
                              _chatCtrl.uploadAndSendVoiceNote(
                                convId,
                                myId,
                                _isActingAsBoutique ? 'shop' : 'user',
                                receiverId,
                                retryReceiverEntityType,
                                pm.originalFile!,
                                pm.mediaDuration ?? 1,
                                _isActingAsBoutique,
                                existing: pm,
                              );
                            }
                          },
                        );
                      }

                      final realIdx = i - pending.length;
                      final msg = realMessages[realIdx];
                      return _MessageBubble(
                          message: msg,
                          sellerAvatar: otherAvatar,
                          isMe: msg.senderEntityId == myId);
                    },
                  );
                }),
              ),
              // Quick replies
              Obx(() {
                if (_chatCtrl.currentMessages.isNotEmpty)
                  return const SizedBox.shrink();
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
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
                    if (_recordState == VoiceRecordState.none)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _showAttachMenu,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(right: 12, bottom: 12),
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
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                minLines: 1,
                                maxLines: 5,
                                onChanged: (val) {
                                  setState(() {});
                                },
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
                          const SizedBox(width: 8),
                          if (_isUploading)
                            Container(
                              width: r.s(48),
                              height: r.s(48),
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else if (_msgCtrl.text.trim().isEmpty)
                            GestureDetector(
                              onTap: _startRecording,
                              child: Container(
                                width: r.s(48),
                                height: r.s(48),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.shadowPrimary,
                                ),
                                child: const Icon(Icons.mic,
                                    color: Colors.white, size: 20),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => _send(),
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
                      )
                    else if (_recordState == VoiceRecordState.recording ||
                        _recordState == VoiceRecordState.paused)
                      Row(
                        children: [
                          // Trash / Cancel
                          GestureDetector(
                            onTap: _cancelRecording,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 24),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Animated pulse wave / Record State
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  // Pulsing indicator
                                  if (_recordState ==
                                      VoiceRecordState.recording)
                                    const _RecordingWaveform()
                                  else
                                    const Icon(Icons.pause,
                                        color: Colors.grey, size: 16),
                                  const SizedBox(width: 12),
                                  // Recording duration
                                  Text(
                                    _formatTimer(_recordDuration),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Pause / Resume Button
                          GestureDetector(
                            onTap: _recordState == VoiceRecordState.recording
                                ? _pauseRecording
                                : _resumeRecording,
                            child: Container(
                              width: r.s(40),
                              height: r.s(40),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Icon(
                                _recordState == VoiceRecordState.recording
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Stop & Preview Button
                          GestureDetector(
                            onTap: _stopAndPreviewRecording,
                            child: Container(
                              width: r.s(48),
                              height: r.s(48),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.shadowPrimary,
                              ),
                              child: const Icon(Icons.stop,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    else if (_recordState == VoiceRecordState.preview)
                      Row(
                        children: [
                          // Discard / Trash
                          GestureDetector(
                            onTap: _deletePreview,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 24),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Player preview
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.muted,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _playPreview,
                                    child: Icon(
                                      _isPreviewPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: AppTheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3.0,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 5.0),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                                overlayRadius: 10.0),
                                        activeTrackColor: AppTheme.primary,
                                        inactiveTrackColor: AppTheme.border,
                                        thumbColor: AppTheme.primary,
                                      ),
                                      child: Slider(
                                        value: _previewPosition.inMilliseconds
                                            .toDouble()
                                            .clamp(
                                                0.0,
                                                _previewDuration.inMilliseconds
                                                    .toDouble()),
                                        min: 0.0,
                                        max: _previewDuration.inMilliseconds
                                                    .toDouble() >
                                                0
                                            ? _previewDuration.inMilliseconds
                                                .toDouble()
                                            : 1.0,
                                        onChanged: (val) {
                                          _previewPlayer.seek(Duration(
                                              milliseconds: val.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTimer(_previewDuration.inSeconds),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Confirm Send Button
                          GestureDetector(
                            onTap: _sendVoiceNote,
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
        ));
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final String sellerAvatar;
  final bool isMe;

  const _MessageBubble(
      {required this.message, required this.sellerAvatar, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final msgType = message.type ?? 'text';

    // ── Type 'order' : même structure que les bulles normales ──────────
    if (msgType == 'order') {
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
                    ? CachedNetworkImageProvider(
                        ApiConstants.resolveImageUrl(sellerAvatar))
                    : null,
                child: sellerAvatar.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            _OrderRecapBubble(
              content: message.content as String,
              isMe: isMe,
              timestamp: message.timestamp,
              seen: message.seen ?? false,
            ),
          ],
        ),
      );
    }

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
                  ? CachedNetworkImageProvider(
                      ApiConstants.resolveImageUrl(sellerAvatar))
                  : null,
              child: sellerAvatar.isEmpty ? Icon(Icons.person, size: 16) : null,
            ),
            SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: (msgType == 'image' || msgType == 'location')
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

                // ── Location ──
                if (msgType == 'location' && message.mediaUrl != null)
                  _LocationCardInBubble(
                    coordsString: message.mediaUrl!,
                    address: message.content as String,
                    isMe: isMe,
                  ),

                // ── Image ──
                if (msgType == 'image' && message.mediaUrl != null)
                  _DownloadableMediaWidget(
                    url: message.mediaUrl!,
                    isMe: isMe,
                    child: GestureDetector(
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
                            child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 100,
                            color: AppTheme.muted,
                            child: Icon(Icons.broken_image,
                                color: AppTheme.mutedForeground),
                          ),
                        ),
                      ),
                    ),
                  ),
                // ── Voice ──
                if (msgType == 'voice' && message.mediaUrl != null)
                  _DownloadableMediaWidget(
                    url: message.mediaUrl!,
                    isMe: isMe,
                    child: _VoicePlayerWidget(
                      url: message.mediaUrl!,
                      duration: message.mediaDuration ?? 0,
                      isMe: isMe,
                    ),
                  ),
                // ── Text / Caption ──
                if ((msgType == 'text' || msgType == 'image') &&
                    (message.content as String).isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: msgType == 'image' || message.productId != null
                            ? r.s(8)
                            : 0),
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
                  padding: (msgType == 'image' || msgType == 'location')
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 2)
                      : EdgeInsets.zero,
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
                          color: message.seen
                              ? Colors.blueAccent
                              : Colors.white.withOpacity(0.7),
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

// ── Location Card inside a chat bubble ──────────────────────────────────────────
class _LocationCardInBubble extends StatelessWidget {
  final String coordsString;
  final String address;
  final bool isMe;

  const _LocationCardInBubble({
    required this.coordsString,
    required this.address,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final parts = coordsString.split(',');
    if (parts.length != 2) {
      return Text('📍 $address',
          style: TextStyle(color: isMe ? Colors.white : AppTheme.foreground));
    }
    final lat = double.tryParse(parts[0].trim()) ?? 0;
    final lon = double.tryParse(parts[1].trim()) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini map
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140,
            width: MediaQuery.of(context).size.width * 0.6,
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(flags: 0),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.togo.market',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 30,
                        height: 30,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Adresse
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.pin_drop,
                  size: 14,
                  color: isMe ? Colors.white70 : AppTheme.mutedForeground),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address.isNotEmpty ? address : 'Position partagée',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white : AppTheme.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Bouton "Voir sur la carte"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {
              Get.to(() => UnifiedMapScreen(
                    viewMode: true,
                    initialLat: lat,
                    initialLon: lon,
                    initialAddress:
                        address.isNotEmpty ? address : 'Position partagée',
                  ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new,
                      size: 13, color: isMe ? Colors.white : AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('Voir sur la carte',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isMe ? Colors.white : AppTheme.primary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Manual Download Overlay ────────────────────────────────────────────────────
class _DownloadableMediaWidget extends StatefulWidget {
  final String url;
  final bool isMe;
  final Widget child;

  const _DownloadableMediaWidget({
    required this.url,
    required this.isMe,
    required this.child,
  });

  @override
  State<_DownloadableMediaWidget> createState() =>
      _DownloadableMediaWidgetState();
}

class _DownloadableMediaWidgetState extends State<_DownloadableMediaWidget> {
  bool _isDownloaded = true;

  @override
  void initState() {
    super.initState();
    // For sent messages (isMe), always show content directly
    if (!widget.isMe) {
      _isDownloaded = ChatMediaCacheManager.isDownloaded(widget.url);
    }
  }

  void _download() async {
    await ChatMediaCacheManager.markAsDownloaded(widget.url);
    if (mounted) {
      setState(() => _isDownloaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMe || _isDownloaded) {
      return widget.child;
    }

    // Placeholder with download button
    return GestureDetector(
      onTap: _download,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.muted.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download_rounded,
                  color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 10),
            Text('Appuyer pour télécharger',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Pending Message Bubble (Optimistic UI) ──────────────────────────────────────
class _PendingMessageBubble extends StatelessWidget {
  final PendingMessage pending;
  final VoidCallback onRetry;

  const _PendingMessageBubble({required this.pending, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Obx(() {
              final status = pending.status.value;
              final progress = pending.progress.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image preview
                  if (pending.type == 'image' && pending.localFilePath != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(pending.localFilePath!),
                            width: MediaQuery.of(context).size.width * 0.6,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 100,
                              color: AppTheme.muted,
                              child: Icon(Icons.broken_image,
                                  color: AppTheme.mutedForeground),
                            ),
                          ),
                        ),
                        // Upload overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: status == 'error'
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.35),
                              child: Center(
                                child: status == 'error'
                                    ? GestureDetector(
                                        onTap: onRetry,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.refresh,
                                                  color: Colors.red, size: 18),
                                              const SizedBox(width: 6),
                                              Text('Réessayer',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: CircularProgressIndicator(
                                          value: progress > 0 ? progress : null,
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Voice pending
                  if (pending.type == 'voice')
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('🎤 Vocal',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13)),
                          const SizedBox(width: 8),
                          if (status == 'sending')
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  value: progress > 0 ? progress : null),
                            ),
                          if (status == 'error')
                            GestureDetector(
                              onTap: onRetry,
                              child: Icon(Icons.refresh,
                                  color: Colors.white70, size: 20),
                            ),
                        ],
                      ),
                    ),
                  // Caption
                  if (pending.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
                      child: Text(pending.content,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white)),
                    ),
                  // Time + status
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pending.timestamp.hour.toString().padLeft(2, '0')}:${pending.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(width: 4),
                        if (status == 'sending')
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                color: Colors.white.withOpacity(0.7),
                                strokeWidth: 1.5),
                          ),
                        if (status == 'error')
                          Icon(Icons.error_outline,
                              color: Colors.red.shade200, size: 14),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Card récapitulatif commande dans le chat ───────────────────────────────────
class _OrderRecapBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final bool seen;

  const _OrderRecapBubble({
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.seen = false,
  });

  Map<String, String> _parseOrder() {
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Widget _row(IconData icon, String label, String value,
      {Color? valueColor,
      bool bold = false,
      Color? iconColor,
      Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor ?? Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12, color: textColor ?? Colors.white70)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider({Color? color}) => Divider(
      height: 1, thickness: 0.4, color: color ?? Colors.white.withOpacity(0.2));

  @override
  Widget build(BuildContext context) {
    final data = _parseOrder();
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(content,
            style: TextStyle(fontSize: 13, color: AppTheme.foreground)),
      );
    }

    final orderId = data['order_id'] ?? '-';
    final date = data['date'] ?? '';
    final productTitle = data['product_title'] ?? '';
    final productImage = data['product_image'] ?? '';
    final quantity = data['quantity'] ?? '1';
    final total = data['total'] ?? '';
    final mode = data['mode'] ?? '';
    final address = data['address'] ?? '';
    final payment = data['payment'] ?? '';
    final phone = data['phone'] ?? '';
    final note = data['note'] ?? '';
    final status = data['status'] ?? 'En attente';

    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    // Couleurs adaptées selon l'expéditeur
    final bgGradient = isMe
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.75)],
          )
        : null;
    final bgColor = isMe ? null : AppTheme.cardColor;
    final textPrimaryColor = isMe ? Colors.white : AppTheme.foreground;
    final textSecondaryColor = isMe ? Colors.white70 : AppTheme.mutedForeground;
    final dividerColor =
        isMe ? Colors.white.withOpacity(0.2) : AppTheme.border.withOpacity(0.5);
    final iconColor = isMe ? Colors.white70 : AppTheme.mutedForeground;
    final totalColor = isMe ? Colors.yellow.shade200 : AppTheme.primary;
    final timestampColor = isMe ? Colors.white54 : AppTheme.mutedForeground;
    final shadowColor = isMe
        ? AppTheme.primary.withOpacity(0.3)
        : Colors.black.withOpacity(0.06);
    final imageOverlayColor = isMe
        ? AppTheme.primary.withOpacity(0.9)
        : Colors.black.withOpacity(0.55);

    return GestureDetector(
      onTap: () {
        Get.toNamed('/order-details', arguments: {
          'orderId': '#$orderId',
          'title': productTitle,
          'price': total,
          'status': status,
          'image': productImage.isNotEmpty
              ? ApiConstants.resolveImageUrl(productImage)
              : '',
          'date': date,
          'isSale': !isMe,
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        decoration: BoxDecoration(
          gradient: bgGradient,
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border:
              isMe ? null : Border.all(color: AppTheme.border.withOpacity(0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header image + titre ────────────────────────────────────────
            if (productImage.isNotEmpty)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: ApiConstants.resolveImageUrl(productImage),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: isMe ? Colors.white12 : AppTheme.muted),
                      errorWidget: (_, __, ___) => Container(
                        color: isMe ? Colors.white12 : AppTheme.muted,
                        child: Icon(Icons.image_not_supported,
                            color: iconColor, size: 36),
                      ),
                    ),
                    // Gradient par-dessus l'image
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, imageOverlayColor],
                        ),
                      ),
                    ),
                    // Badge statut
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hourglass_top_outlined,
                                size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(status,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    // Titre commande en bas de l'image
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commande #$orderId',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            productTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: textPrimaryColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Commande #$orderId',
                        style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),

            // ── Lignes de détails ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Column(
                children: [
                  if (date.isNotEmpty) ...[
                    _row(Icons.calendar_today_outlined, 'Date', date,
                        iconColor: iconColor,
                        textColor: textSecondaryColor,
                        valueColor: textPrimaryColor),
                    _divider(color: dividerColor),
                  ],
                  _row(Icons.numbers_outlined, 'Quantité', quantity,
                      iconColor: iconColor,
                      textColor: textSecondaryColor,
                      valueColor: textPrimaryColor),
                  _divider(color: dividerColor),
                  _row(Icons.payments_outlined, 'Total', total,
                      iconColor: iconColor,
                      textColor: textSecondaryColor,
                      valueColor: totalColor,
                      bold: true),
                  _divider(color: dividerColor),
                  _row(Icons.local_shipping_outlined, 'Livraison', mode,
                      iconColor: iconColor,
                      textColor: textSecondaryColor,
                      valueColor: textPrimaryColor),
                  if (address.isNotEmpty) ...[
                    _divider(color: dividerColor),
                    _row(Icons.location_on_outlined, 'Adresse', address,
                        iconColor: iconColor,
                        textColor: textSecondaryColor,
                        valueColor: textPrimaryColor),
                  ],
                  _divider(color: dividerColor),
                  _row(Icons.credit_card_outlined, 'Paiement', payment,
                      iconColor: iconColor,
                      textColor: textSecondaryColor,
                      valueColor: textPrimaryColor),
                  _divider(color: dividerColor),
                  _row(Icons.phone_outlined, 'Téléphone', phone,
                      iconColor: iconColor,
                      textColor: textSecondaryColor,
                      valueColor: textPrimaryColor),
                  if (note.isNotEmpty) ...[
                    _divider(color: dividerColor),
                    _row(Icons.notes_outlined, 'Note', note,
                        iconColor: iconColor,
                        textColor: textSecondaryColor,
                        valueColor: textPrimaryColor),
                  ],
                ],
              ),
            ),

            // ── Indicateur "appuyer pour voir" ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 12, color: textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Appuyez pour voir les détails',
                    style: TextStyle(
                        fontSize: 10,
                        color: textSecondaryColor,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // ── Timestamp + coche ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(timeStr,
                      style: TextStyle(fontSize: 10, color: timestampColor)),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      seen ? Icons.done_all : Icons.check,
                      size: 13,
                      color: seen ? Colors.blueAccent : timestampColor,
                    ),
                  ],
                ],
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

  const _AttachOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

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
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foreground)),
        ],
      ),
    );
  }
}

class _WaveformProgressBar extends StatelessWidget {
  final double progress; // 0.0 à 1.0
  final Color activeColor;
  final Color inactiveColor;
  final Function(double) onSeek;

  // Pré-calcul des hauteurs d'ondes pour une superbe signature visuelle
  static const List<double> _waveHeights = [
    8,
    14,
    10,
    20,
    26,
    14,
    18,
    12,
    22,
    28,
    16,
    22,
    10,
    26,
    32,
    16,
    24,
    12,
    18,
    26,
    14,
    22,
    8,
    18,
    24,
    14,
    20,
    10,
    16,
    12
  ];

  const _WaveformProgressBar({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final percent = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(percent);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final percent = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(percent);
      },
      child: Container(
        height: 36,
        color: Colors.transparent, // Étend la zone cliquable
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_waveHeights.length, (index) {
            final barPercent = index / _waveHeights.length;
            final isActive = progress >= barPercent;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                height: _waveHeights[index],
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _VoicePlayerWidget extends StatefulWidget {
  final String url;
  final int duration;
  final bool isMe;

  const _VoicePlayerWidget(
      {required this.url, required this.duration, required this.isMe});

  @override
  State<_VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<_VoicePlayerWidget> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
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
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isLoading = (state == PlayerState.playing &&
              _position == Duration.zero &&
              _totalDuration == Duration.zero);
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        setState(() => _isLoading = true);
        if (_position.inSeconds == 0) {
          await _player.play(UrlSource(widget.url));
        } else {
          await _player.resume();
        }
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      debugPrint('Error playing audio: $e');
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

    final activeColor = widget.isMe ? Colors.white : AppTheme.primary;
    final inactiveColor = widget.isMe
        ? Colors.white.withOpacity(0.3)
        : AppTheme.mutedForeground.withOpacity(0.4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.2)
                  : AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                          widget.isMe ? Colors.white : AppTheme.primary),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24,
                    color: widget.isMe ? Colors.white : AppTheme.primary,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WaveformProgressBar(
                progress: progress,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onSeek: (percent) {
                  final targetMs =
                      (percent * _totalDuration.inMilliseconds).toInt();
                  _player.seek(Duration(milliseconds: targetMs));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.7)
                            : AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: widget.isMe
                            ? Colors.white.withOpacity(0.7)
                            : AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordingWaveform extends StatefulWidget {
  const _RecordingWaveform();

  @override
  State<_RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<_RecordingWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value =
                (sin((_controller.value * 2 * pi) + (index * 1.0)) + 1) / 2;
            final double height = 4.0 + (value * 20.0);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
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
              backgroundImage: CachedNetworkImageProvider(
                  ApiConstants.resolveImageUrl(seller.avatar as String)),
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
                child: Icon(Icons.image_not_supported,
                    size: r.s(16), color: AppTheme.mutedForeground),
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
    final appCtrl =
        Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
    final product = appCtrl?.products
            .firstWhereOrNull((p) => p.id.toString() == productId) ??
        getProductById(productId);
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
                  child: Icon(Icons.image_not_supported,
                      size: r.s(30), color: AppTheme.mutedForeground),
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
                      formatPrice(product.price),
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
