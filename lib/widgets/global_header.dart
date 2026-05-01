import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/theme_constants.dart';

class GlobalHeader extends StatelessWidget {
  const GlobalHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final isApiKeyValid = settingsProvider.isApiKeyValid();
        final statusColor = isApiKeyValid ? ThemeConstants.successColor : ThemeConstants.destructiveColor;
        final statusText = isApiKeyValid ? 'Connected' : 'Invalid Key';

        return Container(
          decoration: BoxDecoration(
            color: ThemeConstants.cardColor,
            border: Border(
              bottom: BorderSide(
                color: ThemeConstants.focusBorderColor,
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VoiceStudio Pro',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ThemeConstants.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Gemini 3.1 Flash TTS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ThemeConstants.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  border: Border.all(
                    color: statusColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
