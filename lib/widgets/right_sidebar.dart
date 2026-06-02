import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';
import '../models/event.dart';
import 'shad_button.dart';
import 'shad_input.dart';

class CalendarRightSidebar extends StatelessWidget {
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
  });

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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isGoogleAuthenticated) ...[
                  // Google User Chip
                  Tooltip(
                    message: 'Connected as ${googleUserName ?? "Google User"}\nClick to Sign Out',
                    child: GestureDetector(
                      onTap: onGoogleLogout,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: shadTheme.border, width: 1),
                            borderRadius: BorderRadius.circular(6),
                            color: shadTheme.background,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                              Text(
                                googleUserName?.split(' ').first ?? 'Connected',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: shadTheme.foreground,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Connect Google Account Button
                  Tooltip(
                    message: 'Connect Google Account',
                    child: ShadButton.outline(
                      onPressed: onGoogleLogin,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
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
                fontFamily: 'Inter',
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
                    fontFamily: 'Inter',
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
                                  fontFamily: 'Inter'),
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
}
