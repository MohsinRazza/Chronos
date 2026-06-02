import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'theme/shadcn_theme.dart';
import 'models/event.dart';
import 'widgets/sidebar.dart';
import 'widgets/right_sidebar.dart';
import 'widgets/calendar_views.dart';
import 'widgets/event_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _viewMode = CalendarViewMode.month;
    _events = CalendarEvent.getMockEvents();
    _activeCategories = {'Work', 'Personal', 'Health', 'Education', 'Finance', 'Travel'};
    _searchKeyword = '';
  }

  // Filter events based on active category checkboxes and search bar queries
  List<CalendarEvent> get _filteredEvents {
    return _events.where((event) {
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

  // Create new event handler
  Future<void> _handleNewEventPressed([DateTime? targetDate]) async {
    final result = await EventFormDialog.show(
      context: context,
      initialDate: targetDate ?? _selectedDate,
    );

    if (result != null && result['action'] == 'save') {
      setState(() {
        _events.add(result['event'] as CalendarEvent);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event added successfully!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Edit / Details event handler
  Future<void> _handleEventSelected(CalendarEvent event) async {
    final result = await EventFormDialog.show(
      context: context,
      initialEvent: event,
      initialDate: event.date,
    );

    if (result != null) {
      if (result['action'] == 'save') {
        final updatedEvent = result['event'] as CalendarEvent;
        setState(() {
          final index = _events.indexWhere((e) => e.id == updatedEvent.id);
          if (index != -1) {
            _events[index] = updatedEvent;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result['action'] == 'delete') {
        final id = result['id'] as String;
        setState(() {
          _events.removeWhere((e) => e.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
                // Left Sidebar Panel: Agenda & Upcoming Timeline
                CalendarSidebar(
                  selectedDate: _selectedDate,
                  eventsForSelectedDate: _eventsForSelectedDate,
                  allEvents: _filteredEvents,
                  onEventSelected: _handleEventSelected,
                ),

                // Main Workspace Panel (Expanded to fill middle space)
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

                // Right Sidebar Panel: Searches, Filters, Theme Toggles
                CalendarRightSidebar(
                  activeCategories: _activeCategories,
                  onCategoryToggled: _handleCategoryToggled,
                  onSearchChanged: _handleSearchChanged,
                  onNewEventPressed: () => _handleNewEventPressed(),
                  onToggleTheme: widget.onToggleTheme,
                  isDark: widget.isDark,
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
                        fontFamily: 'Inter',
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
    Widget child = Center(child: widget.icon);
    
    // Switch icon color on hover if hoverIconColor is provided
    if (_isHovered && widget.hoverIconColor != null && widget.icon is Icon) {
      child = Center(
        child: Icon(
          (widget.icon as Icon).icon,
          size: (widget.icon as Icon).size,
          color: widget.hoverIconColor,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 48,
          height: 40,
          color: _isHovered ? widget.hoverColor : Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

