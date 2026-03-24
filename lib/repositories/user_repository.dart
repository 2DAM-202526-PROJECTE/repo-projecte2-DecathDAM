import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'usuaris';

  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<UserModel>> fetchUsers() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    return snapshot.docs.map((doc) {
      return UserModel.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  Future<void> addUser(UserModel user) async {
    await _firestore.collection(_collectionName).doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection(_collectionName).doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  Future<UserModel?> getUserById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  /// Retorna el nombre d'usuaris sense descarregar cap document.
  Future<int> getUsersCount() async {
    final snapshot = await _firestore.collection(_collectionName).count().get();
    return snapshot.count ?? 0;
  }
}
