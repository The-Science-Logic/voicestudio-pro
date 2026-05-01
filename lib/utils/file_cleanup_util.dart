import 'dart:io';
import 'package:voicestudio_pro/models/audio_file_model.dart';

class FileCleanupUtil {
  static const int _cleanupIntervalHours = 24;
  static const int _fileExpirationHours = 48;
  
  /// Check if cleanup should run based on last cleanup time
  static bool shouldRunCleanup(DateTime? lastCleanupTime) {
    if (lastCleanupTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCleanupTime);
    
    return difference.inHours >= _cleanupIntervalHours;
  }
  
  /// Get files that are older than 48 hours
  static List<AudioFileModel> getExpiredFiles(List<AudioFileModel> files) {
    final now = DateTime.now();
    final threshold = now.subtract(Duration(hours: _fileExpirationHours));
    
    return files
        .where((file) => file.createdAt.isBefore(threshold))
        .toList();
  }
  
  /// Delete expired files from disk
  static Future<List<String>> deleteExpiredFiles(List<AudioFileModel> expiredFiles) async {
    final deletedFiles = <String>[];
    
    for (var file in expiredFiles) {
      try {
        final physicalFile = File(file.filePath);
        
        if (await physicalFile.exists()) {
          await physicalFile.delete();
          deletedFiles.add(file.filename);
        }
      } catch (e) {
        print('Error deleting file ${file.filename}: $e');
      }
    }
    
    return deletedFiles;
  }
  
  /// Get human-readable cleanup status
  static String getCleanupStatus(DateTime? lastCleanupTime) {
    if (lastCleanupTime == null) {
      return 'Never cleaned';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastCleanupTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
  /// Calculate total size of expired files
  static int getExpiredFilesSize(List<AudioFileModel> expiredFiles) {
    return expiredFiles.fold(0, (sum, file) => sum + file.fileSizeBytes);
  }
  
  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
  
  /// Get cleanup summary
  static String get
