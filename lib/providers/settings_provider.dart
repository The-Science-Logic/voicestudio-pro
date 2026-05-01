import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../services/shared_prefs_service.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPrefsService _sharedPrefsService;
  
  late SettingsModel _settings;
  bool _isLoading = true;
  String? _error;

  SettingsProvider(this._sharedPrefsService) {
    _initializeSettings();
  }

  // Getters
  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get apiKeyStatus => _settings.apiKey.isNotEmpty ? 'connected' : 'invalid';

  /// Initialize settings from SharedPreferences on app launch
  Future<void> _initializeSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final savedSettings = await _sharedPrefsService.loadSettings();
      _settings = savedSettings ?? SettingsModel.defaultSettings();
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load settings: $e';
      _settings = SettingsModel.defaultSettings();
    }
    notifyListeners();
  }

  /// Update API Key
  Future<void> updateApiKey(String newApiKey) async {
    try {
      _settings = _settings.copyWith(apiKey: newApiKey);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update API Key: $e';
      notifyListeners();
    }
  }

  /// Update Voice Profile
  Future<void> updateVoiceProfile(String voiceProfile) async {
    try {
      _settings = _settings.copyWith(voiceProfile: voiceProfile);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update Voice Profile: $e';
      notifyListeners();
    }
  }

  /// Update Audio Format
  Future<void> updateAudioFormat(String audioFormat) async {
    try {
      _settings = _settings.copyWith(audioFormat: audioFormat);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update Audio Format: $e';
      notifyListeners();
    }
  }

  /// Update Audio Tags (multi-select)
  Future<void> updateAudioTags(List<String> audioTags) async {
    try {
      _settings = _settings.copyWith(audioTags: audioTags);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update Audio Tags: $e';
      notifyListeners();
    }
  }

  /// Update Scene Direction
  Future<void> updateSceneDirection(String sceneDirection) async {
    try {
      _settings = _settings.copyWith(sceneDirection: sceneDirection);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update Scene Direction: $e';
      notifyListeners();
    }
  }

  /// Update Sample Context
  Future<void> updateSampleContext(String sampleContext) async {
    try {
      _settings = _settings.copyWith(sampleContext: sampleContext);
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update Sample Context: $e';
      notifyListeners();
    }
  }

  /// Save all settings at once
  Future<void> saveAllSettings({
    String? apiKey,
    String? voiceProfile,
    String? audioFormat,
    List<String>? audioTags,
    String? sceneDirection,
    String? sampleContext,
  }) async {
    try {
      _settings = _settings.copyWith(
        apiKey: apiKey,
        voiceProfile: voiceProfile,
        audioFormat: audioFormat,
        audioTags: audioTags,
        sceneDirection: sceneDirection,
        sampleContext: sampleContext,
      );
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save settings: $e';
      notifyListeners();
    }
  }

  /// Clear API Key (logout)
  Future<void> clearApiKey() async {
    try {
      _settings = _settings.copyWith(apiKey: '');
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear API Key: $e';
      notifyListeners();
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      _settings = SettingsModel.defaultSettings();
      await _sharedPrefsService.saveSettings(_settings);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset settings: $e';
      notifyListeners();
    }
  }
}
