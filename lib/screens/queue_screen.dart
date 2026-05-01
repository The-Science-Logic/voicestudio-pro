import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../models/queue_item_model.dart';
import '../widgets/global_header.dart';
import '../constants/theme_constants.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: const GlobalHeader(),
      ),
      body: Consumer<QueueProvider>(
        builder: (context, queueProvider, _) {
          final queue = queueProvider.queue;
          final isProcessing = queueProvider.isProcessing;
          final isPaused = queueProvider.isPaused;
          final estimatedDailyLimit =
              queueProvider.estimatedDailyApiCallsRemaining;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: ThemeConstants.cardColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Queue Status',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: ThemeConstants.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isProcessing
                                          ? ThemeConstants.accentColor
                                              .withOpacity(0.15)
                                          : isPaused
                                              ? ThemeConstants.warningColor
                                                  .withOpacity(0.15)
                                              : ThemeConstants.successColor
                                                  .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      isProcessing
                                          ? 'Processing'
                                          : isPaused
                                              ? 'Paused'
                                              : 'Ready',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isProcessing
                                                ? ThemeConstants.accentColor
                                                : isPaused
                                                    ? ThemeConstants
                                                        .warningColor
                                                    : ThemeConstants
                                                        .successColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Text(
                                    'Items: ${queue.length}/20',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: ThemeConstants
                                              .primaryTextColor,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ThemeConstants.accentColor
                                  .withOpacity(0.15),
                              border: Border.all(
                                color: ThemeConstants.accentColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Daily Limit Est.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: ThemeConstants
                                            .secondaryTextColor,
                                      ),
                                ),
                                Text(
                                  '$estimatedDailyLimit calls',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: ThemeConstants.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (queue.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 40.0,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.queue_music,
                            color: ThemeConstants.secondaryTextColor,
                            size: 64.0,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Queue is empty',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: ThemeConstants.secondaryTextColor,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Go to Dashboard and add items to get started.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: ThemeConstants.secondaryTextColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      final isCurrentlyProcessing =
                          index == 0 && isProcessing;

                      return _buildQueueItemTile(
                        context,
                        item,
                        index,
                        isCurrentlyProcessing,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueueItemTile(
    BuildContext context,
    QueueItemModel item,
    int index,
    bool isCurrentlyProcessing,
  ) {
    String statusLabel = '';
    Color statusColor = ThemeConstants.secondaryTextColor;
    IconData statusIcon = Icons.schedule;

    if (isCurrentlyProcessing) {
      statusLabel = 'Processing...';
      statusColor = ThemeConstants.accentColor;
      statusIcon = Icons.autorenew;
    } else if (item.status == 'completed') {
      statusLabel = 'Completed';
      statusColor = ThemeConstants.successColor;
      statusIcon = Icons.check_circle;
    } else if (item.status == 'failed') {
      statusLabel = 'Failed';
      statusColor = ThemeConstants.destructiveColor;
      statusIcon = Icons.error;
    } else if (item.status == 'pending') {
      statusLabel = 'Pending';
      statusColor = ThemeConstants.warningColor;
      statusIcon = Icons.schedule;
    }

    return Card(
      color: ThemeConstants.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isCurrentlyProcessing
              ? ThemeConstants.accentColor
              : ThemeConstants.unfocusedBorderColor,
          width: isCurrentlyProcessing ? 2.0 : 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${index + 1} – ${item.fileName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ThemeConstants.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        item.text.length > 80
                            ? '${item.text.substring(0, 80)}...'
                            : item.text,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 14.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        statusLabel,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isCurrentlyProcessing) ...[
              const SizedBox(height: 12.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: ThemeConstants.unfocusedBorderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeConstants.accentColor,
                  ),
                  minHeight: 6.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${(item.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ThemeConstants.secondaryTextColor,
                ),
              ),
            ],
            if (item.errorMessage != null && item.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: ThemeConstants.destructiveColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.all(8.0
