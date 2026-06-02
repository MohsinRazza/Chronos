import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';
import '../models/event.dart';

class CalendarSidebar extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> eventsForSelectedDate;
  final List<CalendarEvent> allEvents;
  final Function(CalendarEvent) onEventSelected;

  const CalendarSidebar({
    super.key,
    required this.selectedDate,
    required this.eventsForSelectedDate,
    required this.allEvents,
    required this.onEventSelected,
  });

  String _formatMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatFullMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  List<CalendarEvent> _getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allEvents.where((e) {
      final eventDateOnly = DateTime(e.date.year, e.date.month, e.date.day);
      return !eventDateOnly.isBefore(today);
    }).toList()
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final upcomingEvents = _getUpcomingEvents();

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: shadTheme.background,
        border: Border(
          right: BorderSide(color: shadTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section aligned with central workspace
          Container(
            height: 68.0,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: shadTheme.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AGENDA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: shadTheme.foreground,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '${_formatFullMonth(selectedDate.month)} ${selectedDate.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: shadTheme.mutedForeground,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          // SECTION 1: Agenda of Selected Day
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: eventsForSelectedDate.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 24,
                                  color: shadTheme.mutedForeground.withOpacity(0.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No events for this day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: shadTheme.mutedForeground,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: eventsForSelectedDate.length,
                            itemBuilder: (context, index) {
                              final event = eventsForSelectedDate[index];
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => onEventSelected(event),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: shadTheme.accent.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: shadTheme.border, width: 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: event.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: shadTheme.foreground,
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: shadTheme.mutedForeground,
                                              fontFamily: 'Inter',
                                            ),
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
                ],
              ),
            ),
          ),

          Divider(height: 1, color: shadTheme.border),

          // SECTION 2: Upcoming Events Timeline
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'UPCOMING EVENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: shadTheme.mutedForeground,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: upcomingEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timeline_outlined,
                                  size: 24,
                                  color: shadTheme.mutedForeground.withOpacity(0.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: shadTheme.mutedForeground,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: upcomingEvents.length,
                            itemBuilder: (context, index) {
                              final event = upcomingEvents[index];
                              final isLast = index == upcomingEvents.length - 1;
                              
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left Date Column
                                    SizedBox(
                                      width: 44,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.date.day.toString().padLeft(2, '0'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: shadTheme.foreground,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          Text(
                                            _formatMonth(event.date.month),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: shadTheme.mutedForeground,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Timeline Dot and vertical line
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: event.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 1,
                                                color: shadTheme.border,
                                              ),
                                            )
                                          else
                                            const Spacer(),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Event Description Card
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => onEventSelected(event),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: shadTheme.accent.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: shadTheme.border, width: 1),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: shadTheme.foreground,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${event.startTime.format(context)} - ${event.category}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: shadTheme.mutedForeground,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
