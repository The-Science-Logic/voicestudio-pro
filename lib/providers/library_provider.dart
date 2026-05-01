import 'package:flutter/foundation.dart';
import 'package:voicestudio_pro/models/audio_file_model.dart';
import 'dart:io';

class LibraryProvider extends ChangeNotifier {
  List<AudioFileModel> _audioFiles = [];
  Directory? _audioDirectory;
  
  List<AudioFileModel> get audioFiles => List.unmodifiable(_audioFiles);
  int get fileCount => _audioFiles.length;
  
  String get totalStorageSize {
    double totalBytes = 0;
    for (var file in _audioFiles) {
      totalBytes += file.fileSizeBytes;
    }
    return _formatFileSize(totalBytes.toInt());
  }
  
  DateTime? _lastCleanupTime;
  DateTime? get lastCleanupTime => _lastCleanupTime;
  
  /// Initialize library from audio directory
  Future<void> initialize(Directory audioDirectory) async {
    try {
      _audioDirectory = audioDirectory;
      
      // Create directory if it doesn't exist
      if (!await audioDirectory.exists()) {
        await audioDirectory.create(recursive: true);
      }
      
      await _loadAudioFiles();
      await _performCleanup();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing library: $e');
    }
  }
  
  /// Load all audio files from directory
  Future<void> _loadAudioFiles() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        _audioFiles = [];
        return;
      }
      
      final files = _audioDirectory!.listSync();
      _audioFiles.clear();
      
      for (var file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final stat = file.statSync();
          final created = stat.changed;
          
          // Parse duration from filename (format: filename_duration.ext)
          int durationSeconds = _parseDurationFromFile(file);
          
          final audioFile = AudioFileModel(
            id: fileName.replaceAll('.', '_'),
            filename: fileName,
            filePath: file.path,
            fileSizeBytes: stat.size,
            durationSeconds: durationSeconds,
            createdAt: created,
            isTemporary: true,
            tags: [],
          );
          
          _audioFiles.add(audioFile);
        }
      }
      
      // Sort by creation date (newest first)
      _audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading audio files: $e');
      _audioFiles = [];
    }
  }
  
  /// Parse duration from file (assumes metadata or filename convention)
  int _parseDurationFromFile(File file) {
    try {
      // This is a placeholder for actual metadata reading
      // In production, use a package like audioplayers to get duration
      return 0; // Duration in seconds
    } catch (e) {
      debugPrint('Error parsing duration: $e');
      return 0;
    }
  }
  
  /// Perform 48-hour cleanup
  Future<void> _performCleanup() async {
    try {
      if (_audioDirectory == null) return;
      
      final now = DateTime.now();
      final threshold = now.subtract(Duration(hours: 48));
      
      List<AudioFileModel> filesToDelete = [];
      
      for (var file in _audioFiles) {
        if (file.createdAt.isBefore(threshold)) {
          filesToDelete.add(file);
        }
      }
      
      for (var file in filesToDelete) {
        await deleteFile(file.id);
      }
      
      _lastCleanupTime = now;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }
  
  /// Manually delete a file by ID
  Future<void> deleteFile(String fileId) async {
    try {
      final file = _audioFiles.firstWhere(
        (f) => f.id == fileId,
        orElse: () => AudioFileModel(
          id: '',
          filename: '',
          filePath: '',
          fileSizeBytes: 0,
          durationSeconds: 0,
          createdAt: DateTime.now(),
          isTemporary: true,
          tags: [],
        ),
      );
      
      if (file.id.isEmpty) return;
      
      final physicalFile = File(file.filePath);
      if (await physicalFile.exists()) {
        await physicalFile.delete();
      }
      
      _audioFiles.removeWhere((f) => f.id == fileId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
  
  /// Add a newly generated audio file to library
  Future<void> addAudioFile(AudioFileModel audioFile) async {
    try {
      // Remove duplicate if exists
      _audioFiles.removeWhere((f) => f.filename == audioFile.filename);
      
      // Insert at beginning (newest first)
      _audioFiles.insert(0, audioFile);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding audio file: $e');
    }
  }
  
  /// Get audio file by ID
  AudioFileModel? getAudioFileById(String id) {
    try {
      return _audioFiles.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get files created in last N hours
  List<AudioFileModel> getRecentFiles(int hours) {
    final threshold = DateTime.now().subtract(Duration(hours: hours));
    return _audioFiles.where((f) => f.createdAt.isAfter(threshold)).toList();
  }
  
  /// Manually trigger cleanup (user-initiated)
  Future<void> triggerManualCleanup() async {
    try {
      await _performCleanup();
    } catch (e) {
      debugPrint('Error during manual cleanup: $e');
    }
  }
  
  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  
  /// Refresh library (reload files from disk)
  Future<void> refresh() async {
    try {
      await _loadAudioFiles();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing library: $e');
    }
  }
}
