import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryProvider extends ChangeNotifier {
  static const String _historyKey = 'voicestudio_history';
  static const int _maxHistoryItems = 30;
  
  List<String> _history = [];
  
  List<String> get history => List.unmodifiable(_history);
  int get historyCount => _history.length;
  
  /// Initialize history from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHistory = prefs.getStringList(_historyKey) ?? [];
      _history = storedHistory;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing history: $e');
    }
  }
  
  /// Add a text prompt to history (oldest item removed if exceeds max)
  Future<void> addToHistory(String text) async {
    if (text.trim().isEmpty) return;
    
    try {
      // Remove duplicate if it exists
      _history.removeWhere((item) => item == text);
      
      // Add to beginning (most recent first)
      _history.insert(0, text);
      
      // Keep only last 30 items
      if (_history.length > _maxHistoryItems) {
        _history = _history.sublist(0, _maxHistoryItems);
      }
      
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }
  
  /// Remove a specific item from history
  Future<void> removeFromHistory(String text) async {
    try {
      _history.removeWhere((item) => item == text);
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from history: $e');
    }
  }
  
  /// Clear all history with confirmation
  Future<void> clearHistory() async {
    try {
      _history.clear();
      await _saveHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
  
  /// Get history item at index
  String? getHistoryItem(int index) {
    if (index >= 0 && index < _history.length) {
      return _history[index];
    }
    return null;
  }
  
  /// Search history by partial text match
  List<String> searchHistory(String query) {
    if (query.trim().isEmpty) return _history;
    
    final lowerQuery = query.toLowerCase();
    return _history
        .where((item) => item.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  /// Save history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, _history);
    } catch (e) {
      debugPrint('Error saving history to SharedPreferences: $e');
    }
  }
  
  /// Export history as JSON string
  String exportHistoryAsJson() {
    return jsonEncode({
      'exported_at': DateTime.now().toIso8601String(),
      'items_count': _history.length,
      'history': _history,
    });
  }
}
