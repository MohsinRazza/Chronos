import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:http/http.dart' as http;
import '../config/google_oauth_config.dart';
import '../models/event.dart' as local;

class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  AuthClient? _client;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  String? _userPicture;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPicture => _userPicture;

  final ClientId _clientId = ClientId(
    GoogleOAuthConfig.clientId,
    GoogleOAuthConfig.clientSecret,
  );

  final List<String> _scopes = [
    CalendarApi.calendarScope,
    Oauth2Api.userinfoEmailScope,
    Oauth2Api.userinfoProfileScope,
  ];

  // Callback to notify UI of state updates
  VoidCallback? onStateChanged;

  Future<void> initialize() async {
    await trySilentLogin();
  }

  Future<bool> login() async {
    if (GoogleOAuthConfig.clientId.isEmpty) {
      debugPrint('Google Client ID is empty. Please configure google_oauth_config.dart');
      return false;
    }
    try {
      final client = await clientViaUserConsent(
        _clientId,
        _scopes,
        (url) async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );

      _client = client;
      _isAuthenticated = true;

      // Handle token refreshes
      client.credentialUpdates.listen((AccessCredentials newCreds) async {
        await _saveCredentials(newCreds);
      });

      // Fetch user profile info
      await _fetchProfileInfo();

      // Save credentials for future launches
      await _saveCredentials(client.credentials);

      // Save login session timestamp (15 days check)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_login_time', DateTime.now().toIso8601String());

      if (onStateChanged != null) onStateChanged!();
      return true;
    } catch (e) {
      debugPrint('Google login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _client?.close();
    _client = null;
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _userPicture = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_credentials');
    await prefs.remove('google_user_email');
    await prefs.remove('google_user_name');
    await prefs.remove('google_user_picture');
    await prefs.remove('google_login_time');

    if (onStateChanged != null) onStateChanged!();
  }

  Future<void> trySilentLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final credsJson = prefs.getString('google_credentials');
    if (credsJson == null) return;

    if (GoogleOAuthConfig.clientId.isEmpty) {
      return;
    }

    // Check 15-day session expiration
    final loginTimeStr = prefs.getString('google_login_time');
    if (loginTimeStr != null) {
      try {
        final loginTime = DateTime.parse(loginTimeStr);
        final difference = DateTime.now().difference(loginTime);
        if (difference.inDays >= 15) {
          debugPrint('Google session expired (older than 15 days). Logging out.');
          await logout();
          return;
        }
      } catch (e) {
        debugPrint('Error parsing google_login_time: $e');
      }
    }

    try {
      final credsMap = json.decode(credsJson) as Map<String, dynamic>;
      final creds = _credentialsFromJson(credsMap);

      final baseClient = http.Client();
      final client = autoRefreshingClient(_clientId, creds, baseClient);

      // Handle token refreshes
      client.credentialUpdates.listen((AccessCredentials newCreds) async {
        await _saveCredentials(newCreds);
      });

      _client = client;
      _isAuthenticated = true;

      // Load cached profile info
      _userEmail = prefs.getString('google_user_email');
      _userName = prefs.getString('google_user_name');
      _userPicture = prefs.getString('google_user_picture');

      // Fetch fresh profile in background
      _fetchProfileInfo();

      if (onStateChanged != null) onStateChanged!();
    } catch (e) {
      debugPrint('Google silent login error: $e');
      await logout();
    }
  }

  Future<void> _fetchProfileInfo() async {
    if (_client == null) return;
    try {
      final oauth2 = Oauth2Api(_client!);
      final userInfo = await oauth2.userinfo.get();
      _userEmail = userInfo.email;
      _userName = userInfo.name;
      _userPicture = userInfo.picture;

      final prefs = await SharedPreferences.getInstance();
      if (_userEmail != null) await prefs.setString('google_user_email', _userEmail!);
      if (_userName != null) await prefs.setString('google_user_name', _userName!);
      if (_userPicture != null) await prefs.setString('google_user_picture', _userPicture!);

      if (onStateChanged != null) onStateChanged!();
    } catch (e) {
      debugPrint('Error fetching Google profile: $e');
    }
  }

  Future<void> _saveCredentials(AccessCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    final credsMap = _credentialsToJson(credentials);
    await prefs.setString('google_credentials', json.encode(credsMap));
  }

  Map<String, dynamic> _credentialsToJson(AccessCredentials credentials) {
    return {
      'accessToken': {
        'data': credentials.accessToken.data,
        'expiry': credentials.accessToken.expiry.toIso8601String(),
        'type': credentials.accessToken.type,
      },
      'refreshToken': credentials.refreshToken,
      'scopes': credentials.scopes,
    };
  }

  AccessCredentials _credentialsFromJson(Map<String, dynamic> json) {
    final tokenJson = json['accessToken'] as Map<String, dynamic>;
    final accessToken = AccessToken(
      tokenJson['type'] as String,
      tokenJson['data'] as String,
      DateTime.parse(tokenJson['expiry'] as String).toUtc(),
    );
    return AccessCredentials(
      accessToken,
      json['refreshToken'] as String?,
      (json['scopes'] as List<dynamic>).cast<String>(),
    );
  }

  // --- GOOGLE CALENDAR API INTERACTION ---

  Future<List<local.CalendarEvent>> fetchGoogleEvents() async {
    if (_client == null || !_isAuthenticated) return [];
    final calendarApi = CalendarApi(_client!);
    final events = await calendarApi.events.list(
      'primary',
      maxResults: 250,
      timeMin: DateTime.now().subtract(const Duration(days: 30)).toUtc(),
    );

    final list = events.items ?? [];
    return list.map((e) => _mapGoogleEventToLocal(e)).toList();
  }

  Future<local.CalendarEvent?> pushEvent(local.CalendarEvent lEvent) async {
    if (_client == null || !_isAuthenticated) return null;
    try {
      final calendarApi = CalendarApi(_client!);
      final gEvent = _mapLocalToGoogleEvent(lEvent);

      Event result;
      if (lEvent.id.startsWith('google_')) {
        final cleanId = lEvent.id.replaceFirst('google_', '');
        result = await calendarApi.events.update(gEvent, 'primary', cleanId);
      } else {
        result = await calendarApi.events.insert(gEvent, 'primary');
      }
      return _mapGoogleEventToLocal(result);
    } catch (e) {
      debugPrint('Error syncing event to Google: $e');
      return null;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    if (_client == null || !_isAuthenticated || !eventId.startsWith('google_')) return false;
    try {
      final calendarApi = CalendarApi(_client!);
      final cleanId = eventId.replaceFirst('google_', '');
      await calendarApi.events.delete('primary', cleanId);
      return true;
    } catch (e) {
      debugPrint('Error deleting event from Google: $e');
      return false;
    }
  }

  // --- MAPPING HELPERS ---

  local.CalendarEvent _mapGoogleEventToLocal(Event gEvent) {
    String category = 'Work';
    String description = gEvent.description ?? '';

    final categoryRegExp = RegExp(r'^\[Chronos Category: (.*?)\]\n?');
    final match = categoryRegExp.firstMatch(description);
    if (match != null) {
      category = match.group(1) ?? 'Work';
      description = description.replaceFirst(categoryRegExp, '');
    }

    DateTime startDateTime;
    DateTime endDateTime;
    if (gEvent.start?.dateTime != null) {
      startDateTime = gEvent.start!.dateTime!.toLocal();
    } else if (gEvent.start?.date != null) {
      startDateTime = gEvent.start!.date!;
    } else {
      startDateTime = DateTime.now();
    }

    if (gEvent.end?.dateTime != null) {
      endDateTime = gEvent.end!.dateTime!.toLocal();
    } else if (gEvent.end?.date != null) {
      endDateTime = gEvent.end!.date!;
    } else {
      endDateTime = startDateTime.add(const Duration(hours: 1));
    }

    return local.CalendarEvent(
      id: 'google_${gEvent.id}',
      title: gEvent.summary ?? 'Untitled Event',
      description: description,
      date: DateTime(startDateTime.year, startDateTime.month, startDateTime.day),
      startTime: TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute),
      endTime: TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute),
      category: category,
      color: local.CalendarEvent.getColorForCategory(category),
    );
  }

  Event _mapLocalToGoogleEvent(local.CalendarEvent lEvent) {
    final startDateTime = DateTime(
      lEvent.date.year,
      lEvent.date.month,
      lEvent.date.day,
      lEvent.startTime.hour,
      lEvent.startTime.minute,
    );
    final endDateTime = DateTime(
      lEvent.date.year,
      lEvent.date.month,
      lEvent.date.day,
      lEvent.endTime.hour,
      lEvent.endTime.minute,
    );

    final cleanId = lEvent.id.replaceFirst('google_', '');

    return Event()
      ..id = (cleanId.contains('-') || cleanId.length < 5) ? null : cleanId
      ..summary = lEvent.title
      ..description = '[Chronos Category: ${lEvent.category}]\n${lEvent.description}'
      ..start = (EventDateTime()..dateTime = startDateTime)
      ..end = (EventDateTime()..dateTime = endDateTime);
  }
}
