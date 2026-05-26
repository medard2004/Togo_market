import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../utils/location_service.dart';

class UnifiedMapScreen extends StatefulWidget {
  final bool viewMode;
  final double? initialLat;
  final double? initialLon;
  final String? initialAddress;

  const UnifiedMapScreen({
    super.key,
    this.viewMode = false,
    this.initialLat,
    this.initialLon,
    this.initialAddress,
  });

  @override
  State<UnifiedMapScreen> createState() => _UnifiedMapScreenState();
}

class _UnifiedMapScreenState extends State<UnifiedMapScreen> {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  String _address = 'Recherche de l\'adresse...';
  bool _isLoadingAddress = false;
  bool _gpsLoading = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = (widget.initialLat != null && widget.initialLon != null)
        ? LatLng(widget.initialLat!, widget.initialLon!)
        : const LatLng(6.137, 1.212); // Lomé por défaut

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _address = widget.initialAddress!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.viewMode && widget.initialLat == null) {
          _requestGpsPosition(silent: true);
        } else {
          _reverseGeocode(_currentCenter);
        }
      });
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final res = await LocationService.reverseGeocode(point.latitude, point.longitude);
      if (!mounted) return;
      if (res != null) {
        final ville = res['ville'] ?? '';
        final quartier = res['quartier'] ?? '';
        setState(() {
          if (ville.isNotEmpty && quartier.isNotEmpty) {
            _address = '$quartier, $ville';
          } else {
            _address = ville.isNotEmpty ? ville : (quartier.isNotEmpty ? quartier : 'Adresse inconnue');
          }
        });
      } else {
        setState(() {
          _address = '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address = '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _requestGpsPosition({bool silent = false}) async {
    if (_gpsLoading) return;
    if (!mounted) return;
    setState(() {
      _gpsLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        if (!silent && mounted) {
          Get.snackbar('Erreur', 'Les services de localisation sont désactivés.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        setState(() => _gpsLoading = false);
        if (_address == 'Recherche de l\'adresse...') _reverseGeocode(_currentCenter);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          if (!silent && mounted) {
            Get.snackbar('Erreur', 'Permission GPS refusée.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
          }
          setState(() => _gpsLoading = false);
          if (_address == 'Recherche de l\'adresse...') _reverseGeocode(_currentCenter);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          Get.snackbar('Erreur', 'Les permissions GPS sont définitivement refusées.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        setState(() => _gpsLoading = false);
        if (_address == 'Recherche de l\'adresse...') _reverseGeocode(_currentCenter);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      if (!mounted) return;
      final newCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(newCenter, 16.0);
      setState(() {
        _currentCenter = newCenter;
        _gpsLoading = false;
      });
      _reverseGeocode(newCenter);
    } catch (e) {
      if (!mounted) return;
      if (!silent && mounted) {
        Get.snackbar('Erreur', 'Impossible de récupérer la position GPS.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      setState(() => _gpsLoading = false);
      if (_address == 'Recherche de l\'adresse...') _reverseGeocode(_currentCenter);
    }
  }

  void _openInGoogleMaps() {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${_currentCenter.latitude},${_currentCenter.longitude}');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Get.isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: Text(widget.viewMode ? 'Localisation' : 'Choisir une localisation', 
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Carte interactive
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onMapEvent: (event) {
                  if (!widget.viewMode && event is MapEventMoveEnd) {
                    final newCenter = event.camera.center;
                    if (mounted) {
                      setState(() {
                        _currentCenter = newCenter;
                      });
                      _reverseGeocode(newCenter);
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.togomarket.app',
                ),
                if (widget.viewMode)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentCenter,
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.location_on,
                          size: 44,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Épinglette de sélection centrale (Uber-like) - seulement en mode sélection
            if (!widget.viewMode)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35), // Aligne la pointe de l'épingle au centre exact
                  child: Icon(
                    Icons.location_on,
                    size: 44,
                    color: AppTheme.primary,
                  ),
                ),
              ),

            // Bouton Ma position flotant
            if (!widget.viewMode)
              Positioned(
                right: 16,
                bottom: 200,
                child: FloatingActionButton(
                  heroTag: 'gps_fab',
                  onPressed: () => _requestGpsPosition(),
                  backgroundColor: AppTheme.primary,
                  child: _gpsLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),

            // Panel inférieur d'adresse & confirmation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pin_drop, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Adresse',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingAddress)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            height: 1.4),
                      ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (widget.viewMode) {
                          _openInGoogleMaps();
                        } else {
                          // Retourne les données de localisation
                          Get.back(result: {
                            'latitude': _currentCenter.latitude,
                            'longitude': _currentCenter.longitude,
                            'address': _address,
                          });
                        }
                      },
                      child: Container(
                        height: 52,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.85)],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.viewMode ? 'Ouvrir dans Google Maps' : 'Valider cette position',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
