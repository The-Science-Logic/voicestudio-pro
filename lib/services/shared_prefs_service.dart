import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _voiceProfileKey = 'voice_profile';
  static const String _audioTagsKey = 'audio_tags';
  static const String _audioFormatKey = 'audio_format';
  static const String _sceneDirectionKey = 'scene_direction';
  static const String _sampleContextKey = 'sample_context';
  static const String _dailyCallsRemainingKey = 'daily_calls_remaining';
  static const String _lastCallsResetKey = 'last_calls_reset';
  
  late SharedPreferences _prefs;
  
  /// Initialize SharedPreferences instance
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ============= API KEY METHODS =============
  
  /// Save API Key
  Future<bool> setApiKey(String apiKey) async {
    return await _prefs.setString(_apiKeyKey, apiKey);
  }
  
  /// Retrieve API Key
  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }
  
  /// Check if API Key exists
  bool hasApiKey() {
    return _prefs.containsKey(_apiKeyKey);
  }
  
  /// Clear API Key
  Future<bool> clearApiKey() async {
    return await _prefs.remove(_apiKeyKey);
  }
  
  // ============= VOICE PROFILE METHODS =============
  
  /// Save Voice Profile
  Future<bool> setVoiceProfile(String profile) async {
    return await _prefs.setString(_voiceProfileKey, profile);
  }
  
  /// Retrieve Voice Profile (default: "Standard")
  String getVoiceProfile() {
    return _prefs.getString(_voiceProfileKey) ?? 'Standard';
  }
  
  // ============= AUDIO TAGS METHODS =============
  
  /// Save Audio Tags (comma-separated string)
  Future<bool> setAudioTags(List<String> tags) async {
    return await _prefs.setStringList(_audioTagsKey, tags);
  }
  
  /// Retrieve Audio Tags
  List<String> getAudioTags() {
    return _prefs.getStringList(_audioTagsKey) ?? [];
  }
  
  // ============= AUDIO FORMAT METHODS =============
  
  /// Save Audio Format
  Future<bool> setAudioFormat(String format) async {
    return await _prefs.setString(_audioFormatKey, format);
  }
  
  /// Retrieve Audio Format (default: "MP3")
  String getAudioFormat() {
    return _prefs.getString(_audioFormatKey) ?? 'MP3';
  }
  
  // ============= SCENE DIRECTION METHODS =============
  
  /// Save Scene Direction
  Future<bool> setSceneDirection(String direction) async {
    return await _prefs.setString(_sceneDirectionKey, direction);
  }
  
  /// Retrieve Scene Direction
  String getSceneDirection() {
    return _prefs.getString(_sceneDirectionKey) ?? '';
  }
  
  // ============= SAMPLE CONTEXT METHODS =============
  
  /// Save Sample Context
  Future<bool> setSampleContext(String context) async {
    return await _prefs.setString(_sampleContextKey, context);
  }
  
  /// Retrieve Sample Context
  String getSampleContext() {
    return _prefs.getString(_sampleContextKey) ?? '';
  }
  
  // ============= API RATE LIMIT METHODS =============
  
  /// Save remaining daily API calls
  Future<bool> setDailyCallsRemaining(int calls) async {
    return await _prefs.setInt(_dailyCallsRemainingKey, calls);
  }
  
  /// Get remaining daily API calls (default: 10,000)
  int getDailyCallsRemaining() {
    return _prefs.getInt(_dailyCallsRemainingKey) ?? 10000;
  }
  
  /// Decrement API calls by count
  Future<bool> decrementDailyCallsRemaining(int count) async {
    final current = getDailyCallsRemaining();
    final updated = (current - count).clamp(0, 10000);
    return await setDailyCallsRemaining(updated);
  }
  
  /// Save last reset time for daily calls
  Future<bool> setLastCallsResetTime(DateTime dateTime) async {
    return await _prefs.setString(_lastCallsResetKey, dateTime.toIso8601String());
  }
  
  /// Get last reset time
  DateTime? getLastCallsResetTime() {
    final stored = _prefs.getString(_lastCallsResetKey);
    if (stored != null) {
      return DateTime.parse(stored);
    }
    return null;
  }
  
  /// Check if daily limit needs reset (if > 24 hours have passed)
  bool shouldResetDailyLimit() {
    final lastReset = getLastCallsResetTime();
    if (lastReset == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastReset);
    return difference.inHours >= 24;
  }
  
  /// Reset daily calls to 10,000 and update reset time
  Future<bool> resetDailyCallLimit() async {
    await setDailyCallsRemaining(10000);
    await setLastCallsResetTime(DateTime.now());
    return true;
  }
  
  // ============= BULK OPERATIONS =============
  
  /// Clear all saved data
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
  
  /// Get all keys stored
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
  
  /// Check if key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
}
