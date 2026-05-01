import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tts_item.dart';
import '../providers/queue_provider.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _textController = TextEditingController();
  final _sceneController = TextEditingController();
  final _contextController = TextEditingController();
  bool _showHistory = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _sceneController.text = storage.getSceneDirection();
    _contextController.text = storage.getSampleContext();
    _history = storage.getHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _sceneController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _refreshHistory() {
    setState(() {
      _history = context.read<StorageService>().getHistory();
    });
  }

  void _addToQueue() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text first'),
          backgroundColor: Color(0xFFF44336),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final storage = context.read<StorageService>();
    final item = TtsItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      voice: storage.getVoice(),
      format: storage.getFormat(),
      tags: storage.getTags(),
    );
    context.read<QueueProvider>().addItem(item);
    storage.addHistory(text);
    _textController.clear();
    _refreshHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to queue'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveScene() async {
    final storage = context.read<StorageService>();
    await storage.saveSceneDirection(_sceneController.text);
    await storage.saveSampleContext(_contextController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scene saved'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (queue.statusMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF00D9FF)),
              ),
              child: Row(
                children: [
                  if (queue.isPaused)
                    const Icon(Icons.pause_circle,
                        color: Color(0xFFF44336), size: 18)
                  else if (queue.isProcessing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00D9FF),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      queue.isPaused &&
                              queue.rateLimitRetrySeconds > 0
                          ? '${queue.statusMessage} (${queue.rateLimitRetrySeconds}s)'
                          : queue.statusMessage!,
                      style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color(0xFF444444)),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('API Calls Today',
                        style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10)),
                    Text(
                      '${queue.dailyCallCount} / ~${queue.dailyLimitEstimate}',
                      style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                queue.isPaused
                    ? ElevatedButton.icon(
                        onPressed: queue.resumeQueue,
                        icon: const Icon(Icons.play_arrow,
                            size: 16),
                        label: const Text('Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                          textStyle:
                              const TextStyle(fontSize: 12),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: queue.pauseQueue,
                        icon: const Icon(Icons.pause,
                            size: 16),
                        label: const Text('Pause Queue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF44336),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                          textStyle:
                              const TextStyle(fontSize: 12),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('Scene Direction'),
          TextField(
            controller: _sceneController,
            maxLines: 3,
            maxLength: 300,
            style:
                const TextStyle(color: Color(0xFFE0E0E0)),
            decoration: const InputDecoration(
              hintText: 'Describe the scene direction…',
              counterStyle:
                  TextStyle(color: Color(0xFF888888)),
            ),
          ),
          const SizedBox(height: 10),

          _sectionLabel('Sample Context'),
          TextField(
            controller: _contextController,
            maxLines: 6,
            maxLength: 600,
            style:
                const TextStyle(color: Color(0xFFE0E0E0)),
            decoration: const InputDecoration(
              hintText: 'Paste sample context here…',
              counterStyle:
                  TextStyle(color: Color(0xFF888888)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _saveScene,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save Scene'),
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('Text to Synthesize'),
          TextField(
            controller: _textController,
            maxLines: 4,
            maxLength: 1000,
            style:
                const TextStyle(color: Color(0xFFE0E0E0)),
            decoration: const InputDecoration(
              hintText:
                  'Enter text to convert to speech…',
              counterStyle:
                  TextStyle(color: Color(0xFF888888)),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToQueue,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add to Queue'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => setState(
                    () => _showHistory = !_showHistory),
                icon: Icon(
                  _showHistory
                      ? Icons.history_toggle_off
                      : Icons.history,
                  size: 18,
                  color: const Color(0xFF00D9FF),
                ),
                label: const Text('History',
                    style:
                        TextStyle(color: Color(0xFF00D9FF))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFF00D9FF)),
                ),
              ),
            ],
          ),

          if (_showHistory) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel(
                    'History (${_history.length})'),
                TextButton(
                  onPressed: () async {
                    await context
                        .read<StorageService>()
                        .clearHistory();
                    _refreshHistory();
                  },
                  child: const Text('Clear All',
                      style: TextStyle(
                          color: Color(0xFFF44336),
                          fontSize: 12)),
                ),
              ],
            ),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('No history yet.',
                    style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13)),
              )
            else
              ..._history.map((h) => _historyTile(h)),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _historyTile(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        setState(() => _showHistory = false);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(6),
          border:
              Border.all(color: const Color(0xFF444444)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.length > 80
                    ? '${text.substring(0, 80)}…'
                    : text,
                style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 13),
              ),
            ),
            const Icon(Icons.north_west,
                color: Color(0xFF888888), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}
