import 'package:intl/intl.dart';

String formatPrice(double price) {
  final formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );
  // Le locale fr_FR utilise parfois un espace normal ou un espace insécable,
  // remplaçons explicitement les séparateurs par un espace normal pour éviter des soucis d'affichage.
  return formatter.format(price).replaceAll('\u202F', ' ').replaceAll('\u00A0', ' ').trim();
}

// Add more shared utilities as needed
