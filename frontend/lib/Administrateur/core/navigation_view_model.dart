import 'package:flutter/material.dart';

class NavigationViewModel extends ChangeNotifier {
  String _currentRoute = '/cours';

  bool _coursExists = false;
  bool _edtExists = false;

  String get currentRoute => _currentRoute;

  /// Dashboard activé seulement si cours + EDT existent
  bool get dashboardEnabled => _coursExists && _edtExists;

  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  /// ⚡ À appeler quand la liste des cours change
  void markCoursExists(bool exists) {
    if (_coursExists == exists) return;
    _coursExists = exists;
    notifyListeners();
  }

  /// ⚡ À appeler quand les séances EDT changent
  void markEdtExists(bool exists) {
    if (_edtExists == exists) return;
    _edtExists = exists;
    notifyListeners();
  }
}
