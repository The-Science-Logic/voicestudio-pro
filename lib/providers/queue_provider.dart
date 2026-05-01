import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/queue_item_model.dart';
import '../services/gemini_tts_service.dart';

class QueueProvider with ChangeNotifier {
  final GeminiTtsService _geminiTtsService;

  final List<QueueItemModel> _queue = [];
  QueueItemModel? _activeJob;
  bool _isProcessing = false;
  String? _error;
  int _apiCallsRemaining = 10000;
  final int _dailyApiLimit = 10000;

  QueueProvider(this._geminiTtsService);

  // Getters
  List<QueueItemModel> get queue => List.unmodifiable(_queue);
  QueueItemModel? get activeJob => _activeJob;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  int get queueLength => _queue.length;
  int get apiCallsRemaining => _apiCallsRemaining;
  int get dailyApiLimit => _dailyApiLimit;
  double get apiUsagePercentage => ((_dailyApiLimit - _apiCallsRemaining) / _dailyApiLimit) * 100;

  /// Add a single text item to the queue (FIFO)
  void addToQueue({
    required String textToConvert,
    required String filename,
    required String sceneDirection,
    required String sampleContext,
  }) {
    if (_queue.length >= 20) {
      _error = 'Queue is full (max 20 items)';
      notifyListeners();
      return;
    }

    if (textToConvert.isEmpty) {
      _error = 'Text to convert cannot be empty';
      notifyListeners();
      return;
    }

    if (filename.isEmpty) {
      _error = 'Filename cannot be empty';
      notifyListeners();
      return;
    }

    final newItem = QueueItemModel(
      id: const Uuid().v4(),
      textToConvert: textToConvert,
      filename: filename,
      sceneDirection: sceneDirection,
      sampleContext: sampleContext,
      createdAt: DateTime.now(),
      status: QueueItemStatus.pending,
      progress: 0.0,
      estimatedWaitTimeSeconds: _calculateEstimatedWaitTime(),
    );

    _queue.add(newItem);
    _error = null;
    notifyListeners();
  }

  /// Start processing the queue (FIFO order)
  Future<void> startQueue() async {
    if (_isProcessing) {
      _error = 'Queue is already processing';
      notifyListeners();
      return;
    }

    if (_queue.isEmpty) {
      _error = 'Queue is empty';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    while (_queue.isNotEmpty && _isProcessing) {
      final currentItem = _queue.first;
      await _processQueueItem(currentItem);

      if (_isProcessing) {
        _queue.removeAt(0);
        notifyListeners();
      }
    }

    _isProcessing = false;
    _activeJob = null;
    _error = null;
    notifyListeners();
  }

  /// Process a single queue item
  Future<void> _processQueueItem(QueueItemModel item) async {
    try {
      _activeJob = item.copyWith(status: QueueItemStatus.processing);
      notifyListeners();

      // Simulate API rate limit check
      if (_apiCallsRemaining <= 0) {
        _isProcessing = false;
        _error = 'API rate limit reached. Queue paused.';
        _activeJob = _activeJob?.copyWith(
          status: QueueItemStatus.failed,
          errorMessage: 'API rate limit reached',
        );
        notifyListeners();
        return;
      }

      // Call Gemini TTS API
      final result = await _geminiTtsService.synthesizeText(
        text: item.textToConvert,
        filename: item.filename,
        sceneDirection: item.sceneDirection,
        sampleContext: item.sampleContext,
      );

      // Update API call count (estimate: 1 call per request)
      _apiCallsRemaining -= 1;

      if (result['success'] == true) {
        _activeJob = _activeJob?.copyWith(
          status: QueueItemStatus.completed,
          progress: 100.0,
        );
        _error = null;
      } else {
        final errorMsg = result['error'] as String? ?? 'Unknown error occurred';
        _activeJob = _activeJob?.copyWith(
          status: QueueItemStatus.failed,
          errorMessage: errorMsg,
        );
        _error = 'Failed to process: $errorMsg';
      }
    } catch (e) {
      _activeJob = _activeJob?.copyWith(
        status: QueueItemStatus.failed,
        errorMessage: e.toString(),
      );
      _error = 'Error processing queue item: $e';
    }

    notifyListeners();
  }

  /// Cancel the currently active job
  void cancelActiveJob() {
    if (_activeJob != null) {
      _activeJob = _activeJob?.copyWith(
        status: QueueItemStatus.failed,
        errorMessage: 'Cancelled by user',
      );
      _isProcessing = false;
      _error = null;
      notifyListeners();
    }
  }

  /// Remove a specific item from the queue by ID
  void removeQueueItem(String itemId) {
    _queue.removeWhere((item) => item.id == itemId);
    _error = null;
    notifyListeners();
  }

  /// Remove all items from the queue
  void clearQueue() {
    _queue.clear();
    _activeJob = null;
    _isProcessing = false;
    _error = null;
    notifyListeners();
  }

  /// Pause queue processing (does not reset active job)
  void pauseQueue() {
    if (_isProcessing) {
      _isProcessing = false;
      _error = null;
      notifyListeners();
    }
  }

  /// Resume queue processing from where it left off
  Future<void> resumeQueue() async {
    if (!_isProcessing && _queue.isNotEmpty) {
      await startQueue();
    }
  }

  /// Update progress of the active job (called by service)
  void updateActiveJobProgress(double progress) {
    if (_activeJob != null) {
      _activeJob = _activeJob?.copyWith(progress: progress);
      notifyListeners();
    }
  }

  /// Calculate estimated wait time for a new item (rough estimate)
  int _calculateEstimatedWaitTime() {
    // Assume ~30 seconds per item in queue
    return (_queue.length + 1) * 30;
  }

  /// Get the position of an item in the queue (1-indexed)
  int getQueuePosition(String itemId) {
    final index = _queue.indexWhere((item) => item.id == itemId);
    return index >= 0 ? index + 1 : -1;
  }

  /// Get queue item by ID
  QueueItemModel? getQueueItemById(String itemId) {
    try {
      return _queue.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Manually set API calls remaining (for testing or syncing with backend)
  void setApiCallsRemaining(int remaining) {
    _apiCallsRemaining = remaining;
    notifyListeners();
  }

  /// Reset API calls remaining to daily limit (call at midnight or on manual reset)
  void resetDailyApiCalls() {
    _apiCallsRemaining = _dailyApiLimit;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _queue.clear();
    _activeJob = null;
    _isProcessing = false;
    super.dispose();
  }
}
