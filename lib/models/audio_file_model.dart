class AudioFileModel {
  final String id;
  final String filename;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final int fileSizeBytes;
  final String audioFormat;
  final bool isPermanent;

  AudioFileModel({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.fileSizeBytes,
    required this.audioFormat,
    this.isPermanent = false,
  });

  /// Check if file is older than 48 hours (for auto-cleanup)
  bool get isOlderThan48Hours {
    final ageInHours = DateTime.now().difference(createdAt).inHours;
    return ageInHours > 48;
  }

  /// Get age of file in human-readable format
  String get ageDisplay {
    final age = DateTime.now().difference(createdAt);
    if (age.inDays > 0) {
      return '${age.inDays} day${age.inDays > 1 ? 's' : ''} ago';
    } else if (age.inHours > 0) {
      return '${age.inHours} hour${age.inHours > 1 ? 's' : ''} ago';
    } else if (age.inMinutes > 0) {
      return '${age.inMinutes} minute${age.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format file size in human-readable format (KB, MB, GB)
  String get fileSizeDisplay {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (fileSizeBytes >= gb) {
      return '${(fileSizeBytes / gb).toStringAsFixed(2)} GB';
    } else if (fileSizeBytes >= mb) {
      return '${(fileSizeBytes / mb).toStringAsFixed(2)} MB';
    } else if (fileSizeBytes >= kb) {
      return '${(fileSizeBytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$fileSizeBytes B';
    }
  }

  /// Format duration in human-readable format (MM:SS or HH:MM:SS)
  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get timestamp in human-readable format (YYYY-MM-DD HH:MM:SS)
  String get timestampDisplay {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}';
  }

  /// Create a copy of this model with optional field overrides
  AudioFileModel copyWith({
    String? id,
    String? filename,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    int? fileSizeBytes,
    String? audioFormat,
    bool? isPermanent,
  }) {
    return AudioFileModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      audioFormat: audioFormat ?? this.audioFormat,
      isPermanent: isPermanent ?? this.isPermanent,
    );
  }

  /// Convert AudioFileModel to JSON for storage/serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inMilliseconds,
      'fileSizeBytes': fileSizeBytes,
      'audioFormat': audioFormat,
      'isPermanent': isPermanent,
    };
  }

  /// Create AudioFileModel from JSON
  factory AudioFileModel.fromJson(Map<String, dynamic> json) {
    return AudioFileModel(
      id: json['id'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : Duration.zero,
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      audioFormat: json['audioFormat'] as String? ?? 'MP3',
      isPermanent: json['isPermanent'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'AudioFileModel(id: $id, filename: $filename, duration: $durationDisplay, size: $fileSizeDisplay, isPermanent: $isPermanent, createdAt: $timestampDisplay)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioFileModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          filename == other.filename &&
          filePath == other.filePath &&
          createdAt == other.createdAt &&
          duration == other.duration &&
          fileSizeBytes == other.fileSizeBytes &&
          audioFormat == other.audioFormat &&
          isPermanent == other.isPermanent;

  @override
  int get hashCode =>
      id.hashCode ^
      filename.hashCode ^
      filePath.hashCode ^
      createdAt.hashCode ^
      duration.hashCode ^
      fileSizeBytes.hashCode ^
      audioFormat.hashCode ^
      isPermanent.hashCode;
}
