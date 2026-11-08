import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final double borderRadius;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.textInputAction,
    this.keyboardType,
    this.borderRadius = 16,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(widget.borderRadius);
    final borderSide = BorderSide(
      color: widget.errorText != null
          ? colorScheme.error
          : colorScheme.outlineVariant.withValues(alpha: 0.35),
      width: 1.2,
    );
    final focusedBorderSide = BorderSide(
      color: widget.errorText != null
          ? colorScheme.error
          : colorScheme.primary,
      width: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: colorScheme.primary.withValues(alpha: 0.7),
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: borderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: borderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: focusedBorderSide,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1.6,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
