import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryStore {
  SearchHistoryStore._();

  static const String _key = 'kluxe_recent_searches';
  static final List<String> _history = [];
  static bool _isLoaded = false;

  static List<String> get history {
    if (!_isLoaded) {
      load();
    }
    return List.unmodifiable(_history);
  }

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key);
      if (saved != null) {
        _history.clear();
        _history.addAll(saved);
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('[SearchHistoryStore] Load error: $e');
    }
  }

  static Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    _history.insert(0, trimmed);

    if (_history.length > 10) {
      _history.removeRange(10, _history.length);
    }

    await _save();
  }

  static Future<void> remove(String query) async {
    _history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await _save();
  }

  static Future<void> clear() async {
    _history.clear();
    await _save();
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _history);
    } catch (e) {
      debugPrint('[SearchHistoryStore] Save error: $e');
    }
  }
}
