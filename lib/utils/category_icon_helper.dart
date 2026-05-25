import 'package:flutter/material.dart';

class CategoryIconHelper {
  /// Map of string icon names to Flutter Icons
  static const Map<String, IconData> _stringToIcon = {
    'checkroom': Icons.checkroom_rounded,
    'smartphone': Icons.smartphone_rounded,
    'computer': Icons.computer_rounded,
    'chair': Icons.chair_rounded,
    'bed': Icons.bed_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
    'stroller': Icons.child_friendly_rounded,
    'directions_car': Icons.directions_car_rounded,
    'handyman': Icons.handyman_rounded,
    'business_center': Icons.business_center_rounded,
    'sports_soccer': Icons.sports_soccer_rounded,
    'menu_book': Icons.menu_book_rounded,
    'agriculture': Icons.agriculture_rounded,
    'pets': Icons.pets_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
  };

  /// Returns the corresponding icon for a given category icon string.
  /// If [iconString] is null or not found, returns a generic category icon.
  static IconData getIconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.category_rounded;
    }
    
    if (_stringToIcon.containsKey(iconString)) {
      return _stringToIcon[iconString]!;
    }
    
    return Icons.label_outline_rounded;
  }
}
