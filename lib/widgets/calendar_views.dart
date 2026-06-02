import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';
import '../models/event.dart';
import 'shad_button.dart';

enum CalendarViewMode { month, week, day }

class CalendarWorkspace extends StatelessWidget {
  final DateTime currentDate;
  final CalendarViewMode viewMode;
  final List<CalendarEvent> events;
  final Function(DateTime) onDateSelected;
  final Function(CalendarViewMode) onViewModeChanged;
  final Function(DateTime) onNavigateMonth;
  final Function(CalendarEvent) onEventSelected;
  final Function(DateTime) onAddEventForDate;

  const CalendarWorkspace({
    super.key,
    required this.currentDate,
    required this.viewMode,
    required this.events,
    required this.onDateSelected,
    required this.onViewModeChanged,
    required this.onNavigateMonth,
    required this.onEventSelected,
    required this.onAddEventForDate,
  });

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _navigateToPrevious() {
    if (viewMode == CalendarViewMode.month) {
      onNavigateMonth(DateTime(currentDate.year, currentDate.month - 1, 1));
    } else if (viewMode == CalendarViewMode.week) {
      onNavigateMonth(currentDate.subtract(const Duration(days: 7)));
    } else {
      onNavigateMonth(currentDate.subtract(const Duration(days: 1)));
    }
  }

  void _navigateToNext() {
    if (viewMode == CalendarViewMode.month) {
      onNavigateMonth(DateTime(currentDate.year, currentDate.month + 1, 1));
    } else if (viewMode == CalendarViewMode.week) {
      onNavigateMonth(currentDate.add(const Duration(days: 7)));
    } else {
      onNavigateMonth(currentDate.add(const Duration(days: 1)));
    }
  }

  void _navigateToToday() {
    onNavigateMonth(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      color: shadTheme.background,
      child: Column(
        children: [
          // Calendar Header Toolbar
          _buildToolbar(context, shadTheme),
          
          // View Area
          Expanded(
            child: _buildCalendarView(context, shadTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ShadTheme shadTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: shadTheme.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month/Year navigation
          Row(
            children: [
              Text(
                _formatMonthYear(currentDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: shadTheme.foreground,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 16),
              ShadButton.outline(
                onPressed: _navigateToToday,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Text('Today'),
              ),
              const SizedBox(width: 8),
              ShadButton.icon(
                onPressed: _navigateToPrevious,
                variant: ShadButtonVariant.outline,
                icon: Icons.chevron_left_rounded,
                child: const Text('Prev'),
              ),
              const SizedBox(width: 4),
              ShadButton.icon(
                onPressed: _navigateToNext,
                variant: ShadButtonVariant.outline,
                icon: Icons.chevron_right_rounded,
                child: const Text('Next'),
              ),
            ],
          ),

          // View Mode Selector (Month, Week, Day tabs)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: shadTheme.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _buildViewTab(CalendarViewMode.month, 'Month', shadTheme),
                _buildViewTab(CalendarViewMode.week, 'Week', shadTheme),
                _buildViewTab(CalendarViewMode.day, 'Day', shadTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab(CalendarViewMode mode, String label, ShadTheme shadTheme) {
    final isSelected = viewMode == mode;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onViewModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? shadTheme.popover : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? shadTheme.foreground : shadTheme.mutedForeground,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, ShadTheme shadTheme) {
    switch (viewMode) {
      case CalendarViewMode.month:
        return _MonthGridView(
          currentDate: currentDate,
          events: events,
          onDateSelected: onDateSelected,
          onEventSelected: onEventSelected,
          onAddEventForDate: onAddEventForDate,
        );
      case CalendarViewMode.week:
        return _WeekScheduleView(
          currentDate: currentDate,
          events: events,
          onDateSelected: onDateSelected,
          onEventSelected: onEventSelected,
        );
      case CalendarViewMode.day:
        return _DayScheduleView(
          currentDate: currentDate,
          events: events,
          onEventSelected: onEventSelected,
        );
    }
  }
}

// ----------------- MONTH VIEW -----------------
class _MonthGridView extends StatelessWidget {
  final DateTime currentDate;
  final List<CalendarEvent> events;
  final Function(DateTime) onDateSelected;
  final Function(CalendarEvent) onEventSelected;
  final Function(DateTime) onAddEventForDate;

  const _MonthGridView({
    required this.currentDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventSelected,
    required this.onAddEventForDate,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    // Calculate dates for 42-day calendar grid (Sunday to Saturday)
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final daysInPrevMonth = DateTime(currentDate.year, currentDate.month, 0).day;

    final leadingOffset = firstDayOfMonth.weekday % 7; // Sunday first
    
    final List<DateTime> gridDates = [];

    // Add previous month's trailing days
    for (int i = leadingOffset - 1; i >= 0; i--) {
      gridDates.add(
        DateTime(currentDate.year, currentDate.month - 1, daysInPrevMonth - i),
      );
    }

    // Add current month's days
    for (int i = 1; i <= daysInMonth; i++) {
      gridDates.add(DateTime(currentDate.year, currentDate.month, i));
    }

    // Add next month's leading days to fill up to 42 cells (6 rows * 7 columns)
    final trailingDaysCount = 42 - gridDates.length;
    for (int i = 1; i <= trailingDaysCount; i++) {
      gridDates.add(DateTime(currentDate.year, currentDate.month + 1, i));
    }

    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Weekday Labels
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: shadTheme.border, width: 1)),
          ),
          child: Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: shadTheme.mutedForeground,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Grid Cells
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellHeight = constraints.maxHeight / 6;

              return GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.15, // Desktop widescreen balance
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final date = gridDates[index];
                  final isCurrentMonth = date.month == currentDate.month;
                  final isToday = _isSameDay(date, DateTime.now());
                  final isSelected = _isSameDay(date, currentDate);
                  
                  // Filter events for this day
                  final dayEvents = events.where((e) => _isSameDay(e.date, date)).toList();

                  return _MonthGridCell(
                    date: date,
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday,
                    isSelected: isSelected,
                    events: dayEvents,
                    height: cellHeight,
                    onTap: () => onDateSelected(date),
                    onDoubleTap: () => onAddEventForDate(date),
                    onEventTap: onEventSelected,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MonthGridCell extends StatefulWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final Function(CalendarEvent) onEventTap;

  const _MonthGridCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.height,
    required this.onTap,
    required this.onDoubleTap,
    required this.onEventTap,
  });

  @override
  State<_MonthGridCell> createState() => _MonthGridCellState();
}

class _MonthGridCellState extends State<_MonthGridCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    
    // Sort events by starting time
    final sortedEvents = List<CalendarEvent>.from(widget.events)
      ..sort((a, b) {
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? shadTheme.accent.withOpacity(0.4)
                : (_isHovered ? shadTheme.accent.withOpacity(0.2) : Colors.transparent),
            border: Border.all(
              color: shadTheme.border,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Day number header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: widget.isToday
                          ? BoxDecoration(
                              color: shadTheme.primary,
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          '${widget.date.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: widget.isToday ? FontWeight.w600 : FontWeight.w400,
                            color: widget.isToday
                                ? shadTheme.primaryForeground
                                : (widget.isCurrentMonth
                                    ? shadTheme.foreground
                                    : shadTheme.mutedForeground.withOpacity(0.5)),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    if (widget.events.isNotEmpty && widget.height < 90)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: shadTheme.primary.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),

              // Events List (if space permits)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: sortedEvents.take(3).map((event) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              widget.onEventTap(event);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: event.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border(
                                  left: BorderSide(color: event.color, width: 2.5),
                                ),
                              ),
                              child: Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: event.color.withOpacity(0.95),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // More indicator
              if (sortedEvents.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                    '+${sortedEvents.length - 3} more',
                    style: TextStyle(
                      fontSize: 9,
                      color: shadTheme.mutedForeground,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// ----------------- WEEK VIEW -----------------
class _WeekScheduleView extends StatelessWidget {
  final DateTime currentDate;
  final List<CalendarEvent> events;
  final Function(DateTime) onDateSelected;
  final Function(CalendarEvent) onEventSelected;

  const _WeekScheduleView({
    required this.currentDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    // Calculate dates of current week (Sunday to Saturday)
    final diff = currentDate.weekday % 7;
    final sunday = currentDate.subtract(Duration(days: diff));

    final List<DateTime> weekDates = List.generate(7, (index) => sunday.add(Duration(days: index)));
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, currentDate);
        
        // Filter events for this day
        final dayEvents = events.where((e) => _isSameDay(e.date, date)).toList()
          ..sort((a, b) {
            final aMin = a.startTime.hour * 60 + a.startTime.minute;
            final bMin = b.startTime.hour * 60 + b.startTime.minute;
            return aMin.compareTo(bMin);
          });

        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: shadTheme.border, 
                  width: index < 6 ? 1.0 : 0.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Day Column Header
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? shadTheme.accent.withOpacity(0.2) : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: shadTheme.border, width: 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            weekdays[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? shadTheme.foreground : shadTheme.mutedForeground,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: shadTheme.primary,
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isToday ? shadTheme.primaryForeground : shadTheme.foreground,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Event List
                Expanded(
                  child: Container(
                    color: isSelected ? shadTheme.accent.withOpacity(0.05) : Colors.transparent,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: dayEvents.length,
                      itemBuilder: (context, eventIndex) {
                        final event = dayEvents[eventIndex];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => onEventSelected(event),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: event.color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: event.color.withOpacity(0.2), 
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: event.color.withOpacity(0.95),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 10,
                                          color: event.color.withOpacity(0.8),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event.startTime.format(context),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: event.color.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}


// ----------------- DAY VIEW -----------------
class _DayScheduleView extends StatelessWidget {
  final DateTime currentDate;
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventSelected;

  const _DayScheduleView({
    required this.currentDate,
    required this.events,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    // Filter and sort events for this day
    final dayEvents = events.where((e) => _isSameDay(e.date, currentDate)).toList()
      ..sort((a, b) {
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });

    return Row(
      children: [
        // Hourly Timeline Sidebar
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _formatFullDate(currentDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: shadTheme.foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                
                if (dayEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 48,
                            color: shadTheme.mutedForeground.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events scheduled for today',
                            style: TextStyle(
                              fontSize: 14,
                              color: shadTheme.mutedForeground,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // List schedule layout
                  ...dayEvents.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onEventSelected(event),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: shadTheme.accent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: shadTheme.border, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Time Display
                                Container(
                                  width: 80,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.startTime.format(context),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: shadTheme.foreground,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.endTime.format(context),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: shadTheme.mutedForeground,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Verticle bar indicator
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: event.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            event.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: shadTheme.foreground,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: event.color.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              event.category,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: event.color,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        event.description.isNotEmpty
                                            ? event.description
                                            : 'No description provided.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: shadTheme.mutedForeground,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    // weekday is 1-7 (Mon-Sun).
    final weekdayStr = weekdays[date.weekday == 7 ? 0 : date.weekday];
    return '$weekdayStr, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
