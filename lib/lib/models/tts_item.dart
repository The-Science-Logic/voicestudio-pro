enum TtsStatus { pending, processing, completed, failed, rateLimited }

class TtsItem {
  final String id;
  final String text;
  final String voice;
  final String format;
  final List<String> tags;
  TtsStatus status;
  String? filePath;
  String? errorMessage;
  int retryCount;
  DateTime createdAt;

  TtsItem({
    required this.id,
    required this.text,
    required this.voice,
    required this.format,
    required this.tags,
    this.status = TtsStatus.pending,
    this.filePath,
    this.errorMessage,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'voice': voice,
        'format': format,
        'tags': tags,
        'status': status.name,
        'filePath': filePath,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TtsItem.fromJson(Map<String, dynamic> j) => TtsItem(
        id: j['id'] as String,
        text: j['text'] as String,
        voice: j['voice'] as String,
        format: j['format'] as String,
        tags: List<String>.from(j['tags'] as List),
        status: TtsStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => TtsStatus.pending,
        ),
        filePath: j['filePath'] as String?,
        errorMessage: j['errorMessage'] as String?,
        retryCount: (j['retryCount'] as int?) ?? 0,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
