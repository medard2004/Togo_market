import 'package:shared_preferences/shared_preferences.dart';

class ChatMediaCacheManager {
  static const String _key = 'downloaded_chat_media_urls';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool isDownloaded(String url) {
    if (_prefs == null) return false;
    final list = _prefs!.getStringList(_key) ?? [];
    return list.contains(url);
  }

  static Future<void> markAsDownloaded(String url) async {
    await init();
    final list = _prefs!.getStringList(_key) ?? [];
    if (!list.contains(url)) {
      list.add(url);
      await _prefs!.setStringList(_key, list);
    }
  }
}
