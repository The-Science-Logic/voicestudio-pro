class SettingsModel {
  final String apiKey;
  final String voiceProfile;
  final String audioFormat;
  final List<String> audioTags;
  final String sceneDirection;
  final String sampleContext;

  SettingsModel({
    required this.apiKey,
    required this.voiceProfile,
    required this.audioFormat,
    required this.audioTags,
    required this.sceneDirection,
    required this.sampleContext,
  });

  /// Default settings for first-time app launch
  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      apiKey: '',
      voiceProfile: 'Standard',
      audioFormat: 'MP3',
      audioTags: [],
      sceneDirection: '',
      sampleContext: '',
    );
  }

  /// Create a copy of this model with optional field overrides
  SettingsModel copyWith({
    String? apiKey,
    String? voiceProfile,
    String? audioFormat,
    List<String>? audioTags,
    String? sceneDirection,
    String? sampleContext,
  }) {
    return SettingsModel(
      apiKey: apiKey ?? this.apiKey,
      voiceProfile: voiceProfile ?? this.voiceProfile,
      audioFormat: audioFormat ?? this.audioFormat,
      audioTags: audioTags ?? this.audioTags,
      sceneDirection: sceneDirection ?? this.sceneDirection,
      sampleContext: sampleContext ?? this.sampleContext,
    );
  }

  /// Convert SettingsModel to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'voiceProfile': voiceProfile,
      'audioFormat': audioFormat,
      'audioTags': audioTags,
      'sceneDirection': sceneDirection,
      'sampleContext': sampleContext,
    };
  }

  /// Create SettingsModel from JSON (from SharedPreferences)
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      apiKey: json['apiKey'] as String? ?? '',
      voiceProfile: json['voiceProfile'] as String? ?? 'Standard',
      audioFormat: json['audioFormat'] as String? ?? 'MP3',
      audioTags: List<String>.from(json['audioTags'] as List? ?? []),
      sceneDirection: json['sceneDirection'] as String? ?? '',
      sampleContext: json['sampleContext'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'SettingsModel(apiKey: ${apiKey.isNotEmpty ? '***' : 'empty'}, voiceProfile: $voiceProfile, audioFormat: $audioFormat, audioTags: $audioTags, sceneDirection: $sceneDirection, sampleContext: $sampleContext)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModel &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          voiceProfile == other.voiceProfile &&
          audioFormat == other.audioFormat &&
          audioTags == other.audioTags &&
          sceneDirection == other.sceneDirection &&
          sampleContext == other.sampleContext;

  @override
  int get hashCode =>
      apiKey.hashCode ^
      voiceProfile.hashCode ^
      audioFormat.hashCode ^
      audioTags.hashCode ^
      sceneDirection.hashCode ^
      sampleContext.hashCode;
}
