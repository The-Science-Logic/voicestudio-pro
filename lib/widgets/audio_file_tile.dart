import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file_model.dart';
import '../providers/library_provider.dart';
import '../constants/theme_constants.dart';
import 'dart:io';

class AudioFileTile extends StatefulWidget {
  final AudioFileModel audioFile;
  final VoidCallback onRefresh;

  const AudioFileTile({
    Key? key,
    required this.audioFile,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AudioFileTile> createState() => _AudioFileTileState();
}

class _AudioFileTileState extends State<AudioFileTile> {
  bool isPlaying = false;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: ThemeConstants.unfocusedBorderColor,
              width: 1.0,
            ),
          ),
          title: Text(
            'Delete File?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ThemeConstants.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This action cannot be undone. The file "${widget.audioFile.fileName}" will be permanently removed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeConstants.primaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ThemeConstants.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final libraryProvider = Provider.of<LibraryProvider>(
                  context,
                  listen: false,
                );
                await libraryProvider.deleteAudioFile(widget.audioFile.id);
                Navigator.pop(dialogContext);
                widget.onRefresh();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File deleted: ${widget.audioFile.fileName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: ThemeConstants.destructiveColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ThemeConstants.destructiveColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSavePermanentlyDialog(BuildContext context) {
    final TextEditingController newNameController = TextEditingController(
      text: widget.audioFile.fileName,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: ThemeConstants.unfocusedBorderColor,
              width: 1.0,
            ),
          ),
          title: Text(
            'Save Permanently',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ThemeConstants.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a new filename:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConstants.primaryTextColor,
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: newNameController,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConstants.primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'E.g., my_audio_final.mp3',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConstants.secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: ThemeConstants.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: ThemeConstants.unfocusedBorderColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: ThemeConstants.accentColor,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ThemeConstants.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newFileName = newNameController.text.trim();
                if (newFileName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Filename cannot be empty.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: ThemeConstants.destructiveColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                final libraryProvider = Provider.of<LibraryProvider>(
                  context,
                  listen: false,
                );
                await libraryProvider.savePermanently(
                  widget.audioFile.id,
                  newFileName,
                );
                Navigator.pop(dialogContext);
                widget.onRefresh();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File saved permanently: $newFileName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: ThemeConstants.successColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ThemeConstants.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.audioFile.duration ?? 'Unknown';
    final createdAt = _formatDateTime(widget.audioFile.createdAt);
    final isTempStorage = !widget.audioFile.isPermanent;
    final storageLabel = isTempStorage ? '⏱️ Temp (48h)' : '✓ Permanent';

    return Card(
      color: ThemeConstants.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(
          color: ThemeConstants.unfocusedBorderColor,
          width: 1.0,
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
                        widget.audioFile.fileName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ThemeConstants.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isTempStorage
                                  ? ThemeConstants.warningColor.withOpacity(0.15)
                                  : ThemeConstants.successColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              storageLabel,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isTempStorage
                                    ? ThemeConstants.warningColor
                                    : ThemeConstants.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Duration: $duration',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ThemeConstants.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Created: $createdAt',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ThemeConstants.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 16.0,
                    ),
                    label: Text(
                      isPlaying ? 'Pause' : 'Play',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.accentColor,
                      foregroundColor: ThemeConstants.backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSavePermanentlyDialog(context),
                    icon: const Icon(Icons.save, size: 16.0),
                    label: Text(
                      'Save',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete, size: 16.0),
                    label: Text(
                      'Delete',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.destructiveColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
