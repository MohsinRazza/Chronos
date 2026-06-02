import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/shadcn_theme.dart';
import 'models/event.dart';
import 'services/google_calendar_service.dart';
import 'widgets/sidebar.dart';
import 'widgets/right_sidebar.dart';
import 'widgets/calendar_views.dart';
import 'widgets/event_dialog.dart';
import 'widgets/shad_toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false; // Default theme is Light!

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('is_dark') ?? false;
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', value);
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme(isDark: _isDark);

    return MaterialApp(
      title: 'Chronos',
      debugShowCheckedModeBanner: false,
      theme: shadTheme.themeData,
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      home: CalendarDashboard(
        isDark: _isDark,
        onToggleTheme: () {
          setState(() {
            _isDark = !_isDark;
          });
          _saveTheme(_isDark);
        },
      ),
    );
  }
}

class CalendarDashboard extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const CalendarDashboard({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  late DateTime _selectedDate;
  late CalendarViewMode _viewMode;
  late List<CalendarEvent> _events;
  late Set<String> _activeCategories;
  late String _searchKeyword;

  // Google Calendar Integration
  final GoogleCalendarService _googleService = GoogleCalendarService();
  List<CalendarEvent> _googleEvents = [];
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  DateTime? _googleLoginTime;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _viewMode = CalendarViewMode.month;
    _events = [];
    _activeCategories = {'Work', 'Personal', 'Health', 'Education', 'Finance', 'Travel'};
    _searchKeyword = '';

    // Bind Google Auth state listener
    _googleService.onStateChanged = () async {
      if (mounted) {
        setState(() {});
        if (_googleService.isAuthenticated) {
          final prefs = await SharedPreferences.getInstance();
          final String? lastSyncTimeStr = prefs.getString('google_last_sync_time');
          final String? loginTimeStr = prefs.getString('google_login_time');
          setState(() {
            _lastSyncTime = lastSyncTimeStr != null ? DateTime.parse(lastSyncTimeStr) : null;
            _googleLoginTime = loginTimeStr != null ? DateTime.parse(loginTimeStr) : null;
          });
          _fetchGoogleEvents();
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('cached_google_events');
          setState(() {
            _googleEvents = [];
            _lastSyncTime = null;
            _googleLoginTime = null;
          });
        }
      }
    };

    _loadEvents();
    _googleService.initialize();
    _checkConnectivity();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkConnectivity();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGoogleEvents() async {
    try {
      final gEvents = await _googleService.fetchGoogleEvents();
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          _googleEvents = gEvents;
          _lastSyncTime = now;
          _isOnline = true;
        });
      }
      await _saveCachedGoogleEvents();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_last_sync_time', now.toIso8601String());
    } catch (e) {
      debugPrint('Error fetching Google events: $e');
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
        ShadToast.show(
          context,
          title: 'Sync Failed',
          description: 'Could not fetch events. Please check your internet connection.',
          isDestructive: true,
        );
      }
    }
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load local events
    final String? eventsJson = prefs.getString('calendar_events');
    if (eventsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(eventsJson);
        setState(() {
          _events = decoded
              .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        setState(() {
          _events = CalendarEvent.getMockEvents();
        });
        _saveEvents();
      }
    } else {
      setState(() {
        _events = CalendarEvent.getMockEvents();
      });
      _saveEvents();
    }

    // Load cached Google events
    final String? cachedGoogleJson = prefs.getString('cached_google_events');
    if (cachedGoogleJson != null) {
      try {
        final List<dynamic> decodedGoogle = json.decode(cachedGoogleJson);
        setState(() {
          _googleEvents = decodedGoogle
              .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        debugPrint('Error loading cached Google events: $e');
      }
    }

    // Load last sync time
    final String? lastSyncTimeStr = prefs.getString('google_last_sync_time');
    if (lastSyncTimeStr != null) {
      setState(() {
        _lastSyncTime = DateTime.parse(lastSyncTimeStr);
      });
    }
    
    // Load google login time
    final String? loginTimeStr = prefs.getString('google_login_time');
    if (loginTimeStr != null) {
      setState(() {
        _googleLoginTime = DateTime.parse(loginTimeStr);
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_events.map((e) => e.toJson()).toList());
    await prefs.setString('calendar_events', encoded);
  }

  Future<void> _saveCachedGoogleEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_googleEvents.map((e) => e.toJson()).toList());
    await prefs.setString('cached_google_events', encoded);
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && online != _isOnline) {
        setState(() {
          _isOnline = online;
        });
      }
    } catch (_) {
      if (mounted && _isOnline) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  // Filter events based on active category checkboxes and search bar queries
  List<CalendarEvent> get _filteredEvents {
    final allEvents = [..._events, ..._googleEvents];
    return allEvents.where((event) {
      final matchesCategory = _activeCategories.contains(event.category);
      final matchesSearch = _searchKeyword.isEmpty ||
          event.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchKeyword.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Filtered events scheduled on the selected day (for Sidebar Agenda display)
  List<CalendarEvent> get _eventsForSelectedDate {
    return _filteredEvents.where((event) {
      return event.date.year == _selectedDate.year &&
          event.date.month == _selectedDate.month &&
          event.date.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) {
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });
  }

  void _handleCategoryToggled(String category, bool isChecked) {
    setState(() {
      if (isChecked) {
        _activeCategories.add(category);
      } else {
        _activeCategories.remove(category);
      }
    });
  }

  void _handleSearchChanged(String query) {
    setState(() {
      _searchKeyword = query;
    });
  }

  // Google OAuth Handlers
  Future<void> _handleGoogleLogin() async {
    final success = await _googleService.login();
    if (success) {
      ShadToast.show(
        context,
        title: 'Google Connected',
        description: 'Successfully authenticated as ${_googleService.userEmail}.',
        icon: Icons.check_circle_outline,
      );
    } else {
      ShadToast.show(
        context,
        title: 'Connection Failed',
        description: 'Google Sign-In failed or was cancelled.',
        isDestructive: true,
      );
    }
  }

  Future<void> _handleGoogleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final shadTheme = ShadTheme.of(context);
        return AlertDialog(
          backgroundColor: shadTheme.background,
          title: Text(
            'Disconnect Google Account',
            style: TextStyle(color: shadTheme.foreground),
          ),
          content: Text(
            'Are you sure you want to sign out of ${_googleService.userEmail}?',
            style: TextStyle(color: shadTheme.mutedForeground),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Disconnect',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _googleService.logout();
      ShadToast.show(
        context,
        title: 'Google Disconnected',
        description: 'You have signed out of your Google Account.',
        icon: Icons.info_outline,
      );
    }
  }

  Future<void> _handleGoogleRefresh() async {
    ShadToast.show(
      context,
      title: 'Syncing Calendar',
      description: 'Fetching events from Google Calendar...',
      icon: Icons.sync,
    );
    await _fetchGoogleEvents();
    ShadToast.show(
      context,
      title: 'Sync Completed',
      description: 'Google Calendar events are now up to date.',
      icon: Icons.check_circle_outline,
    );
  }

  // Create new event handler
  Future<void> _handleNewEventPressed([DateTime? targetDate]) async {
    final result = await EventFormDialog.show(
      context: context,
      initialDate: targetDate ?? _selectedDate,
      isGoogleAuthenticated: _googleService.isAuthenticated,
    );

    if (result != null && result['action'] == 'save') {
      final CalendarEvent event = result['event'] as CalendarEvent;
      final syncToGoogle = result['syncToGoogle'] as bool? ?? false;

      if (syncToGoogle) {
        ShadToast.show(
          context,
          title: 'Syncing Event',
          description: 'Adding event to Google Calendar...',
          icon: Icons.cloud_upload_outlined,
        );
        final syncedEvent = await _googleService.pushEvent(event);
        if (syncedEvent != null) {
          setState(() {
            _googleEvents.add(syncedEvent);
          });
          await _saveCachedGoogleEvents();
          ShadToast.show(
            context,
            title: 'Google Event Added',
            description: '"${event.title}" has been synced to Google Calendar.',
            icon: Icons.check_circle_outline,
          );
        } else {
          setState(() {
            _events.add(event);
          });
          _saveEvents();
          ShadToast.show(
            context,
            title: 'Sync Failed',
            description: 'Failed to sync with Google. Saved to Local Calendar.',
            isDestructive: true,
          );
        }
      } else {
        setState(() {
          _events.add(event);
        });
        _saveEvents();
        ShadToast.show(
          context,
          title: 'Event Created',
          description: '"${event.title}" saved to local calendar.',
          icon: Icons.check_circle_outline,
        );
      }
    }
  }

  // Edit / Details event handler
  Future<void> _handleEventSelected(CalendarEvent event) async {
    final result = await EventFormDialog.show(
      context: context,
      initialEvent: event,
      initialDate: event.date,
      isGoogleAuthenticated: _googleService.isAuthenticated,
    );

    if (result != null) {
      if (result['action'] == 'save') {
        final updatedEvent = result['event'] as CalendarEvent;

        if (updatedEvent.id.startsWith('google_')) {
          ShadToast.show(
            context,
            title: 'Updating Event',
            description: 'Pushing updates to Google Calendar...',
            icon: Icons.cloud_upload_outlined,
          );
          final syncedEvent = await _googleService.pushEvent(updatedEvent);
          if (syncedEvent != null) {
            setState(() {
              final index = _googleEvents.indexWhere((e) => e.id == updatedEvent.id);
              if (index != -1) {
                _googleEvents[index] = syncedEvent;
              }
            });
            await _saveCachedGoogleEvents();
            ShadToast.show(
              context,
              title: 'Google Event Updated',
              description: '"${updatedEvent.title}" has been updated on Google Calendar.',
              icon: Icons.check_circle_outline,
            );
          } else {
            ShadToast.show(
              context,
              title: 'Update Failed',
              description: 'Failed to update event on Google Calendar.',
              isDestructive: true,
            );
          }
        } else {
          setState(() {
            final index = _events.indexWhere((e) => e.id == updatedEvent.id);
            if (index != -1) {
              _events[index] = updatedEvent;
            }
          });
          _saveEvents();
          ShadToast.show(
            context,
            title: 'Event Updated',
            description: '"${updatedEvent.title}" updated locally.',
            icon: Icons.check_circle_outline,
          );
        }
      } else if (result['action'] == 'delete') {
        final id = result['id'] as String;

        if (id.startsWith('google_')) {
          ShadToast.show(
            context,
            title: 'Deleting Event',
            description: 'Removing event from Google Calendar...',
            icon: Icons.delete_outline,
          );
          final success = await _googleService.deleteEvent(id);
          if (success) {
            setState(() {
              _googleEvents.removeWhere((e) => e.id == id);
            });
            await _saveCachedGoogleEvents();
            ShadToast.show(
              context,
              title: 'Google Event Deleted',
              description: 'The event has been deleted from Google Calendar.',
              icon: Icons.delete_outline,
            );
          } else {
            ShadToast.show(
              context,
              title: 'Deletion Failed',
              description: 'Failed to delete event from Google Calendar.',
              isDestructive: true,
            );
          }
        } else {
          setState(() {
            _events.removeWhere((e) => e.id == id);
          });
          _saveEvents();
          ShadToast.show(
            context,
            title: 'Event Deleted',
            description: 'The event was deleted from your local calendar.',
            icon: Icons.delete_outline,
          );
        }
      }
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleViewModeChanged(CalendarViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _handleNavigateMonth(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: shadTheme.background,
      body: Column(
        children: [
          CustomWindowTitleBar(isDark: widget.isDark),
          Expanded(
            child: Row(
              children: [
                CalendarSidebar(
                  selectedDate: _selectedDate,
                  eventsForSelectedDate: _eventsForSelectedDate,
                  allEvents: _filteredEvents,
                  onEventSelected: _handleEventSelected,
                ),
                Expanded(
                  child: CalendarWorkspace(
                    currentDate: _selectedDate,
                    viewMode: _viewMode,
                    events: _filteredEvents,
                    onDateSelected: _handleDateSelected,
                    onViewModeChanged: _handleViewModeChanged,
                    onNavigateMonth: _handleNavigateMonth,
                    onEventSelected: _handleEventSelected,
                    onAddEventForDate: _handleNewEventPressed,
                  ),
                ),
                CalendarRightSidebar(
                  activeCategories: _activeCategories,
                  onCategoryToggled: _handleCategoryToggled,
                  onSearchChanged: _handleSearchChanged,
                  onNewEventPressed: () => _handleNewEventPressed(),
                  onToggleTheme: widget.onToggleTheme,
                  isDark: widget.isDark,
                  isGoogleAuthenticated: _googleService.isAuthenticated,
                  googleUserName: _googleService.userName,
                  googleUserPicture: _googleService.userPicture,
                  onGoogleLogin: _handleGoogleLogin,
                  onGoogleLogout: _handleGoogleLogout,
                  onGoogleRefresh: _handleGoogleRefresh,
                  isOnline: _isOnline,
                  lastSyncTime: _lastSyncTime,
                  googleLoginTime: _googleLoginTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomWindowTitleBar extends StatefulWidget {
  final bool isDark;
  const CustomWindowTitleBar({super.key, required this.isDark});

  @override
  State<CustomWindowTitleBar> createState() => _CustomWindowTitleBarState();
}

class _CustomWindowTitleBarState extends State<CustomWindowTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximizedState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximizedState() async {
    final max = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = max;
      });
    }
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: shadTheme.background,
        border: Border(
          bottom: BorderSide(color: shadTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Draggable window area for drag-to-move
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: () async {
                if (_isMaximized) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Logo Image
                    Image.asset(
                      'assets/images/Chronos_C.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: shadTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chronos',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: shadTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Window Controls (Minimize, Maximize, Close)
          Row(
            children: [
              // Minimize
              _WindowControlButton(
                icon: Icon(Icons.minimize_rounded, size: 16, color: shadTheme.foreground),
                hoverColor: shadTheme.accent,
                onPressed: () => windowManager.minimize(),
              ),
              // Maximize/Restore
              _WindowControlButton(
                icon: Icon(
                  _isMaximized ? Icons.filter_none_rounded : Icons.crop_square_rounded,
                  size: 14,
                  color: shadTheme.foreground,
                ),
                hoverColor: shadTheme.accent,
                onPressed: () async {
                  if (_isMaximized) {
                    await windowManager.unmaximize();
                  } else {
                    await windowManager.maximize();
                  }
                },
              ),
              // Close
              _WindowControlButton(
                icon: Icon(Icons.close_rounded, size: 16, color: shadTheme.foreground),
                hoverColor: Colors.red.withOpacity(0.1),
                hoverIconColor: Colors.red,
                onPressed: () => windowManager.close(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final Widget icon;
  final Color hoverColor;
  final Color? hoverIconColor;
  final VoidCallback onPressed;

  const _WindowControlButton({
    required this.icon,
    required this.hoverColor,
    this.hoverIconColor,
    required this.onPressed,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color? iconColor;
    IconData? iconData;
    double? iconSize;

    if (widget.icon is Icon) {
      final iconWidget = widget.icon as Icon;
      iconData = iconWidget.icon;
      iconSize = iconWidget.size;
      iconColor = _isHovered 
          ? (widget.hoverIconColor ?? iconWidget.color) 
          : iconWidget.color;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: Container(
          width: 48,
          height: 40,
          color: _isHovered ? widget.hoverColor : Colors.transparent,
          child: Center(
            child: iconData != null
                ? Icon(
                    iconData,
                    size: iconSize,
                    color: iconColor,
                  )
                : widget.icon,
          ),
        ),
      ),
    );
  }
}

