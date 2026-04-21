import 'package:firebase_analytics/firebase_analytics.dart';

// Wrapping FirebaseAnalytics in its own service class means the rest of
// the app doesn't depend directly on Firebase - if we ever swap it out
// for something else we only change this file.
//
// To fully activate: add google-services.json (Android) and
// GoogleService-Info.plist (iOS) after setting up a Firebase project.

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  static Future<void> logEntrySaved() async {
    await _analytics.logEvent(name: 'entry_saved');
  }

  static Future<void> logEntryDeleted() async {
    await _analytics.logEvent(name: 'entry_deleted');
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
