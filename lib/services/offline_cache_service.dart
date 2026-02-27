import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_model.dart';

/// Caches the last known energy reading to SharedPreferences so the dashboard
/// can display data even when the device is offline.
class OfflineCacheService {
  static const _readingKey = 'cached_reading_METER001';
  static const _timestampKey = 'cached_reading_ts';

  /// Save a live reading to local cache.
  static Future<void> saveReading(ReadingModel reading) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_readingKey, jsonEncode(reading.toMap()));
      await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  /// Load the last cached reading. Returns null if nothing has been saved yet.
  static Future<ReadingModel?> loadReading() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_readingKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReadingModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// When the cached reading was last saved (human-readable "X min ago").
  static Future<String> cacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getString(_timestampKey);
      if (ts == null) return 'unknown';
      final saved = DateTime.parse(ts);
      final diff = DateTime.now().difference(saved);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (_) {
      return 'unknown';
    }
  }
}
