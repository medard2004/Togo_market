import 'package:dio/dio.dart';

class LocationService {
  static final Dio _dio = Dio();

  /// Renvoie un Map avec 'ville' et 'quartier' depuis les coordonnées GPS
  static Future<Map<String, String>?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'com.togomarket.app/1.0',
            'Accept-Language': 'fr-FR,fr;q=0.9',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Extraire la ville (peut varier selon les données OSM)
          String? ville = address['city'] ?? 
                          address['town'] ?? 
                          address['village'] ?? 
                          address['county'] ?? 
                          address['state'];
                          
          // Extraire le quartier ou la rue
          String? quartier = address['suburb'] ?? 
                             address['neighbourhood'] ?? 
                             address['residential'] ?? 
                             address['road'] ?? 
                             address['village'];

          return {
            'ville': ville ?? '',
            'quartier': quartier ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      print('Erreur reverse geocoding Nominatim: $e');
      return null;
    }
  }
}
