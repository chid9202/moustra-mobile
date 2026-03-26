import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:moustra/screens/barcode_scanner_screen.dart';

/// Display mode for the barcode preview.
enum BarcodeDisplayType { barcode, qr }

/// Reusable barcode field with:
/// 1. Text input (type or paste)
/// 2. Camera scan button (opens BarcodeScannerScreen)
/// 3. Inline barcode / QR code preview
class BarcodeField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool enabled;
  final String? Function(String?)? validator;

  const BarcodeField({
    super.key,
    required this.controller,
    this.labelText = 'Barcode',
    this.hintText = 'Enter or scan barcode',
    this.enabled = true,
    this.validator,
  });

  @override
  State<BarcodeField> createState() => _BarcodeFieldState();
}

class _BarcodeFieldState extends State<BarcodeField> {
  BarcodeDisplayType _displayType = BarcodeDisplayType.barcode;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild to show/hide preview
    if (mounted) setState(() {});
  }

  Future<void> _scanBarcode() async {
    try {
      final String? barcode = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );
      if (barcode != null && mounted) {
        widget.controller.text = barcode;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning barcode: $e')),
        );
      }
    }
  }

  bool get _hasValue => widget.controller.text.trim().isNotEmpty;

  bool get _isValidForCode128 {
    if (!_hasValue) return false;
    // Code128 supports ASCII 0-127
    return widget.controller.text.codeUnits.every((c) => c < 128);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = widget.controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text input with scan button
        Semantics(
          label: widget.labelText,
          textField: true,
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: _hasValue
                  ? const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                    )
                  : const OutlineInputBorder(),
              enabledBorder: _hasValue
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    )
                  : null,
              focusedBorder: _hasValue
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
              suffixIcon: Semantics(
                label: 'Scan barcode',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: widget.enabled ? _scanBarcode : null,
                  tooltip: 'Scan barcode',
                ),
              ),
            ),
          ),
        ),

        // Preview — attached to the bottom of the input
        if (_hasValue)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                left: BorderSide(color: theme.colorScheme.outline),
                right: BorderSide(color: theme.colorScheme.outline),
                bottom: BorderSide(color: theme.colorScheme.outline),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Code visual
                Expanded(
                  child: Center(
                    child: _displayType == BarcodeDisplayType.qr
                        ? bw.BarcodeWidget(
                            barcode: bw.Barcode.qrCode(),
                            data: value,
                            width: 64,
                            height: 64,
                            drawText: false,
                          )
                        : _isValidForCode128
                            ? bw.BarcodeWidget(
                                barcode: bw.Barcode.code128(),
                                data: value,
                                height: 36,
                                drawText: false,
                              )
                            : Text(
                                'Cannot render barcode — try QR.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle
                SegmentedButton<BarcodeDisplayType>(
                  segments: const [
                    ButtonSegment(
                      value: BarcodeDisplayType.barcode,
                      icon: Icon(Icons.view_week, size: 16),
                    ),
                    ButtonSegment(
                      value: BarcodeDisplayType.qr,
                      icon: Icon(Icons.qr_code_2, size: 16),
                    ),
                  ],
                  selected: {_displayType},
                  onSelectionChanged: (selected) {
                    setState(() => _displayType = selected.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
