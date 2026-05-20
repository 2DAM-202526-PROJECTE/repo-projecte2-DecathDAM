import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/repositories/category_repository.dart';
import 'package:decathdam/repositories/product_repository.dart';

class SeedService {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Categories per defecte amb els seus productes associats.
  final Map<String, List<Map<String, dynamic>>> _categoryProducts = {
    'Running': [
      {
        'nom': 'Zapatillas Trail Running',
        'descripcio': 'Zapatillas para correr por montaña con gran agarre y amortiguación.',
        'preu': 59.99,
        'url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nom': 'Camiseta Técnica Running',
        'descripcio': 'Camiseta transpirable y ligera para tus entrenamientos diarios.',
        'preu': 15.99,
        'url': 'https://images.unsplash.com/photo-1515555230216-820c39d439bb?auto=format&fit=crop&w=600&q=80',
      },
    ],
    'Ciclisme': [
      {
        'nom': 'Casco Bicicleta Carretera',
        'descripcio': 'Casco aerodinámico y ventilado para ciclistas exigentes.',
        'preu': 45.00,
        'url': 'https://images.unsplash.com/photo-1596733430284-f7437764b1a9?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nom': 'Bicicleta de Montaña Summit',
        'descripcio': 'MTB de aluminio con suspensión delantera y 21 velocidades.',
        'preu': 299.99,
        'url': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=600&q=80',
      },
    ],
    'Fitness': [
      {
        'nom': 'Mancuernas 5kg (Par)',
        'descripcio': 'Juego de dos mancuernas de 5kg con recubrimiento de neopreno.',
        'preu': 24.99,
        'url': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nom': 'Esterilla Yoga Confort',
        'descripcio': 'Esterilla antideslizante de 6mm de grosor para máxima comodidad.',
        'preu': 19.50,
        'url': 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?auto=format&fit=crop&w=600&q=80',
      },
    ],
    'Senderisme': [
      {
        'nom': 'Botas Trekking Impermeables',
        'descripcio': 'Botas de media caña resistentes al agua y con suela Vibram.',
        'preu': 79.99,
        'url': 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nom': 'Mochila Senderismo 20L',
        'descripcio': 'Mochila compacta y ergonómica ideal para rutas de un día.',
        'preu': 29.99,
        'url': 'https://images.unsplash.com/photo-1553062407-98eeb94c6a62?auto=format&fit=crop&w=600&q=80',
      },
    ],
    'Natació': [
      {
        'nom': 'Gafas de Natación Pro',
        'descripcio': 'Gafas con lentes espejadas y tratamiento antivaho de larga duración.',
        'preu': 12.99,
        'url': 'https://images.unsplash.com/photo-1600965962102-9d260a71890d?auto=format&fit=crop&w=600&q=80',
      },
    ],
    'Futbol': [
      {
        'nom': 'Balón de Fútbol Talla 5',
        'descripcio': 'Balón de alta resistencia para entrenamientos en césped artificial.',
        'preu': 14.99,
        'url': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=600&q=80',
      },
    ],
  };

  Future<void> seedProducts() async {
    int ordre = 0;
    
    for (final entry in _categoryProducts.entries) {
      final categoryName = entry.key;
      final products = entry.value;

      // Crea la categoria si no existeix
      final existingCategories = await _categoryRepository.fetchCategories();
      var categoryId = '';
      
      final existing = existingCategories.where((c) => c.nom == categoryName);
      if (existing.isNotEmpty) {
        categoryId = existing.first.id;
      } else {
        // Crear la categoria i obtenir el seu ID
        final docRef = await FirebaseFirestore.instance
            .collection('categories')
            .add({'nom': categoryName, 'ordre': ordre});
        categoryId = docRef.id;
        ordre++;
      }

      // Crea els productes amb el categoriaId
      for (final productData in products) {
        await _productRepository.addProduct({
          ...productData,
          'categoriaId': categoryId,
        });
      }
    }
  }

  Future<void> fixImages() async {
    final snapshot = await FirebaseFirestore.instance.collection('productes').get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final String url = data['url'] ?? '';
      final String imatge = data['imatge'] ?? '';

      // Si la URL és de decathlon i la imatge és d'unsplash, les arreglem
      if (url.contains('decathlon.es') && imatge.contains('unsplash.com')) {
        await doc.reference.update({
          'url': imatge,
          'imatge': FieldValue.delete(),
        });
      } else if (data.containsKey('imatge')) {
        // En qualsevol cas, borrem el camp redundant si existeix
        await doc.reference.update({
          'imatge': FieldValue.delete(),
        });
      }
    }
  }
}
