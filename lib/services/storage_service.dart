import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  static const String _keyApiKeys = 'api_keys_v2';
  static const String _keyActiveKeyIndex = 'active_key_index';
  static const String _keySceneDirection = 'scene_direction';
  static const String _keySampleContext = 'sample_context';
  static const String _keyHistory = 'history_v2';
  static const String _keyVoice = 'voice';
  static const String _keyFormat = 'audio_format';
  static const String _keyTags = 'audio_tags';
  static const int _maxHistory = 30;

  StorageService(this._prefs);

  // ── API Keys ──────────────────────────────────────────────────────────────

  List<String> getApiKeys() {
    final raw = _prefs.getString(_keyApiKeys);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> saveApiKeys(List<String> keys) async {
    await _prefs.setString(_keyApiKeys, jsonEncode(keys));
  }

  int getActiveKeyIndex() =>
      _prefs.getInt(_keyActiveKeyIndex) ?? 0;

  Future<void> setActiveKeyIndex(int index) async {
    await _prefs.setInt(_keyActiveKeyIndex, index);
  }

  String? getActiveApiKey() {
    final keys = getApiKeys();
    final idx = getActiveKeyIndex();
    if (keys.isEmpty || idx >= keys.length) return null;
    final key = keys[idx];
    return key.isEmpty ? null : key;
  }

  // ── Scene / Context ───────────────────────────────────────────────────────

  String getSceneDirection() =>
      _prefs.getString(_keySceneDirection) ?? '';

  Future<void> saveSceneDirection(String val) async =>
      _prefs.setString(_keySceneDirection, val);

  String getSampleContext() =>
      _prefs.getString(_keySampleContext) ?? '';

  Future<void> saveSampleContext(String val) async =>
      _prefs.setString(_keySampleContext, val);

  // ── Voice / Format / Tags ─────────────────────────────────────────────────

  String getVoice() => _prefs.getString(_keyVoice) ?? 'Puck';

  Future<void> saveVoice(String v) async =>
      _prefs.setString(_keyVoice, v);

  String getFormat() =>
      _prefs.getString(_keyFormat) ?? 'mp3';

  Future<void> saveFormat(String f) async =>
      _prefs.setString(_keyFormat, f);

  List<String> getTags() {
    final raw = _prefs.getString(_keyTags);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> saveTags(List<String> tags) async =>
      _prefs.setString(_keyTags, jsonEncode(tags));

  // ── History ───────────────────────────────────────────────────────────────

  List<String> getHistory() {
    final raw = _prefs.getString(_keyHistory);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> addHistory(String text) async {
    final h = getHistory();
    h.insert(0, text);
    await _prefs.setString(
        _keyHistory, jsonEncode(h.take(_maxHistory).toList()));
  }

  Future<void> clearHistory() async =>
      _prefs.remove(_keyHistory);

  // ── File Storage ──────────────────────────────────────────────────────────

  Future<Directory> _getDocsDir() async =>
      getApplicationDocumentsDirectory();

  Future<Directory> _getTempAudioDir() async {
    final base = await _getDocsDir();
    final dir = Directory('${base.path}/audio_temp');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // Permanent files saved to Music/VoiceStudioPro — visible in File Manager
  Future<Directory> _getPermanentAudioDir() async {
    Directory? base;
    try {
      final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.music);
      if (dirs != null && dirs.isNotEmpty) {
        base = dirs.first;
      }
    } catch (_) {}
    base ??= await _getDocsDir();
    final dir = Directory('${base.path}/VoiceStudioPro');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // Sanitize filename — remove characters not allowed in Android filenames
  String _sanitizeFileName(String name) {
    if (name.trim().isEmpty) return '';
    return name
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  Future<String> saveAudioTemp(
      Uint8List bytes, String id, String format, String saveName) async {
    final dir = await _getTempAudioDir();
    final sanitized = _sanitizeFileName(saveName);
    final fileName = sanitized.isNotEmpty
        ? '${sanitized}_$id.$format'
        : '$id.$format';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> makeAudioPermanent(String filePath) async {
    final permDir = await _getPermanentAudioDir();
    final src = File(filePath);
    final fileName = src.uri.pathSegments.last;
    final dest = File('${permDir.path}/$fileName');
    await src.copy(dest.path);
    await src.delete();
    return dest.path;
  }

  Future<void> deleteAudioFile(String filePath) async {
    final f = File(filePath);
    if (await f.exists()) await f.delete();
  }

  Future<void> deleteOldFiles() async {
    try {
      final dir = await _getTempAudioDir();
      final cutoff =
          DateTime.now().subtract(const Duration(hours: 48));
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          }
        }
      }
    } catch (_) {}
  }

  Future<List<File>> listTempFiles() async {
    final dir = await _getTempAudioDir();
    return dir.listSync().whereType<File>().toList();
  }

  Future<List<File>> listPermanentFiles() async {
    final dir = await _getPermanentAudioDir();
    return dir.listSync().whereType<File>().toList();
  }
}
