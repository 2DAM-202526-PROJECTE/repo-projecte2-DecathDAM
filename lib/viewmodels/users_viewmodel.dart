import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UsersViewModel extends ChangeNotifier {
  final UserRepository _repository;
  List<UserModel> _users = [];
  String _searchQuery = '';

  UsersViewModel({UserRepository? userRepository})
      : _repository = userRepository ?? UserRepository();

  List<UserModel> get users => _users;
  String get searchQuery => _searchQuery;

  /// Retorna la llista d'usuaris filtrada per la cerca actual.
  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Stream<List<UserModel>>? _usersStream;
  Stream<List<UserModel>> getUsersStream() {
    _usersStream ??= _repository.getUsersStream().map((list) {
      _users = list; // Mantenim la llista local actualitzada
      return list;
    });
    return _usersStream!;
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

  Future<void> addUser(UserModel user) async {
    try {
      await _repository.addUser(user);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding user: $e");
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _repository.updateUser(user);
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
