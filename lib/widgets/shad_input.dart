import 'package:flutter/material.dart';
import '../theme/shadcn_theme.dart';

class ShadInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final String? helperText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;

  const ShadInput({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.helperText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
  });

  @override
  State<ShadInput> createState() => _ShadInputState();
}

class _ShadInputState extends State<ShadInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: shadTheme.foreground,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isFocused ? shadTheme.ring : shadTheme.border,
              width: 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: shadTheme.ring.withOpacity(0.15),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: 10),
                Icon(
                  widget.prefixIcon,
                  size: 16,
                  color: shadTheme.mutedForeground,
                ),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: 14,
                    color: shadTheme.foreground,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      color: shadTheme.mutedForeground,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                widget.suffix!,
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: shadTheme.mutedForeground,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }
}
