import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageOptimizationService {
  /// Taille cible maximale de l'image (par défaut 1 Mo pour rester très léger).
  static const int targetFileSize = 1 * 1024 * 1024; // 1 MB
  
  /// Dimensions maximales de l'image (pour réduire la résolution des photos 12MP/4K).
  static const int maxDimension = 1280;

  /// Compresse une image et retourne le fichier optimisé de manière asynchrone.
  static Future<File> optimizeImage(File file, {int maxBytes = targetFileSize}) async {
    try {
      final originalSize = await file.length();
      debugPrint('📸 [ImageOptimization] Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Si l'image est déjà très petite, on peut la retourner directement
      // Mais pour garantir une uniformité (conversion HEIC -> JPEG ou resizing), on force au moins un passage.

      final dir = await getTemporaryDirectory();
      
      // Essai 1 : Qualité haute avec redimensionnement intelligent
      int quality = 85;
      File? optimizedFile = await _compress(file, dir, quality);

      if (optimizedFile == null) return file; // Fallback original si échec total

      int optimizedSize = await optimizedFile.length();
      debugPrint('📸 [ImageOptimization] Pass 1 size: ${(optimizedSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Boucle de compression plus agressive si l'image est encore trop lourde
      while (optimizedSize > maxBytes && quality > 30) {
        quality -= 15; // 70 -> 55 -> 40
        final candidate = await _compress(file, dir, quality);
        
        if (candidate != null) {
          optimizedFile = candidate;
          optimizedSize = await optimizedFile.length();
          debugPrint('📸 [ImageOptimization] Pass (Quality $quality) size: ${(optimizedSize / 1024 / 1024).toStringAsFixed(2)} MB');
        } else {
          break; // Échec inattendu, on sort de la boucle
        }
      }

      return optimizedFile ?? file;
    } catch (e) {
      debugPrint('❌ [ImageOptimization] Failed to optimize image: $e');
      return file; // Si l'optimisation échoue, on retourne l'image originale pour ne pas bloquer
    }
  }

  static Future<File?> _compress(File source, Directory tempDir, int quality) async {
    // Générer un chemin unique pour le résultat (forçons le jpeg)
    final targetPath = '${tempDir.absolute.path}/opt_${DateTime.now().millisecondsSinceEpoch}_$quality.jpg';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      targetPath,
      quality: quality,
      minWidth: maxDimension,
      minHeight: maxDimension,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }
}
