import 'dart:async';
import 'package:flutter/material.dart';
import '../state/wizard_state.dart';
import '../colony_wizard_constants.dart';

class UndoSnackbarWidget extends StatefulWidget {
  final UndoAction action;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  const UndoSnackbarWidget({
    super.key,
    required this.action,
    required this.onUndo,
    required this.onDismiss,
  });

  @override
  State<UndoSnackbarWidget> createState() => _UndoSnackbarWidgetState();
}

class _UndoSnackbarWidgetState extends State<UndoSnackbarWidget> {
  Timer? _dismissTimer;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _startDismissTimer();
  }

  @override
  void didUpdateWidget(UndoSnackbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action != oldWidget.action) {
      _dismissTimer?.cancel();
      _startDismissTimer();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(
      ColonyWizardConstants.undoSnackbarDuration,
      widget.onDismiss,
    );
  }

  Future<void> _handleUndo() async {
    if (_isExecuting) return;
    setState(() {
      _isExecuting = true;
    });
    _dismissTimer?.cancel();
    
    try {
      widget.onUndo();
    } finally {
      if (mounted) {
        setState(() {
          _isExecuting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.action.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (_isExecuting)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.inversePrimary,
              ),
            )
          else
            TextButton(
              onPressed: _handleUndo,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.inversePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('UNDO'),
            ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: theme.colorScheme.onInverseSurface.withOpacity(0.7),
            ),
            onPressed: widget.onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
