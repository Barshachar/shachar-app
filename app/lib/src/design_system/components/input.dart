/// Enterprise-grade Input components
/// Professional form inputs with validation, icons, and states
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashachar_marketplace/src/design_system/tokens/tokens.dart';

/// Input sizes
enum InputSize { sm, md, lg }

/// Input component with enterprise features
class AppInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputSize size;
  final bool isDisabled;
  final bool isRequired;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool readOnly;

  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.size = InputSize.md,
    this.isDisabled = false,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  InputDecoration _getInputDecoration() {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? SemanticColors.destructive
        : _isFocused
            ? SemanticColors.borderFocus
            : SemanticColors.border;

    return InputDecoration(
      hintText: widget.placeholder,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      filled: true,
      fillColor:
          widget.isDisabled ? SemanticColors.muted : SemanticColors.background,
      contentPadding: _getPadding(),
      border: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide: BorderSide(color: SemanticColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide: BorderSide(color: SemanticColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide: BorderSide(color: SemanticColors.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide: BorderSide(color: SemanticColors.destructive, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadii.input,
        borderSide:
            BorderSide(color: SemanticColors.border.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        iconSize: _getIconSize(),
      );
    }
    return widget.suffixIcon;
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case InputSize.sm:
        return Insets.inputSm;
      case InputSize.md:
        return Insets.inputMd;
      case InputSize.lg:
        return Insets.inputLg;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case InputSize.sm:
        return Sizes.iconSm;
      case InputSize.md:
        return Sizes.iconMd;
      case InputSize.lg:
        return Sizes.iconLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TypographyPresets.labelMd(
                  color: SemanticColors.foreground,
                ),
              ),
              if (widget.isRequired) ...[
                Gaps.h1,
                Text(
                  '*',
                  style: TypographyPresets.labelMd(
                    color: SemanticColors.destructive,
                  ),
                ),
              ],
            ],
          ),
          Gaps.v2,
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: _getInputDecoration(),
          enabled: !widget.isDisabled,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          style: TypographyPresets.bodyMd(),
        ),
      ],
    );
  }
}

/// Textarea component (multi-line input)
class AppTextarea extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool isDisabled;
  final bool isRequired;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const AppTextarea({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.isRequired = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      label: label,
      placeholder: placeholder,
      helperText: helperText,
      errorText: errorText,
      isDisabled: isDisabled,
      isRequired: isRequired,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
    );
  }
}

/// Select/Dropdown component
class AppSelect<T> extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool isDisabled;
  final bool isRequired;
  final InputSize size;

  const AppSelect({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.value,
    required this.options,
    this.onChanged,
    this.isDisabled = false,
    this.isRequired = false,
    this.size = InputSize.md,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TypographyPresets.labelMd(
                  color: SemanticColors.foreground,
                ),
              ),
              if (isRequired) ...[
                Gaps.h1,
                Text(
                  '*',
                  style: TypographyPresets.labelMd(
                    color: SemanticColors.destructive,
                  ),
                ),
              ],
            ],
          ),
          Gaps.v2,
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: options
              .map((option) => DropdownMenuItem<T>(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
          onChanged: isDisabled ? null : onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            helperText: helperText,
            errorText: errorText,
            filled: true,
            fillColor:
                isDisabled ? SemanticColors.muted : SemanticColors.background,
            contentPadding: _getPadding(),
            border: OutlineInputBorder(
              borderRadius: BorderRadii.input,
              borderSide: BorderSide(color: SemanticColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadii.input,
              borderSide: BorderSide(color: SemanticColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadii.input,
              borderSide:
                  BorderSide(color: SemanticColors.borderFocus, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadii.input,
              borderSide: BorderSide(color: SemanticColors.destructive),
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case InputSize.sm:
        return Insets.inputSm;
      case InputSize.md:
        return Insets.inputMd;
      case InputSize.lg:
        return Insets.inputLg;
    }
  }
}

/// Select option model
class AppSelectOption<T> {
  final T value;
  final String label;
  final bool isDisabled;

  const AppSelectOption({
    required this.value,
    required this.label,
    this.isDisabled = false,
  });
}

/// Checkbox component
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool isDisabled;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadii.sm,
      child: Padding(
        padding: Insets.all2,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Sizes.iconMd,
              height: Sizes.iconMd,
              child: Checkbox(
                value: value,
                onChanged: isDisabled ? null : onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadii.xs,
                ),
              ),
            ),
            if (label != null) ...[
              Gaps.h2,
              Flexible(
                child: Text(
                  label!,
                  style: TypographyPresets.bodyMd(
                    color: isDisabled
                        ? SemanticColors.mutedForeground
                        : SemanticColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Radio button component
class AppRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final bool isDisabled;

  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || onChanged == null ? null : () => onChanged!(value),
      borderRadius: BorderRadii.sm,
      child: Padding(
        padding: Insets.all2,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Sizes.iconMd,
              height: Sizes.iconMd,
              child: Radio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: isDisabled ? null : onChanged,
              ),
            ),
            if (label != null) ...[
              Gaps.h2,
              Flexible(
                child: Text(
                  label!,
                  style: TypographyPresets.bodyMd(
                    color: isDisabled
                        ? SemanticColors.mutedForeground
                        : SemanticColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Switch/Toggle component
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool isDisabled;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadii.sm,
      child: Padding(
        padding: Insets.all2,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: value,
              onChanged: isDisabled ? null : onChanged,
            ),
            if (label != null) ...[
              Gaps.h2,
              Flexible(
                child: Text(
                  label!,
                  style: TypographyPresets.bodyMd(
                    color: isDisabled
                        ? SemanticColors.mutedForeground
                        : SemanticColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
