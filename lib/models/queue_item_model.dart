class QueueItemModel {
  final String id;
  final String textToConvert;
  final String filename;
  final String sceneDirection;
  final String sampleContext;
  final DateTime createdAt;
  final QueueItemStatus status;
  final double progress;
  final String? errorMessage;
  final int? estimatedWaitTimeSeconds;

  QueueItemModel({
    required this.id,
    required this.textToConvert,
    required this.filename,
    required this.sceneDirection,
    required this.sampleContext,
    required this.createdAt,
    this.status = QueueItemStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.estimatedWaitTimeSeconds,
  });

  /// Get text snippet (first 50 characters for display)
  String get textSnippet {
    if (textToConvert.length > 50) {
      return '${textToConvert.substring(0, 50)}...';
    }
    return textToConvert;
  }

  /// Calculate elapsed time since item was created
  Duration get elapsedTime {
    return DateTime.now().difference(createdAt);
  }

  /// Get human-readable position in queue (1-indexed)
  int getPositionInQueue(List<QueueItemModel> queue) {
    return queue.indexWhere((item) => item.id == id) + 1;
  }

  /// Create a copy of this model with optional field overrides
  QueueItemModel copyWith({
    String? id,
    String? textToConvert,
    String? filename,
    String? sceneDirection,
    String? sampleContext,
    DateTime? createdAt,
    QueueItemStatus? status,
    double? progress,
    String? errorMessage,
    int? estimatedWaitTimeSeconds,
  }) {
    return QueueItemModel(
      id: id ?? this.id,
      textToConvert: textToConvert ?? this.textToConvert,
      filename: filename ?? this.filename,
      sceneDirection: sceneDirection ?? this.sceneDirection,
      sampleContext: sampleContext ?? this.sampleContext,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      estimatedWaitTimeSeconds: estimatedWaitTimeSeconds ?? this.estimatedWaitTimeSeconds,
    );
  }

  /// Convert QueueItemModel to JSON for storage/serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textToConvert': textToConvert,
      'filename': filename,
      'sceneDirection': sceneDirection,
      'sampleContext': sampleContext,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'progress': progress,
      'errorMessage': errorMessage,
      'estimatedWaitTimeSeconds': estimatedWaitTimeSeconds,
    };
  }

  /// Create QueueItemModel from JSON
  factory QueueItemModel.fromJson(Map<String, dynamic> json) {
    return QueueItemModel(
      id: json['id'] as String? ?? '',
      textToConvert: json['textToConvert'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      sceneDirection: json['sceneDirection'] as String? ?? '',
      sampleContext: json['sampleContext'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['errorMessage'] as String?,
      estimatedWaitTimeSeconds: json['estimatedWaitTimeSeconds'] as int?,
    );
  }

  /// Helper to parse status string to enum
  static QueueItemStatus _parseStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'processing':
        return QueueItemStatus.processing;
      case 'completed':
        return QueueItemStatus.completed;
      case 'failed':
        return QueueItemStatus.failed;
      case 'pending':
      default:
        return QueueItemStatus.pending;
    }
  }

  @override
  String toString() {
    return 'QueueItemModel(id: $id, filename: $filename, status: $status, progress: ${progress.toStringAsFixed(2)}%, textSnippet: $textSnippet)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          textToConvert == other.textToConvert &&
          filename == other.filename &&
          sceneDirection == other.sceneDirection &&
          sampleContext == other.sampleContext &&
          createdAt == other.createdAt &&
          status == other.status &&
          progress == other.progress &&
          errorMessage == other.errorMessage &&
          estimatedWaitTimeSeconds == other.estimatedWaitTimeSeconds;

  @override
  int get hashCode =>
      id.hashCode ^
      textToConvert.hashCode ^
      filename.hashCode ^
      sceneDirection.hashCode ^
      sampleContext.hashCode ^
      createdAt.hashCode ^
      status.hashCode ^
      progress.hashCode ^
      errorMessage.hashCode ^
      estimatedWaitTimeSeconds.hashCode;
}

/// Enum for queue item status states
enum QueueItemStatus {
  pending,
  processing,
  completed,
  failed,
}
