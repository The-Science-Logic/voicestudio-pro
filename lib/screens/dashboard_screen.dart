import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/global_header.dart';
import '../widgets/input_card.dart';
import '../widgets/queue_button_row.dart';
import '../widgets/history_panel.dart';
import '../constants/theme_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late TextEditingController sceneDirectionController;
  late TextEditingController sampleContextController;
  late TextEditingController textToConvertController;
  late TextEditingController saveAsController;

  @override
  void initState() {
    super.initState();
    sceneDirectionController = TextEditingController();
    sampleContextController = TextEditingController();
    textToConvertController = TextEditingController();
    saveAsController = TextEditingController();
  }

  @override
  void dispose() {
    sceneDirectionController.dispose();
    sampleContextController.dispose();
    textToConvertController.dispose();
    saveAsController.dispose();
    super.dispose();
  }

  Future<void> _addToQueue() async {
    final textToConvert = textToConvertController.text.trim();
    final saveAs = saveAsController.text.trim();
    final sceneDirection = sceneDirectionController.text.trim();
    final sampleContext = sampleContextController.text.trim();

    if (textToConvert.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter text to convert.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: ThemeConstants.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (saveAs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a filename.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: ThemeConstants.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    await queueProvider.addToQueue(
      text: textToConvert,
      fileName: saveAs,
      sceneDirection: sceneDirection,
      sampleContext: sampleContext,
    );

    await historyProvider.addToHistory(textToConvert);

    textToConvertController.clear();
    saveAsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added to queue: $saveAs',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _fillFromHistory(String historyText) {
    textToConvertController.text = historyText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: const GlobalHeader(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InputCard(
              sceneDirectionController: sceneDirectionController,
              sampleContextController: sampleContextController,
              textToConvertController: textToConvertController,
              saveAsController: saveAsController,
              onAddToQueue: _addToQueue,
              onHistoryItemTapped: _fillFromHistory,
            ),
            QueueButtonRow(),
            HistoryPanel(
              onHistoryItemSelected: _fillFromHistory,
            ),
          ],
        ),
      ),
    );
  }
}
