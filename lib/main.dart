import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/journal_entry.dart';
import 'providers/journal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'services/analytics_service.dart';
import 'firebase_options.dart';

// Keeping this global so home_screen can access it without passing it down
// through constructors. Could use a service locator but this is fine for now.
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  await _initNotifications();

  // Firebase init - will throw if google-services.json isn't added yet,
  // so wrapping in try/catch during development
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => JournalProvider(),
      child: const PhotoJournalApp(),
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await Hive.openBox<JournalEntry>('journal_entries');
}

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await notificationsPlugin.initialize(initSettings);
}

class PhotoJournalApp extends StatelessWidget {
  const PhotoJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Journal',
      debugShowCheckedModeBanner: false,
      // Analytics observer so Firebase auto-tracks screen transitions
      navigatorObservers: [AnalyticsService.getObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // IndexedStack keeps both screens alive so the gallery doesn't
  // reload every time you switch tabs
  final List<Widget> _screens = const [
    HomeScreen(),
    GalleryScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    final screenName = index == 0 ? 'home_screen' : 'gallery_screen';
    AnalyticsService.logScreenView(screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_photo_alternate_outlined),
            selectedIcon: Icon(Icons.add_photo_alternate),
            label: 'New Entry',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
      ),
    );
  }
}
