import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> _voices = [
    'Puck', 'Charon', 'Kore', 'Fenrir',
    'Aoede', 'Leda', 'Orus', 'Zephyr',
  ];

  static const List<String> _availableTags = [
    'Narration', 'Dialogue', 'News', 'Educational',
    'Podcast', 'Story', 'Commercial', 'Training',
  ];

  late List<TextEditingController> _keyControllers;
  late String _selectedVoice;
  late String _selectedFormat;
  late List<String> _selectedTags;
  late int _activeKeyIndex;
  final List<bool> _keyObscured = [true, true, true];
  final List<bool?> _keyStatus = [null, null, null];
  bool _testing = false;
  int _testingIndex = -1;

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    final keys = storage.getApiKeys();
    _keyControllers = List.generate(
      3,
      (i) => TextEditingController(
          text: i < keys.length ? keys[i] : ''),
    );
    _selectedVoice = storage.getVoice();
    _selectedFormat = storage.getFormat();
    _selectedTags = List.from(storage.getTags());
    _activeKeyIndex = storage.getActiveKeyIndex();
  }

  @override
  void dispose() {
    for (final c in _keyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final storage = context.read<StorageService>();
    final keys =
        _keyControllers.map((c) => c.text.trim()).toList();
    await storage.saveApiKeys(keys);
    await storage.saveVoice(_selectedVoice);
    await storage.saveFormat(_selectedFormat);
    await storage.saveTags(_selectedTags);
    final nonEmptyCount =
        keys.where((k) => k.isNotEmpty).length;
    final validIndex = _activeKeyIndex < nonEmptyCount
        ? _activeKeyIndex
        : 0;
    await storage.setActiveKeyIndex(validIndex);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _testKey(int index) async {
    final key = _keyControllers[index].text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter an API key first'),
          backgroundColor: Color(0xFFF44336),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _testing = true;
      _testingIndex = index;
      _keyStatus[index] = null;
    });
    final ok = await ApiService().testApiKey(key);
    if (mounted) {
      setState(() {
        _testing = false;
        _testingIndex = -1;
        _keyStatus[index] = ok;
      });
    }
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}…${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('API Keys (up to 3)'),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF00D9FF)),
            ),
            child: const Text(
              '💡 Add up to 3 keys to rotate and maximize free-tier usage (~50 requests/day per key).',
              style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11),
            ),
          ),
          ...List.generate(3, _apiKeyRow),
          const SizedBox(height: 10),

          _sectionLabel('Active Key'),
          DropdownButtonFormField<int>(
            value: _activeKeyIndex,
            dropdownColor: const Color(0xFF1A1F3A),
            style: const TextStyle(
                color: Color(0xFFE0E0E0)),
            decoration: const InputDecoration(),
            items: List.generate(3, (i) {
              final key =
                  _keyControllers[i].text.trim();
              final label = key.isEmpty
                  ? 'Key ${i + 1} — (empty)'
                  : 'Key ${i + 1}: ${_maskKey(key)}';
              return DropdownMenuItem(
                  value: i, child: Text(label));
            }),
            onChanged: (v) {
              if (v != null) {
                setState(() => _activeKeyIndex = v);
              }
            },
          ),
          const SizedBox(height: 16),

          _sectionLabel('Voice Profile'),
          DropdownButtonFormField<String>(
            value: _selectedVoice,
            dropdownColor: const Color(0xFF1A1F3A),
            style: const TextStyle(
                color: Color(0xFFE0E0E0)),
            decoration: const InputDecoration(),
            items: _voices
                .map((v) => DropdownMenuItem(
                    value: v, child: Text(v)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedVoice = v);
              }
            },
          ),
          const SizedBox(height: 16),

          _sectionLabel('Audio Format'),
          Row(
            children: [
              _formatRadio('mp3', 'MP3'),
              const SizedBox(width: 24),
              _formatRadio('wav', 'WAV'),
            ],
          ),
          const SizedBox(height: 16),

          _sectionLabel('Audio Tags'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _availableTags.map((tag) {
              final selected =
                  _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0A0E27)
                          : const Color(0xFFE0E0E0),
                      fontSize: 12,
                    )),
                selected: selected,
                selectedColor:
                    const Color(0xFF00D9FF),
                backgroundColor:
                    const Color(0xFF1A1F3A),
                checkmarkColor:
                    const Color(0xFF0A0E27),
                side: const BorderSide(
                    color: Color(0xFF444444)),
                onSelected: (val) => setState(() {
                  val
                      ? _selectedTags.add(tag)
                      : _selectedTags.remove(tag);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Settings',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _apiKeyRow(int index) {
    final status = _keyStatus[index];
    final isTesting =
        _testing && _testingIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == null
              ? const Color(0xFF444444)
              : status
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Key ${index + 1}',
                  style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (status != null) ...[
                Icon(
                  status
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: status
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  status ? 'Connected' : 'Failed',
                  style: TextStyle(
                      color: status
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      fontSize: 11),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyControllers[index],
            obscureText: _keyObscured[index],
            style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Paste API key here…',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _keyObscured[index]
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF888888),
                      size: 18,
                    ),
                    onPressed: () => setState(() =>
                        _keyObscured[index] =
                            !_keyObscured[index]),
                  ),
                  isTesting
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Color(0xFF00D9FF),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                              Icons.wifi_tethering,
                              color: Color(0xFF00D9FF),
                              size: 18),
                          tooltip: 'Test connection',
                          onPressed: () =>
                              _testKey(index),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatRadio(String value, String label) {
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedFormat = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedFormat,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedFormat = v);
              }
            },
            activeColor: const Color(0xFF00D9FF),
          ),
          Text(label,
              style: TextStyle(
                color: _selectedFormat == value
                    ? const Color(0xFF00D9FF)
                    : const Color(0xFFE0E0E0),
                fontSize: 14,
              )),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}
