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

  const CalendarRightSidebar({
    super.key,
    required this.activeCategories,
    required this.onCategoryToggled,
    required this.onSearchChanged,
    required this.onNewEventPressed,
    required this.onToggleTheme,
    required this.isDark,
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
                // Theme Toggle Button (with support for future header action buttons)
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
