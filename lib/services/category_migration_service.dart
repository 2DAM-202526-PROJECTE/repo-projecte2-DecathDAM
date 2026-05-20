import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Servei de migració per convertir el camp antic 'categoria' (String)
/// dels productes al nou camp 'categoriaId' (referència a la col·lecció categories).
///
/// Procés:
/// 1. Llegeix tots els productes que tenen el camp 'categoria' (String)
/// 2. Per cada categoria única trobada, busca o crea l'entrada a la col·lecció 'categories'
/// 3. Actualitza cada producte amb el 'categoriaId' corresponent
/// 4. Elimina el camp antic 'categoria' del producte
class CategoryMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Executa la migració completa. Retorna un resum del procés.
  Future<MigrationResult> migrateCategories() async {
    int productsUpdated = 0;
    int categoriesCreated = 0;
    int skipped = 0;
    final List<String> errors = [];

    try {
      // 1. Obtenim tots els productes
      final productsSnapshot =
          await _firestore.collection('productes').get();

      // 2. Recollim totes les categories úniques dels productes antics
      final Map<String, String> categoryNameToId = {};

      // Primer, carreguem les categories que ja existeixen a Firestore
      final existingCategoriesSnapshot =
          await _firestore.collection('categories').get();
      for (final doc in existingCategoriesSnapshot.docs) {
        final nom = doc.data()['nom'] as String? ?? '';
        if (nom.isNotEmpty) {
          categoryNameToId[nom] = doc.id;
        }
      }

      // 3. Determinem l'ordre més alt per les noves categories
      int maxOrdre = 0;
      for (final doc in existingCategoriesSnapshot.docs) {
        final ordre = doc.data()['ordre'] as int? ?? 0;
        if (ordre > maxOrdre) maxOrdre = ordre;
      }

      // 4. Processem cada producte
      for (final doc in productsSnapshot.docs) {
        final data = doc.data();

        // Comprovem si el producte ja té categoriaId (ja migrat)
        if (data.containsKey('categoriaId') &&
            (data['categoriaId'] as String? ?? '').isNotEmpty) {
          skipped++;
          // Si encara té el camp antic, l'eliminem
          if (data.containsKey('categoria')) {
            await doc.reference.update({
              'categoria': FieldValue.delete(),
            });
          }
          continue;
        }

        // Obtenim el valor antic de 'categoria'
        final String categoriaAntica = data['categoria'] as String? ?? '';

        if (categoriaAntica.isEmpty) {
          skipped++;
          continue;
        }

        // Busquem o creem la categoria
        String categoryId;
        if (categoryNameToId.containsKey(categoriaAntica)) {
          categoryId = categoryNameToId[categoriaAntica]!;
        } else {
          // Creem la categoria nova
          maxOrdre++;
          final newCatDoc = await _firestore.collection('categories').add({
            'nom': categoriaAntica,
            'ordre': maxOrdre,
          });
          categoryId = newCatDoc.id;
          categoryNameToId[categoriaAntica] = categoryId;
          categoriesCreated++;
          debugPrint(
              'Migració: Creada categoria "$categoriaAntica" amb ID: $categoryId');
        }

        // Actualitzem el producte: afegim categoriaId i eliminem categoria
        try {
          await doc.reference.update({
            'categoriaId': categoryId,
            'categoria': FieldValue.delete(),
          });
          productsUpdated++;
          debugPrint(
              'Migració: Producte "${data['nom']}" → categoria "$categoriaAntica" (ID: $categoryId)');
        } catch (e) {
          errors.add('Error migrant "${data['nom']}": $e');
          debugPrint('Migració ERROR: ${errors.last}');
        }
      }
    } catch (e) {
      errors.add('Error general de migració: $e');
      debugPrint('Migració ERROR GENERAL: $e');
    }

    return MigrationResult(
      productsUpdated: productsUpdated,
      categoriesCreated: categoriesCreated,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Comprova quants productes necessiten migrar-se (tenen 'categoria' però no 'categoriaId').
  Future<int> countPendingMigrations() async {
    final snapshot = await _firestore.collection('productes').get();
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final hasCategoriaId = data.containsKey('categoriaId') &&
          (data['categoriaId'] as String? ?? '').isNotEmpty;
      final hasOldCategoria = data.containsKey('categoria') &&
          (data['categoria'] as String? ?? '').isNotEmpty;

      if (!hasCategoriaId && hasOldCategoria) {
        count++;
      }
    }
    return count;
  }
}

/// Resultat de la migració amb estadístiques.
class MigrationResult {
  final int productsUpdated;
  final int categoriesCreated;
  final int skipped;
  final List<String> errors;

  MigrationResult({
    required this.productsUpdated,
    required this.categoriesCreated,
    required this.skipped,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => !hasErrors;
  int get totalProcessed => productsUpdated + skipped;
}
