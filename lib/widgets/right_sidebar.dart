import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/shadcn_theme.dart';
import '../models/event.dart';
import 'shad_button.dart';
import 'shad_input.dart';

class CalendarRightSidebar extends StatefulWidget {
  final Set<String> activeCategories;
  final Function(String, bool) onCategoryToggled;
  final Function(String) onSearchChanged;
  final VoidCallback onNewEventPressed;
  final VoidCallback onToggleTheme;
  final bool isDark;

  // Google authentication properties
  final bool isGoogleAuthenticated;
  final String? googleUserName;
  final String? googleUserPicture;
  final VoidCallback onGoogleLogin;
  final VoidCallback onGoogleLogout;
  final VoidCallback onGoogleRefresh;

  // Session & Network Status properties
  final bool isOnline;
  final DateTime? lastSyncTime;
  final DateTime? googleLoginTime;

  const CalendarRightSidebar({
    super.key,
    required this.activeCategories,
    required this.onCategoryToggled,
    required this.onSearchChanged,
    required this.onNewEventPressed,
    required this.onToggleTheme,
    required this.isDark,
    required this.isGoogleAuthenticated,
    required this.googleUserName,
    required this.googleUserPicture,
    required this.onGoogleLogin,
    required this.onGoogleLogout,
    required this.onGoogleRefresh,
    required this.isOnline,
    required this.lastSyncTime,
    required this.googleLoginTime,
  });

  @override
  State<CalendarRightSidebar> createState() => _CalendarRightSidebarState();
}

class _CalendarRightSidebarState extends State<CalendarRightSidebar> {
  Timer? _relativeTimeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _relativeTimeUpdateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _relativeTimeUpdateTimer?.cancel();
    super.dispose();
  }

  Set<String> get activeCategories => widget.activeCategories;
  Function(String, bool) get onCategoryToggled => widget.onCategoryToggled;
  Function(String) get onSearchChanged => widget.onSearchChanged;
  VoidCallback get onNewEventPressed => widget.onNewEventPressed;
  VoidCallback get onToggleTheme => widget.onToggleTheme;
  bool get isDark => widget.isDark;
  bool get isGoogleAuthenticated => widget.isGoogleAuthenticated;
  String? get googleUserName => widget.googleUserName;
  String? get googleUserPicture => widget.googleUserPicture;
  VoidCallback get onGoogleLogin => widget.onGoogleLogin;
  VoidCallback get onGoogleLogout => widget.onGoogleLogout;
  VoidCallback get onGoogleRefresh => widget.onGoogleRefresh;
  bool get isOnline => widget.isOnline;
  DateTime? get lastSyncTime => widget.lastSyncTime;
  DateTime? get googleLoginTime => widget.googleLoginTime;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final categories = ['Work', 'Personal', 'Health', 'Education', 'Finance', 'Travel'];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: shadTheme.background,
        border: Border(
          left: BorderSide(color: shadTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section with Actions
          Container(
            height: 68.0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: shadTheme.border, width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isGoogleAuthenticated) ...[
                  Expanded(
                    child: _buildSessionStatus(context, shadTheme),
                  ),
                  const SizedBox(width: 8),
                  // Google User Chip
                  Expanded(
                    child: Tooltip(
                      message: 'Connected as ${googleUserName ?? "Google User"}\nClick to Sign Out',
                      child: GestureDetector(
                        onTap: onGoogleLogout,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: shadTheme.border, width: 1),
                              borderRadius: BorderRadius.circular(6),
                              color: shadTheme.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: googleUserPicture != null && googleUserPicture!.isNotEmpty
                                        ? Image.network(
                                            googleUserPicture!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.person,
                                              size: 12,
                                              color: shadTheme.foreground,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 12,
                                            color: shadTheme.foreground,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    googleUserName?.split(' ').first ?? 'Connected',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: shadTheme.foreground,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  // Connect Google Account Button
                  Expanded(
                    child: Tooltip(
                      message: 'Connect Google Account',
                      child: ShadButton.outline(
                        onPressed: onGoogleLogin,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Google_logo.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.login_outlined,
                                size: 18,
                                color: shadTheme.foreground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Google Sync',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Theme Toggle Button
                ShadButton.icon(
                  onPressed: onToggleTheme,
                  variant: ShadButtonVariant.outline,
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  iconSize: 18,
                  child: const Text('Toggle Theme'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShadInput(
              placeholder: 'Search events...',
              prefixIcon: Icons.search,
              onChanged: onSearchChanged,
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: shadTheme.border),
          const SizedBox(height: 16),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Actions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: shadTheme.mutedForeground,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShadButton.standard(
              onPressed: onNewEventPressed,
              icon: Icons.add,
              child: const Text('Add Event'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShadButton.secondary(
              onPressed: isGoogleAuthenticated ? onGoogleRefresh : onGoogleLogin,
              icon: Icons.sync,
              child: Text(isGoogleAuthenticated ? 'Sync Calendar' : 'Connect Calendar'),
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: shadTheme.border),
          const SizedBox(height: 20),

          // Categories Selection List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: shadTheme.mutedForeground,
                    letterSpacing: 0.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                ...categories.map((category) {
                  final isChecked = activeCategories.contains(category);
                  final categoryColor = CalendarEvent.getColorForCategory(category);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => onCategoryToggled(category, !isChecked),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isChecked ? shadTheme.primary : Colors.transparent,
                                border: Border.all(
                                  color: isChecked ? shadTheme.primary : shadTheme.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isChecked
                                  ? Icon(
                                      Icons.check,
                                      size: 10,
                                      color: shadTheme.primaryForeground,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: shadTheme.foreground,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildSessionStatus(BuildContext context, ShadTheme shadTheme) {
    final statusColor = isOnline ? const Color(0xFF10B981) : Colors.red;
    String statusText = '';

    if (!isOnline) {
      statusText = 'Offline';
    } else if (lastSyncTime == null) {
      statusText = 'Not Synced';
    } else {
      final difference = DateTime.now().difference(lastSyncTime!);
      if (difference.inMinutes < 1) {
        statusText = 'Just now';
      } else if (difference.inMinutes < 60) {
        statusText = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        statusText = '${difference.inHours}h ago';
      } else {
        statusText = '${difference.inDays}d ago';
      }
    }

    int daysRemaining = 15;
    if (googleLoginTime != null) {
      final elapsed = DateTime.now().difference(googleLoginTime!).inDays;
      daysRemaining = 15 - elapsed;
      if (daysRemaining < 0) daysRemaining = 0;
    }

    return Tooltip(
      message: 'Network: ${isOnline ? "Online" : "Offline"}\n'
          'Last Sync: ${lastSyncTime != null ? _formatDateTime(lastSyncTime!) : "Never"}\n'
          'Session: $daysRemaining days remaining',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: shadTheme.border, width: 1),
          borderRadius: BorderRadius.circular(6),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: shadTheme.mutedForeground,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[localDt.month - 1];
    final day = localDt.day;
    final year = localDt.year;

    final hour = localDt.hour == 0 ? 12 : (localDt.hour > 12 ? localDt.hour - 12 : localDt.hour);
    final minute = localDt.minute.toString().padLeft(2, '0');
    final amPm = localDt.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year at $hour:$minute $amPm';
  }
}
