import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UsersViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  Stream<List<UserModel>> getUsersStream() {
    return _repository.getUsersStream();
  }

  Future<int> getUsersCount() async {
    return _repository.getUsersCount();
  }

  Future<void> fetchUsers() async {
    try {
      _users = await _repository.fetchUsers();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _repository.addUser(userData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding user: $e");
      rethrow;
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      await _repository.updateUser(id, userData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _repository.deleteUser(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting user: $e");
      rethrow;
    }
  }
}
