import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../Api/provider/auth_controller.dart';
import '../Api/core/api_client.dart';

class SearchQuery {
  final int? id;
  final String query;

  SearchQuery({this.id, required this.query});

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      id: json['id'],
      query: json['query'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
    };
  }
}

class SearchHistoryController extends GetxController {
  static SearchHistoryController get to => Get.find();

  final RxList<SearchQuery> searches = <SearchQuery>[].obs;
  final String _storageKey = 'recent_searches_local';
  static const int _maxHistory = 15;

  late SharedPreferences _prefs;
  final AuthController _authCtrl = Get.find<AuthController>();
  final ApiClient _api = Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSearches();

    // Listen to auth changes to sync or clear
    ever(_authCtrl.currentUser, (user) {
      if (user != null) {
        syncLocalToServer();
      }
    });
  }

  String _normalize(String q) => q.trim().toLowerCase();

  Future<void> loadSearches() async {
    // 1. Charger depuis le local (toujours très rapide)
    final String? localData = _prefs.getString(_storageKey);
    if (localData != null && localData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(localData);
        searches.value = decoded.map((e) => SearchQuery.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Erreur décodage historique local: $e');
      }
    }

    // 2. Si connecté, charger depuis l'API pour être à jour
    if (_authCtrl.isAuthenticated) {
      try {
        final response = await _api.get('/search-history');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final List<SearchQuery> remoteSearches = data.map((e) => SearchQuery.fromJson(e)).toList();
          searches.value = remoteSearches;
          _saveToLocal(); // Mettre à jour le cache local
        }
      } catch (e) {
        debugPrint('Erreur chargement historique distant: $e');
      }
    }
  }

  Future<void> addSearch(String queryText) async {
    final q = _normalize(queryText);
    if (q.isEmpty) return;

    // Optimistic UI update
    searches.removeWhere((item) => _normalize(item.query) == q);
    searches.insert(0, SearchQuery(query: q));

    if (searches.length > _maxHistory) {
      searches.removeLast();
    }
    await _saveToLocal();

    // Appeler l'API en arrière-plan si connecté
    if (_authCtrl.isAuthenticated) {
      try {
        final response = await _api.post('/search-history', data: {'query': q});
        if (response.statusCode == 200 || response.statusCode == 201) {
          // On met à jour l'ID avec celui retourné par le serveur
          final serverData = SearchQuery.fromJson(response.data);
          final index = searches.indexWhere((item) => _normalize(item.query) == q);
          if (index != -1) {
            searches[index] = serverData;
            await _saveToLocal();
          }
        }
      } catch (e) {
        debugPrint('Erreur ajout recherche distante: $e');
      }
    }
  }

  Future<void> removeSearch(SearchQuery sq) async {
    final q = _normalize(sq.query);
    searches.removeWhere((item) => _normalize(item.query) == q);
    await _saveToLocal();

    if (_authCtrl.isAuthenticated && sq.id != null) {
      try {
        await _api.delete('/search-history/${sq.id}');
      } catch (e) {
        debugPrint('Erreur suppression recherche distante: $e');
      }
    }
  }

  Future<void> clearSearches() async {
    searches.clear();
    await _prefs.remove(_storageKey);

    if (_authCtrl.isAuthenticated) {
      try {
        await _api.delete('/search-history/all');
      } catch (e) {
        debugPrint('Erreur suppression totale distante: $e');
      }
    }
  }

  Future<void> syncLocalToServer() async {
    final List<String> localQueries = searches.map((e) => e.query).toList();
    if (localQueries.isEmpty) {
      // S'il n'y a rien en local, on charge juste le distant
      await loadSearches();
      return;
    }

    try {
      final response = await _api.post('/search-history/sync', data: {
        'queries': localQueries,
      });

      if (response.statusCode == 200) {
        // Une fois synchronisé, on recharge la liste depuis le serveur pour avoir les IDs corrects
        await loadSearches();
      }
    } catch (e) {
      debugPrint('Erreur synchronisation historique: $e');
    }
  }

  Future<void> _saveToLocal() async {
    final String encoded = jsonEncode(searches.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}
