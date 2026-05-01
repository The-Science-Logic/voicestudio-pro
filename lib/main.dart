import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme_constants.dart';
import 'providers/queue_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/history_provider.dart';
import 'providers/library_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceStudioProApp());
}

class VoiceStudioProApp extends StatelessWidget {
  const VoiceStudioProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: MaterialApp(
        title: 'VoiceStudio Pro',
        theme: ThemeConstants.darkTheme(),
        home: const MainTabScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const QueueScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VoiceStudio Pro',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ThemeConstants.accentCyan,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _buildApiStatusIndicator(),
          ],
        ),
      ),
      body: _screens[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audio_file),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Model',
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatusIndicator() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        bool isApiKeyValid = settingsProvider.apiKey.isNotEmpty &&
            settingsProvider.apiKey.length > 10;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isApiKeyValid
                ? ThemeConstants.statusComplete.withOpacity(0.2)
                : ThemeConstants.statusProcessing.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isApiKeyValid
                  ? ThemeConstants.successGreen
                  : ThemeConstants.warningOrange,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isApiKeyValid ? Icons.check_circle : Icons.error,
                size: 16,
                color: isApiKeyValid
                    ? ThemeConstants.successGreen
                    : ThemeConstants.warningOrange,
              ),
              SizedBox(width: 6),
              Text(
                isApiKeyValid ? 'Connected' : 'Invalid Key',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isApiKeyValid
                      ? ThemeConstants.successGreen
                      : ThemeConstants.warningOrange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
