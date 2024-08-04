import 'package:flutter/material.dart';
import 'package:vivero/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isAdmin = false;

  User? get user => _user;
  bool get isAdmin => _isAdmin;

  void setUser(User user, {bool isAdmin = false}) {
    _user = user;
    _isAdmin = isAdmin;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _isAdmin = false;
    notifyListeners();
  }
}
