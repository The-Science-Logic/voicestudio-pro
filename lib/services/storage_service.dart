import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voicestudio_pro/models/audio_file_model.dart';

class StorageService {
  static const String _audioFolderName = 'voicestudio_audio';
  
  Directory? _audioDirectory;
  
  /// Initialize storage and create audio directory
  Future<void> initialize() async {
    try {
      _audioDirectory = await _getAudioDirectory();
      
      // Create directory if it doesn't exist
      if (!await _audioDirectory!.exists()) {
        await _audioDirectory!.create(recursive: true);
      }
    } catch (e) {
      print('Error initializing storage: $e');
    }
  }
  
  /// Get the audio files directory
  Future<Directory> _getAudioDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory('${appDocDir.path}/$_audioFolderName');
  }
  
  /// Get audio directory instance
  Directory? get audioDirectory => _audioDirectory;
  
  /// Save audio file (binary data) to storage
  Future<File?> saveAudioFile({
    required String filename,
    required List<int> audioData,
  }) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      final savedFile = await file.writeAsBytes(audioData);
      
      return savedFile;
    } catch (e) {
      print('Error saving audio file: $e');
      return null;
    }
  }
  
  /// Read audio file as bytes
  Future<List<int>?> readAudioFile(String filename) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      
      return null;
    } catch (e) {
      print('Error reading audio file: $e');
      return null;
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String filename) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }
  
  /// Delete audio file
  Future<bool> deleteAudioFile(String filename) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting audio file: $e');
      return false;
    }
  }
  
  /// Get file size in bytes
  Future<int?> getFileSize(String filename) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      
      if (await file.exists()) {
        final stat = file.statSync();
        return stat.size;
      }
      
      return null;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }
  
  /// Get total storage size of all audio files
  Future<int> getTotalStorageSize() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      final files = _audioDirectory!.listSync();
      
      for (var file in files) {
        if (file is File) {
          final stat = file.statSync();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating total storage size: $e');
      return 0;
    }
  }
  
  /// Get all audio files in directory
  Future<List<File>> getAllAudioFiles() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        return [];
      }
      
      final files = _audioDirectory!.listSync();
      return files.whereType<File>().toList();
    } catch (e) {
      print('Error getting all audio files: $e');
      return [];
    }
  }
  
  /// Delete files older than 48 hours
  Future<List<String>> deleteOldFiles() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        return [];
      }
      
      final deletedFiles = <String>[];
      final files = _audioDirectory!.listSync();
      final now = DateTime.now();
      final threshold = now.subtract(Duration(hours: 48));
      
      for (var file in files) {
        if (file is File) {
          final stat = file.statSync();
          final modified = stat.modified;
          
          if (modified.isBefore(threshold)) {
            await file.delete();
            deletedFiles.add(file.path.split('/').last);
          }
        }
      }
      
      return deletedFiles;
    } catch (e) {
      print('Error deleting old files: $e');
      return [];
    }
  }
  
  /// Clear all audio files
  Future<bool> clearAllAudioFiles() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        return true;
      }
      
      final files = _audioDirectory!.listSync();
      
      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      
      return true;
    } catch (e) {
      print('Error clearing all audio files: $e');
      return false;
    }
  }
  
  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
  
  /// Get file creation time
  Future<DateTime?> getFileCreationTime(String filename) async {
    try {
      if (_audioDirectory == null) {
        await initialize();
      }
      
      final file = File('${_audioDirectory!.path}/$filename');
      
      if (await file.exists()) {
        final stat = file.statSync();
        return stat.changed;
      }
      
      return null;
    } catch (e) {
      print('Error getting file creation time: $e');
      return null;
    }
  }
}
