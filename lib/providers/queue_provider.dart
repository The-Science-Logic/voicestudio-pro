import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/tts_item.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QueueProvider extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _api = ApiService();
  final AudioPlayer _player = AudioPlayer();

  final List<TtsItem> _queue = [];
  bool _isProcessing = false;
  bool _isPaused = false;
  String? _statusMessage;
  int _rateLimitRetrySeconds = 0;
  Timer? _retryTimer;
  int _dailyCallCount = 0;
  static const int _dailyLimitEstimate = 50;

  List<TtsItem> get queue => List.unmodifiable(_queue);
  bool get isProcessing => _isProcessing;
  bool get isPaused => _isPaused;
  String? get statusMessage => _statusMessage;
  int get rateLimitRetrySeconds => _rateLimitRetrySeconds;
  int get dailyCallCount => _dailyCallCount;
  int get dailyLimitEstimate => _dailyLimitEstimate;

  QueueProvider(this._storage) {
    _initPlayer();
  }

  void _initPlayer() {
    // Set audio context for Android playback compatibility
    _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
          usageType: AndroidUsageType.media,
          contentType: AndroidContentType.music,
          audioMode: AndroidAudioMode.normal,
          stayAwake: false,
        ),
      ),
    );
    _player.onPlayerComplete.listen((_) {
      _processNext();
    });
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped ||
          state == PlayerState.completed) {
        _processNext();
      }
    });
  }

  void addItem(TtsItem item) {
    if (_queue.length >= 20) {
      _statusMessage = 'Queue full (max 20 items)';
      notifyListeners();
      return;
    }
    _queue.add(item);
    _statusMessage = null;
    notifyListeners();
    _processNext();
  }

  void removeItem(String id) {
    _queue.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearCompleted() {
    _queue.removeWhere((e) =>
        e.status == TtsStatus.completed ||
        e.status == TtsStatus.failed);
    notifyListeners();
  }

  void pauseQueue() {
    _isPaused = true;
    _statusMessage = 'Queue paused';
    notifyListeners();
  }

  void resumeQueue() {
    _isPaused = false;
    _statusMessage = null;
    notifyListeners();
    _processNext();
  }

  Future<void> _processNext() async {
    if (_isProcessing || _isPaused) return;

    final pending = _queue
        .where((e) => e.status == TtsStatus.pending)
        .toList();
    if (pending.isEmpty) return;

    final item = pending.first;
    final apiKey = _storage.getActiveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _statusMessage = 'No API key set. Go to Settings.';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    item.status = TtsStatus.processing;
    _statusMessage =
        'Processing: ${item.text.length > 40 ? '${item.text.substring(0, 40)}...' : item.text}';
    notifyListeners();

    final result = await _api.generateSpeech(
      apiKey: apiKey,
      text: item.text,
      voice: item.voice,
      format: item.format,
    );

    _isProcessing = false;

    if (result.audioBytes != null) {
      _dailyCallCount++;
      final path = await _storage.saveAudioTemp(
        result.audioBytes!,
        item.id,
        item.format,
        item.saveName,
      );
      item.filePath = path;
      item.status = TtsStatus.completed;
      _statusMessage = 'Completed. Playing audio…';
      notifyListeners();
      await _playAudio(path);
    } else if (result.rateLimited) {
      item.status = TtsStatus.rateLimited;
      item.retryCount++;
      final delay =
          min(120, (5 * pow(2, item.retryCount - 1)).toInt());
      _rateLimitRetrySeconds = delay;
      _statusMessage = 'Rate limited. Retry in ${delay}s';
      _isPaused = true;
      notifyListeners();
      _startRetryCountdown(delay, item);
    } else if (result.dailyLimitReached) {
      item.status = TtsStatus.failed;
      item.errorMessage = 'Daily API quota reached';
      _statusMessage =
          'Daily quota reached. Try tomorrow or switch key.';
      notifyListeners();
    } else {
      item.status = TtsStatus.failed;
      item.errorMessage = result.error;
      _statusMessage = 'Error: ${result.error}';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      _processNext();
    }
  }

  Future<void> _playAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _statusMessage = 'Audio file not found: $filePath';
        notifyListeners();
        return;
      }
      await _player.stop();
      await _player.setVolume(1.0);
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      _statusMessage = 'Playback error: $e';
      notifyListeners();
      // Still process next even if playback fails
      await Future.delayed(const Duration(seconds: 1));
      _processNext();
    }
  }

  void _startRetryCountdown(int seconds, TtsItem item) {
    _retryTimer?.cancel();
    int remaining = seconds;
    _retryTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      _rateLimitRetrySeconds = remaining;
      if (remaining <= 0) {
        timer.cancel();
        item.status = TtsStatus.pending;
        _isPaused = false;
        _statusMessage = 'Retrying…';
        notifyListeners();
        _processNext();
      } else {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
