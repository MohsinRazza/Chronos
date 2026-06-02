import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';
import 'shad_button.dart';

class ShadDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;

  const ShadDialog({
    super.key,
    required this.title,
    this.description,
    required this.content,
    this.actions,
    this.maxWidth = 480.0,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
    double maxWidth = 480.0,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ShadDialogBarrier',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: ShadDialog(
              title: title,
              description: description,
              content: content,
              actions: actions,
              maxWidth: maxWidth,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      width: maxWidth,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: shadTheme.popover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: shadTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: shadTheme.foreground,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: shadTheme.mutedForeground,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ShadButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.close,
                  iconSize: 16,
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                (actions?.isNotEmpty ?? true) ? 8 : 24,
              ),
              child: content,
            ),
          ),
          // Footer / Actions
          if (actions?.isNotEmpty ?? true)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions ??
                    [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ShadButton.standard(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Continue'),
                      ),
                    ],
              ),
            ),
        ],
      ),
    );
  }
}
