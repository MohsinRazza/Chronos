import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';

enum ShadButtonVariant {
  standard, // 'default' is a keyword in Dart, so we use 'standard'
  secondary,
  outline,
  ghost,
  destructive
}

class ShadButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ShadButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final IconData? icon;
  final double iconSize;
  final bool isIconOnly;

  const ShadButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ShadButtonVariant.standard,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
    this.isIconOnly = false,
  });

  // Conveniences
  const ShadButton.standard({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
  }) : variant = ShadButtonVariant.standard, isIconOnly = false;

  const ShadButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
  }) : variant = ShadButtonVariant.secondary, isIconOnly = false;

  const ShadButton.outline({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
  }) : variant = ShadButtonVariant.outline, isIconOnly = false;

  const ShadButton.ghost({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
  }) : variant = ShadButtonVariant.ghost, isIconOnly = false;

  const ShadButton.destructive({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.icon,
    this.iconSize = 16.0,
  }) : variant = ShadButtonVariant.destructive, isIconOnly = false;

  const ShadButton.icon({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ShadButtonVariant.ghost,
    this.width = 36.0,
    this.height = 36.0,
    this.padding = EdgeInsets.zero,
    this.icon,
    this.iconSize = 16.0,
  }) : isIconOnly = true;

  @override
  State<ShadButton> createState() => _ShadButtonState();
}

class _ShadButtonState extends State<ShadButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final isEnabled = widget.onPressed != null;

    // Determine colors based on variant and state
    Color backgroundColor = Colors.transparent;
    Color foregroundColor = shadTheme.foreground;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case ShadButtonVariant.standard:
        backgroundColor = isEnabled
            ? (_isHovered ? shadTheme.primary.withOpacity(0.9) : shadTheme.primary)
            : shadTheme.muted;
        foregroundColor = shadTheme.primaryForeground;
        break;
      case ShadButtonVariant.secondary:
        backgroundColor = isEnabled
            ? (_isHovered ? shadTheme.secondary.withOpacity(0.8) : shadTheme.secondary)
            : shadTheme.muted.withOpacity(0.5);
        foregroundColor = shadTheme.secondaryForeground;
        break;
      case ShadButtonVariant.outline:
        backgroundColor = isEnabled
            ? (_isHovered ? (shadTheme.isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7)) : Colors.transparent)
            : Colors.transparent;
        foregroundColor = isEnabled
            ? (_isHovered ? shadTheme.accentForeground : shadTheme.foreground)
            : shadTheme.mutedForeground;
        borderSide = BorderSide(color: shadTheme.border, width: 1);
        break;
      case ShadButtonVariant.ghost:
        backgroundColor = isEnabled
            ? (_isHovered ? (shadTheme.isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7)) : Colors.transparent)
            : Colors.transparent;
        foregroundColor = isEnabled
            ? (_isHovered ? shadTheme.accentForeground : shadTheme.foreground)
            : shadTheme.mutedForeground;
        break;
      case ShadButtonVariant.destructive:
        backgroundColor = isEnabled
            ? (_isHovered ? shadTheme.destructive.withOpacity(0.9) : shadTheme.destructive)
            : shadTheme.muted;
        foregroundColor = shadTheme.destructiveForeground;
        break;
    }

    if (_isPressed && isEnabled) {
      backgroundColor = backgroundColor.withOpacity(0.8);
    }

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: widget.iconSize, color: foregroundColor),
          if (!widget.isIconOnly) const SizedBox(width: 8),
        ],
        if (!widget.isIconOnly)
          DefaultTextStyle(
            style: TextStyle(
              color: foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            child: widget.child,
          ),
      ],
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
            borderRadius: BorderRadius.circular(6),
            boxShadow: widget.variant == ShadButtonVariant.standard && _isHovered && isEnabled
                ? [
                    BoxShadow(
                      color: shadTheme.primary.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            widthFactor: widget.width == null ? 1.0 : null,
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
