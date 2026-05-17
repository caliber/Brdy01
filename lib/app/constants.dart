abstract class AppConstants {
  static const String golfApiBaseUrl = 'https://api.golfcourseapi.com/v1';
  static const String golfApiKey = String.fromEnvironment('GOLF_API_KEY');
  static const String playerPrefsBox = 'player_prefs';
  static const String courseCacheBox  = 'course_cache';
  static const int maxRoundHoles = 18;
  static const int whsDifferentialsToStore = 20;
  static const int whsBestDifferentials = 8;
  static const String tileCacheStoreName = 'brdy_tiles';
}
