import 'package:flutter/material.dart';

class CategoryIconHelper {
  /// Map of category slugs to Flutter Icons
  static const Map<String, IconData> _slugToIcon = {
    // Parent categories
    'electronique': Icons.computer_rounded,
    'mode': Icons.checkroom_rounded,
    'alimentation': Icons.fastfood_rounded,
    'maison': Icons.home_rounded,
    'vehicules': Icons.directions_car_rounded,
    'services': Icons.build_rounded,
    'immobilier': Icons.apartment_rounded,
    'loisirs': Icons.sports_esports_rounded,
    'sante-beaute': Icons.health_and_safety_rounded,
    'emploi': Icons.work_rounded,
    'tout': Icons.apps_rounded, // special 'all' category
    
    // Sub categories
    'telephones': Icons.phone_android_rounded,
    'ordinateurs': Icons.laptop_mac_rounded,
    'accessoires-electroniques': Icons.headphones_rounded,
    'hommes': Icons.man_rounded,
    'femmes': Icons.woman_rounded,
    'enfants': Icons.child_care_rounded,
    'meubles': Icons.chair_rounded,
    'electromenager': Icons.kitchen_rounded,
    'voitures': Icons.directions_car_filled_rounded,
    'motos': Icons.motorcycle_rounded,
    'pieces-auto': Icons.settings_rounded,
  };

  /// Returns the corresponding icon for a given category slug.
  /// If [slug] is null or not found, returns a generic category icon.
  static IconData getIcon(String? slug) {
    if (slug == null || slug.isEmpty) {
      return Icons.category_rounded;
    }
    
    final lowerSlug = slug.toLowerCase();
    if (_slugToIcon.containsKey(lowerSlug)) {
      return _slugToIcon[lowerSlug]!;
    }
    
    // Fallback based on partial string matching
    if (lowerSlug.contains('phone') || lowerSlug.contains('téléphone')) return Icons.phone_android_rounded;
    if (lowerSlug.contains('ordi') || lowerSlug.contains('laptop')) return Icons.laptop_mac_rounded;
    if (lowerSlug.contains('vet') || lowerSlug.contains('vêtement')) return Icons.checkroom_rounded;
    if (lowerSlug.contains('auto') || lowerSlug.contains('voi')) return Icons.directions_car_rounded;
    if (lowerSlug.contains('mai') || lowerSlug.contains('déco')) return Icons.home_rounded;
    if (lowerSlug.contains('ali') || lowerSlug.contains('nour')) return Icons.fastfood_rounded;
    if (lowerSlug.contains('sant') || lowerSlug.contains('beau')) return Icons.spa_rounded;
    
    return Icons.label_outline_rounded;
  }
}
