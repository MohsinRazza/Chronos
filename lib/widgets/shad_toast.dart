import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';

class ShadToast {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    bool isDestructive = false,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ShadToastWidget(
          title: title,
          description: description,
          icon: icon,
          duration: duration,
          isDestructive: isDestructive,
          onDismiss: () {
            overlayEntry.remove();
          },
        );
      },
    );

    overlayState.insert(overlayEntry);
  }
}

class _ShadToastWidget extends StatefulWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Duration duration;
  final bool isDestructive;
  final VoidCallback onDismiss;

  const _ShadToastWidget({
    required this.title,
    this.description,
    this.icon,
    required this.duration,
    required this.isDestructive,
    required this.onDismiss,
  });

  @override
  State<_ShadToastWidget> createState() => _ShadToastWidgetState();
}

class _ShadToastWidgetState extends State<_ShadToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (mounted && _controller.isAnimating == false) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    final backgroundColor = widget.isDestructive 
        ? (theme.isDark ? const Color(0xFF450A0A) : Colors.red.shade50)
        : theme.background;
    final borderColor = widget.isDestructive 
        ? Colors.red.shade600 
        : theme.border;
    final textColor = widget.isDestructive 
        ? (theme.isDark ? Colors.red.shade100 : Colors.red.shade900)
        : theme.foreground;
    final descriptionColor = widget.isDestructive 
        ? (theme.isDark ? Colors.red.shade300 : Colors.red.shade700)
        : theme.mutedForeground;

    return Positioned(
      bottom: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: descriptionColor,
                            fontFamily: 'Inter',
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismiss,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: widget.isDestructive ? descriptionColor : theme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
