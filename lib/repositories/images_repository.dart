import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/models/imatges_model.dart';

class ImagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'imatges';

  Future<List<Imatges>> fetchImages() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((doc) {
        return Imatges.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      // Return empty list or rethrow depending on desired error handling
      print('Error fetching images: $e');
      return [];
    }
  }

  Stream<List<Imatges>> getImagesStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Imatges.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}
