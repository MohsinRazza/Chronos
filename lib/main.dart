import 'package:flutter/material.dart';
import 'theme/shadcn_theme.dart';
import 'models/event.dart';
import 'widgets/sidebar.dart';
import 'widgets/right_sidebar.dart';
import 'widgets/calendar_views.dart';
import 'widgets/event_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = true; // Premium default is dark mode!

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme(isDark: _isDark);

    return MaterialApp(
      title: 'Shadcn Calendar',
      debugShowCheckedModeBanner: false,
      theme: shadTheme.themeData,
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
      body: Row(
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
    );
  }
}
