import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tts_item.dart';
import '../providers/queue_provider.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  Color _statusColor(TtsStatus s) {
    switch (s) {
      case TtsStatus.pending:
        return const Color(0xFF888888);
      case TtsStatus.processing:
        return const Color(0xFF00D9FF);
      case TtsStatus.completed:
        return const Color(0xFF4CAF50);
      case TtsStatus.failed:
        return const Color(0xFFF44336);
      case TtsStatus.rateLimited:
        return const Color(0xFFFF9800);
    }
  }

  IconData _statusIcon(TtsStatus s) {
    switch (s) {
      case TtsStatus.pending:
        return Icons.hourglass_empty;
      case TtsStatus.processing:
        return Icons.sync;
      case TtsStatus.completed:
        return Icons.check_circle;
      case TtsStatus.failed:
        return Icons.error;
      case TtsStatus.rateLimited:
        return Icons.timer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QueueProvider>();
    final items = qp.queue;

    return Column(
      children: [
        Container(
          color: const Color(0xFF1A1F3A),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                '${items.length} item${items.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 13),
              ),
              const Spacer(),
              _controlBtn(
                icon: qp.isPaused
                    ? Icons.play_arrow
                    : Icons.pause,
                label: qp.isPaused ? 'Resume' : 'Pause',
                color: qp.isPaused
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                onTap: qp.isPaused
                    ? qp.resumeQueue
                    : qp.pauseQueue,
              ),
              const SizedBox(width: 8),
              _controlBtn(
                icon: Icons.clear_all,
                label: 'Clear Done',
                color: const Color(0xFF888888),
                onTap: qp.clearCompleted,
              ),
            ],
          ),
        ),

        if (qp.isPaused && qp.rateLimitRetrySeconds > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: const Color(0xFF2A1A0A),
            child: Text(
              '⏳ Rate limited — retrying in ${qp.rateLimitRetrySeconds}s',
              style: const TextStyle(
                  color: Color(0xFFFF9800), fontSize: 12),
            ),
          ),

        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.queue_music,
                          color: Color(0xFF444444),
                          size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Queue is empty.\nAdd text from the Studio tab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return _QueueTile(
                      item: item,
                      statusColor:
                          _statusColor(item.status),
                      statusIcon: _statusIcon(item.status),
                      onRemove: () =>
                          qp.removeItem(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final TtsItem item;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onRemove;

  const _QueueTile({
    required this.item,
    required this.statusColor,
    required this.statusIcon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.status == TtsStatus.processing
              ? const Color(0xFF00D9FF)
              : const Color(0xFF444444),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.status == TtsStatus.processing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00D9FF),
                  ),
                )
              : Icon(statusIcon,
                  color: statusColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.text.length > 80
                      ? '${item.text.substring(0, 80)}…'
                      : item.text,
                  style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.status.name.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.voice} | ${item.format.toUpperCase()}',
                      style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 10),
                    ),
                  ],
                ),
                if (item.errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4),
                    child: Text(item.errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFF44336),
                            fontSize: 10)),
                  ),
                if (item.tags.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4),
                    child: Text(
                        'Tags: ${item.tags.join(', ')}',
                        style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10)),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: Color(0xFF888888), size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
