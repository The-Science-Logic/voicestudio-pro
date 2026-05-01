import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../constants/theme_constants.dart';

class QueueButtonRow extends StatelessWidget {
  const QueueButtonRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, queueProvider, _) {
        final isProcessing = queueProvider.isProcessing;
        final queue = queueProvider.queue;
        final hasItems = queue.isNotEmpty;

        return Container(
          color: ThemeConstants.cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasItems && !isProcessing
                      ? () => queueProvider.processQueue()
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(isProcessing ? 'Processing...' : 'Play Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isProcessing
                        ? ThemeConstants.accentColor.withOpacity(0.5)
                        : ThemeConstants.accentColor,
                    foregroundColor: ThemeConstants.backgroundColor,
                    disabledBackgroundColor: ThemeConstants.unfocusedBorderColor,
                    disabledForegroundColor: ThemeConstants.secondaryTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasItems ? () => queueProvider.clearQueue() : null,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.destructiveColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ThemeConstants.unfocusedBorderColor,
                    disabledForegroundColor: ThemeConstants.secondaryTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasItems ? () => queueProvider.pauseQueue() : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.warningColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ThemeConstants.unfocusedBorderColor,
                    disabledForegroundColor: ThemeConstants.secondaryTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
