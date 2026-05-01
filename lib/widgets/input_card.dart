import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/theme_constants.dart';

class InputCard extends StatefulWidget {
  final TextEditingController sceneDirectionController;
  final TextEditingController sampleContextController;
  final TextEditingController textToConvertController;
  final TextEditingController saveAsController;
  final VoidCallback onAddToQueue;
  final VoidCallback? onHistoryItemTapped;

  const InputCard({
    Key? key,
    required this.sceneDirectionController,
    required this.sampleContextController,
    required this.textToConvertController,
    required this.saveAsController,
    required this.onAddToQueue,
    this.onHistoryItemTapped,
  }) : super(key: key);

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> {
  late FocusNode sceneDirectionFocus;
  late FocusNode sampleContextFocus;
  late FocusNode textToConvertFocus;
  late FocusNode saveAsFocus;

  @override
  void initState() {
    super.initState();
    sceneDirectionFocus = FocusNode();
    sampleContextFocus = FocusNode();
    textToConvertFocus = FocusNode();
    saveAsFocus = FocusNode();

    _loadSavedInputs();
  }

  Future<void> _loadSavedInputs() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final savedSceneDirection = await settingsProvider.getSceneDirection();
    final savedSampleContext = await settingsProvider.getSampleContext();

    widget.sceneDirectionController.text = savedSceneDirection;
    widget.sampleContextController.text = savedSampleContext;
  }

  void _saveInputsOnChange() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.saveSceneDirection(widget.sceneDirectionController.text);
    settingsProvider.saveSampleContext(widget.sampleContextController.text);
  }

  @override
  void dispose() {
    sceneDirectionFocus.dispose();
    sampleContextFocus.dispose();
    textToConvertFocus.dispose();
    saveAsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemeConstants.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Scene Direction',
                hintText: 'E.g., Dramatic, whispered intro...',
                controller: widget.sceneDirectionController,
                focusNode: sceneDirectionFocus,
                maxLines: 3,
                onChanged: (_) => _saveInputsOnChange(),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                label: 'Sample Context',
                hintText: 'E.g., Character background, mood...',
                controller: widget.sampleContextController,
                focusNode: sampleContextFocus,
                maxLines: 6,
                onChanged: (_) => _saveInputsOnChange(),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                label: 'Text to Convert',
                hintText: 'Paste or type your text here...',
                controller: widget.textToConvertController,
                focusNode: textToConvertFocus,
                maxLines: 12,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                label: 'Save As',
                hintText: 'E.g., scene_01_intro.mp3',
                controller: widget.saveAsController,
                focusNode: saveAsFocus,
                maxLines: 1,
                onChanged: (_) {},
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onAddToQueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.accentColor,
                    foregroundColor: ThemeConstants.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Add to Queue',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: ThemeConstants.backgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int maxLines,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: ThemeConstants.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {});
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeConstants.primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
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
        ),
      ],
    );
  }
}
