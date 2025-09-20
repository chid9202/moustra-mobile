import 'package:flutter/material.dart';
import 'package:moustra/app/mui_color.dart';

enum ButtonVariant { primary, secondary, success, warning, error, info }

enum ButtonSize { small, medium, large }

class MoustraButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool fullWidth;

  const MoustraButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
  });

  const MoustraButton.icon({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final buttonSize = _getButtonSize();

    Widget button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? SizedBox(
              height: buttonSize.iconSize,
              width: buttonSize.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getButtonTextColor(context),
                ),
              ),
            )
          : _buildButtonContent(),
    );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getButtonSize().iconSize),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mui = Theme.of(context).extension<MUIExtraColors>();

    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case ButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        break;
      case ButtonVariant.success:
        backgroundColor = mui?.success ?? const Color(0xFF2E7D32);
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.warning:
        backgroundColor = mui?.warning ?? const Color(0xFFED6C02);
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.error:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
      case ButtonVariant.info:
        backgroundColor = mui?.info ?? const Color(0xFF0288D1);
        foregroundColor = Colors.white;
        break;
    }

    final size = _getButtonSize();

    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: size.padding,
      minimumSize: size.minimumSize,
      textStyle: size.textStyle,
    );
  }

  Color _getButtonTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mui = Theme.of(context).extension<MUIExtraColors>();

    switch (variant) {
      case ButtonVariant.primary:
        return colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return colorScheme.onSecondary;
      case ButtonVariant.success:
      case ButtonVariant.warning:
      case ButtonVariant.info:
        return Colors.white;
      case ButtonVariant.error:
        return colorScheme.onError;
    }
  }

  _ButtonSizeData _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSizeData(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(80, 32),
          textStyle: const TextStyle(fontSize: 12),
          iconSize: 16,
        );
      case ButtonSize.medium:
        return _ButtonSizeData(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(100, 40),
          textStyle: const TextStyle(fontSize: 14),
          iconSize: 18,
        );
      case ButtonSize.large:
        return _ButtonSizeData(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(120, 48),
          textStyle: const TextStyle(fontSize: 16),
          iconSize: 20,
        );
    }
  }
}

class _ButtonSizeData {
  final EdgeInsets padding;
  final Size minimumSize;
  final TextStyle textStyle;
  final double iconSize;

  _ButtonSizeData({
    required this.padding,
    required this.minimumSize,
    required this.textStyle,
    required this.iconSize,
  });
}

// Convenience constructors for common button types
class MoustraButtonPrimary extends MoustraButton {
  const MoustraButtonPrimary({
    super.key,
    required super.label,
    super.icon,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.fullWidth = false,
  }) : super(variant: ButtonVariant.primary);
}

class MoustraButtonSuccess extends MoustraButton {
  const MoustraButtonSuccess({
    super.key,
    required super.label,
    super.icon,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.fullWidth = false,
  }) : super(variant: ButtonVariant.success);
}

class MoustraButtonError extends MoustraButton {
  const MoustraButtonError({
    super.key,
    required super.label,
    super.icon,
    super.onPressed,
    super.size = ButtonSize.medium,
    super.isLoading = false,
    super.fullWidth = false,
  }) : super(variant: ButtonVariant.error);
}
