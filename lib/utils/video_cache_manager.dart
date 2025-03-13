import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  static const String _prefKey = 'cached_videos';
  Directory? _cacheDir;
  SharedPreferences? _prefs;
  final Map<String, String> _cacheMap = {};
  bool _initialized = false;
  bool _isInitializing = false;

  Future<void> initialize() async {
    // Skip initialization if already done or in progress
    if (_initialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Skip actual filesystem operations on web
      if (kIsWeb) {
        _initialized = true;
        _isInitializing = false;
        debugPrint(
            'VideoCacheManager initialized for web (limited functionality)');
        return;
      }

      try {
        _cacheDir = await getTemporaryDirectory();
      } catch (e) {
        debugPrint('Error getting temporary directory: $e');
        // Fall back to application documents directory if available
        try {
          _cacheDir = await getApplicationDocumentsDirectory();
        } catch (e) {
          debugPrint('Error getting application documents directory: $e');
          // No directory available, set initialization state but don't crash
          _initialized = true;
          _isInitializing = false;
          return;
        }
      }

      _prefs = await SharedPreferences.getInstance();
      final cachedVideos = _prefs?.getStringList(_prefKey) ?? [];

      for (final entry in cachedVideos) {
        try {
          final parts = entry.split('||');
          if (parts.length == 2) {
            final url = parts[0];
            final path = parts[1];
            // Verify if file still exists
            final file = File(path);
            if (await file.exists()) {
              _cacheMap[url] = path;
            }
          }
        } catch (e) {
          debugPrint('Error parsing cache entry: $e');
        }
      }

      _initialized = true;
      debugPrint('Video cache initialized with ${_cacheMap.length} entries');
    } catch (e) {
      debugPrint('Error initializing video cache: $e');
      // Still mark as initialized so we don't keep trying to initialize
      _initialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> getCachedVideoPath(String url) async {
    await initialize();

    // Web doesn't support file caching
    if (kIsWeb) return null;

    // Check if URL is in cache map
    if (_cacheMap.containsKey(url)) {
      final path = _cacheMap[url];
      if (path == null) return null;

      final file = File(path);
      if (await file.exists()) {
        debugPrint('Cache hit for video: $url');
        return path;
      } else {
        // File doesn't exist anymore, remove from cache
        _cacheMap.remove(url);
        _saveCache();
      }
    }

    return null;
  }

  Future<String?> cacheVideo(String url) async {
    await initialize();

    // Web doesn't support file caching
    if (kIsWeb) return null;

    try {
      // Check if cache directory exists
      if (_cacheDir == null) {
        debugPrint('Cache directory is null, cannot cache video');
        return null;
      }

      // Check if already cached
      final existingPath = await getCachedVideoPath(url);
      if (existingPath != null) {
        return existingPath;
      }

      // Generate a unique filename for this video
      final cacheKey = _generateCacheKey(url);
      final fileExt = url.split('.').last.split('?').first;
      final fileName = '$cacheKey.$fileExt';
      final filePath = '${_cacheDir!.path}/$fileName';

      // Download video to cache
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Add to cache map
        _cacheMap[url] = filePath;
        _saveCache();

        debugPrint('Video cached successfully: $url');
        return filePath;
      }
    } catch (e) {
      debugPrint('Error caching video: $e');
    }

    return null;
  }

  void _saveCache() async {
    if (kIsWeb || _prefs == null) return;

    final entries =
        _cacheMap.entries.map((e) => '${e.key}||${e.value}').toList();
    await _prefs!.setStringList(_prefKey, entries);
  }

  Future<void> clearCache() async {
    await initialize();

    if (kIsWeb) return;

    for (final path in _cacheMap.values) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting cached file: $e');
      }
    }

    _cacheMap.clear();
    await _prefs?.remove(_prefKey);
    debugPrint('Video cache cleared');
  }
}
