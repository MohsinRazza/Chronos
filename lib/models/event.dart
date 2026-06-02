import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAllDay;
  final String category;
  final Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.category,
    required this.color,
  });

  static Color getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return ShadColors.work;
      case 'personal':
        return ShadColors.personal;
      case 'health':
        return ShadColors.health;
      case 'education':
        return ShadColors.education;
      case 'finance':
        return ShadColors.finance;
      case 'travel':
        return ShadColors.travel;
      default:
        return Colors.blueGrey;
    }
  }

  bool get hasPassed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDateOnly = DateTime(date.year, date.month, date.day);
    if (eventDateOnly.isBefore(today)) return true;
    if (eventDateOnly.isAfter(today)) return false;
    
    if (isAllDay) return false;
    
    // It's today. Compare end time.
    final nowMinutes = now.hour * 60 + now.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return nowMinutes >= endMinutes;
  }

  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDateOnly = DateTime(date.year, date.month, date.day);
    if (eventDateOnly != today) return false;
    
    if (isAllDay) return true;
    
    // It's today. Check if current time falls within start/end range.
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAllDay,
    String? category,
    Color? color,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  // Generate some high-quality mock data for testing
  static List<CalendarEvent> getMockEvents() {
    final today = DateTime.now();
    
    return [
      CalendarEvent(
        id: '1',
        title: 'Project Kickoff Meeting',
        description: 'Discuss calendar app requirements and design layout with stakeholders.',
        date: today,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        category: 'Work',
        color: ShadColors.work,
      ),
      CalendarEvent(
        id: '2',
        title: 'Workout Session',
        description: 'Cardio and weight training at the local gym.',
        date: today,
        startTime: const TimeOfDay(hour: 7, minute: 0),
        endTime: const TimeOfDay(hour: 8, minute: 0),
        category: 'Health',
        color: ShadColors.health,
      ),
      CalendarEvent(
        id: '3',
        title: 'Dinner with Sarah',
        description: 'Celebrate Sarah\'s birthday at the Italian Bistro.',
        date: today,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        category: 'Personal',
        color: ShadColors.personal,
      ),
      CalendarEvent(
        id: '4',
        title: 'Dart & Flutter Seminar',
        description: 'Watch advanced Flutter state management workshops online.',
        date: today.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        category: 'Education',
        color: ShadColors.education,
      ),
      CalendarEvent(
        id: '5',
        title: 'Budget Review',
        description: 'Analyze monthly subscriptions and credit card statements.',
        date: today.subtract(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 30),
        category: 'Finance',
        color: ShadColors.finance,
      ),
      CalendarEvent(
        id: '6',
        title: 'Flight to San Francisco',
        description: 'Check in at Terminal 2. Don\'t forget passport!',
        date: today.add(const Duration(days: 4)),
        startTime: const TimeOfDay(hour: 8, minute: 15),
        endTime: const TimeOfDay(hour: 13, minute: 45),
        category: 'Travel',
        color: ShadColors.travel,
      ),
      CalendarEvent(
        id: '7',
        title: 'Code Refactoring Session',
        description: 'Apply Chronos styles to custom buttons and popovers.',
        date: today.add(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        category: 'Work',
        color: ShadColors.work,
      ),
      CalendarEvent(
        id: '8',
        title: 'Dentist Appointment',
        description: 'Bi-annual teeth cleaning and checkup.',
        date: today.subtract(const Duration(days: 4)),
        startTime: const TimeOfDay(hour: 15, minute: 30),
        endTime: const TimeOfDay(hour: 16, minute: 30),
        category: 'Health',
        color: ShadColors.health,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'start_hour': startTime.hour,
      'start_minute': startTime.minute,
      'end_hour': endTime.hour,
      'end_minute': endTime.minute,
      'is_all_day': isAllDay,
      'category': category,
      'color': color.value,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: json['start_hour'] as int,
        minute: json['start_minute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['end_hour'] as int,
        minute: json['end_minute'] as int,
      ),
      isAllDay: json['is_all_day'] as bool? ?? false,
      category: json['category'] as String,
      color: Color(json['color'] as int),
    );
  }
}
