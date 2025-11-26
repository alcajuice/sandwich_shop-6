import 'package:flutter/foundation.dart';

class Auth extends ChangeNotifier {
  Auth._internal();

  static final Auth instance = Auth._internal();

  String? _username;

  String? get username => _username;

  bool get isLoggedIn => _username != null && _username!.isNotEmpty;

  void login(String username, String password) {
    // This is a simple in-memory stub. In a real app validate credentials.
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}
