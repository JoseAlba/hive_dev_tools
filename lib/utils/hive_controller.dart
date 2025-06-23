import 'dart:ui';

/// Class to manage theme override across the application
class HiveController {
  HiveController._();

  static Map<String, Map<String, String>>? _hiveData;
  static String? _selectedKey;

  static final List<VoidCallback> _listeners = [];

  static Map<String, Map<String, String>>? get hiveData => _hiveData;
  static String? get selectedKey => _selectedKey;

  /// Set an override for the theme mode across the application
  static set hiveData(Map<String, Map<String, String>>? hiveData) {
    _hiveData = hiveData;
    _notifyListeners();
  }

  static set selectedKey(String? selectedKey) {
    _selectedKey = selectedKey;
    _notifyListeners();
  }

  /// Add a listener to be notified when the override changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a previously added listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of a change
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
