import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final AudioPlayer _player = AudioPlayer();
  String? _playingPath;
  List<File> _tempFiles = [];
  List<File> _permFiles = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
    _loadFiles();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final storage = context.read<StorageService>();
    final temp = await storage.listTempFiles();
    final perm = await storage.listPermanentFiles();
    if (mounted) {
      setState(() {
        _tempFiles = temp;
        _permFiles = perm;
      });
    }
  }

  Future<void> _togglePlay(String path) async {
    if (_playingPath == path) {
      await _player.stop();
      setState(() => _playingPath = null);
    } else {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      setState(() => _playingPath = path);
    }
  }

  Future<void> _makePermanent(String path) async {
    final storage = context.read<StorageService>();
    try {
      await storage.makeAudioPermanent(path);
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved permanently'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  Future<void> _delete(String path) async {
    final storage = context.read<StorageService>();
    if (_playingPath == path) {
      await _player.stop();
      setState(() => _playingPath = null);
    }
    await storage.deleteAudioFile(path);
    await _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF1A1F3A),
          child: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Temporary (48h)'),
              Tab(text: 'Permanent'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildFileList(
                files: _tempFiles,
                isPermanent: false,
              ),
              _buildFileList(
                files: _permFiles,
                isPermanent: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileList({
    required List<File> files,
    required bool isPermanent,
  }) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPermanent
                  ? Icons.folder_special
                  : Icons.audio_file,
              color: const Color(0xFF444444),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isPermanent
                  ? 'No permanent files.\nSave a temporary file to keep it.'
                  : 'No audio files yet.\nGenerate audio from the Studio tab.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFiles,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      color: const Color(0xFF00D9FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: files.length,
        itemBuilder: (ctx, i) {
          final file = files[i];
          final name = file.uri.pathSegments.last;
          final isPlaying = _playingPath == file.path;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPlaying
                    ? const Color(0xFF00D9FF)
                    : const Color(0xFF444444),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      FutureBuilder<FileStat>(
                        future: file.stat(),
                        builder: (ctx, snap) {
                          if (!snap.hasData) {
                            return const SizedBox
                                .shrink();
                          }
                          final size =
                              (snap.data!.size / 1024)
                                  .toStringAsFixed(1);
                          final mod = snap.data!.modified
                              .toLocal()
                              .toString()
                              .substring(0, 16);
                          return Text(
                            '${size}KB • $mod',
                            style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 10),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.stop_circle
                        : Icons.play_circle,
                    color: const Color(0xFF00D9FF),
                    size: 28,
                  ),
                  onPressed: () =>
                      _togglePlay(file.path),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (!isPermanent) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.save_alt,
                        color: Color(0xFF4CAF50),
                        size: 22),
                    onPressed: () =>
                        _makePermanent(file.path),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Save permanently',
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFF44336), size: 22),
                  onPressed: () => _delete(file.path),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
