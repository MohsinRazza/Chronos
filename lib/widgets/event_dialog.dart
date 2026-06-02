import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';
import '../models/event.dart';
import 'shad_button.dart';
import 'shad_input.dart';
import 'shad_dialog.dart';
import 'shad_toast.dart';

class EventFormDialog extends StatefulWidget {
  final CalendarEvent? initialEvent;
  final DateTime initialDate;
  final bool isGoogleAuthenticated;

  const EventFormDialog({
    super.key,
    this.initialEvent,
    required this.initialDate,
    required this.isGoogleAuthenticated,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    CalendarEvent? initialEvent,
    required DateTime initialDate,
    required bool isGoogleAuthenticated,
  }) {
    return ShadDialog.show<Map<String, dynamic>>(
      context: context,
      title: initialEvent == null ? 'Create Event' : 'Edit Event',
      description: initialEvent == null 
          ? 'Add a new event to your calendar schedule.' 
          : 'Update details or delete this calendar event.',
      maxWidth: 480.0,
      actions: const [],
      content: EventFormDialog(
        initialEvent: initialEvent,
        initialDate: initialDate,
        isGoogleAuthenticated: isGoogleAuthenticated,
      ),
    );
  }

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;
  late String _selectedCategory;
  late bool _syncToGoogle;

  final List<String> _categories = ['Work', 'Personal', 'Health', 'Education', 'Finance', 'Travel'];

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    
    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _selectedDate = event?.date ?? widget.initialDate;
    _startTime = event?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = event?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _isAllDay = event?.isAllDay ?? false;
    _selectedCategory = event?.category ?? 'Work';
    _syncToGoogle = event?.id.startsWith('google_') ?? widget.isGoogleAuthenticated;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final shadTheme = ShadTheme.of(context);
        return Theme(
          data: shadTheme.themeData,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        final shadTheme = ShadTheme.of(context);
        return Theme(
          data: shadTheme.themeData,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Automatically set end time to 1 hour after start time if end time is before start time
        final startMinutes = _startTime.hour * 60 + _startTime.minute;
        final endMinutes = _endTime.hour * 60 + _endTime.minute;
        if (endMinutes <= startMinutes) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        final shadTheme = ShadTheme.of(context);
        return Theme(
          data: shadTheme.themeData,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ShadToast.show(
        context,
        title: 'Title Required',
        description: 'Please enter a title for your calendar event.',
        isDestructive: true,
      );
      return;
    }

    if (!_isAllDay) {
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;
      if (endMinutes <= startMinutes) {
        ShadToast.show(
          context,
          title: 'Invalid Event Duration',
          description: 'End time must be set after the start time.',
          isDestructive: true,
        );
        return;
      }
    }

    Navigator.of(context).pop({
      'action': 'save',
      'syncToGoogle': _syncToGoogle,
      'event': CalendarEvent(
        id: widget.initialEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: _isAllDay ? const TimeOfDay(hour: 0, minute: 0) : _startTime,
        endTime: _isAllDay ? const TimeOfDay(hour: 23, minute: 59) : _endTime,
        isAllDay: _isAllDay,
        category: _selectedCategory,
        color: CalendarEvent.getColorForCategory(_selectedCategory),
      ),
    });
  }

  void _delete() {
    Navigator.of(context).pop({
      'action': 'delete',
      'id': widget.initialEvent!.id,
    });
  }

  String _formatDateString(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Event Title
          ShadInput(
            controller: _titleController,
            label: 'Event Title',
            placeholder: 'e.g. Design Sync Meeting',
          ),
          const SizedBox(height: 16),

          // Event Description
          ShadInput(
            controller: _descriptionController,
            label: 'Description',
            placeholder: 'Provide optional details about the meeting...',
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          // All Day Checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _isAllDay,
                  activeColor: shadTheme.primary,
                  onChanged: (val) {
                    setState(() {
                      _isAllDay = val ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'All Day Event',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: shadTheme.foreground,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date & Time Picker Group
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: shadTheme.foreground,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    ShadButton.outline(
                      onPressed: _pickDate,
                      width: double.infinity,
                      icon: Icons.calendar_today_rounded,
                      child: Text(_formatDateString(_selectedDate)),
                    ),
                  ],
                ),
              ),
              if (!_isAllDay) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: shadTheme.foreground,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShadButton.outline(
                        onPressed: _pickStartTime,
                        width: double.infinity,
                        icon: Icons.access_time_rounded,
                        child: Text(_startTime.format(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: shadTheme.foreground,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShadButton.outline(
                        onPressed: _pickEndTime,
                        width: double.infinity,
                        icon: Icons.access_time_rounded,
                        child: Text(_endTime.format(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Category Selector
          Text(
            'Category Tag',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: shadTheme.foreground,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              final categoryColor = CalendarEvent.getColorForCategory(category);
              
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? categoryColor.withOpacity(0.15) 
                          : shadTheme.accent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? categoryColor : shadTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? categoryColor : shadTheme.foreground,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (widget.isGoogleAuthenticated && (widget.initialEvent == null || !widget.initialEvent!.id.startsWith('google_'))) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _syncToGoogle,
                    activeColor: shadTheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _syncToGoogle = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync to Google Calendar',
                  style: TextStyle(
                    fontSize: 13,
                    color: shadTheme.foreground,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),
          Divider(height: 1, color: shadTheme.border),
          const SizedBox(height: 20),

          // Actions Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.initialEvent != null) ...[
                ShadButton.destructive(
                  onPressed: _delete,
                  icon: Icons.delete_outline_rounded,
                  child: const Text('Delete'),
                ),
                const Spacer(),
              ],
              ShadButton.outline(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ShadButton.standard(
                onPressed: _save,
                child: const Text('Save Event'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
