import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/queue_provider.dart';
import 'services/storage_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  await storageService.deleteOldFiles();
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProxyProvider<StorageService, QueueProvider>(
          create: (ctx) => QueueProvider(storageService),
          update: (ctx, storage, prev) => prev ?? QueueProvider(storage),
        ),
      ],
      child: const VoiceStudioApp(),
    ),
  );
}

class VoiceStudioApp extends StatelessWidget {
  const VoiceStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceStudio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0A0E27),
          primary: Color(0xFF00D9FF),
          secondary: Color(0xFF00D9FF),
          error: Color(0xFFF44336),
        ),
        cardColor: const Color(0xFF1A1F3A),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1F3A),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF444444)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF00D9FF), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
          hintStyle: const TextStyle(color: Color(0xFF888888)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D9FF),
            foregroundColor: const Color(0xFF0A0E27),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFF00D9FF),
          unselectedLabelColor: Color(0xFF888888),
          indicatorColor: Color(0xFF00D9FF),
        ),
        dividerColor: const Color(0xFF444444),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'VoiceStudio Pro',
          style: TextStyle(
              color: Color(0xFF00D9FF), fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.mic), text: 'Studio'),
            Tab(icon: Icon(Icons.queue_music), text: 'Queue'),
            Tab(icon: Icon(Icons.library_music), text: 'Library'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardScreen(),
          QueueScreen(),
          LibraryScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
