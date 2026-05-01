import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../constants/theme_constants.dart';

class HistoryPanel extends StatefulWidget {
  final Function(String) onHistoryItemSelected;

  const HistoryPanel({
    Key? key,
    required this.onHistoryItemSelected,
  }) : super(key: key);

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        final historyList = historyProvider.history;

        return Container(
          color: ThemeConstants.cardColor,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ThemeConstants.unfocusedBorderColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: ThemeConstants.accentColor,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'History (${historyList.length}/30)',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: ThemeConstants.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: ThemeConstants.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Container(
                  constraints: const BoxConstraints(maxHeight
