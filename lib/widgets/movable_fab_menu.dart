import 'package:flutter/material.dart';

class FabMenuAction {
  FabMenuAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.closeOnTap = true,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool closeOnTap;
}

class MovableFabMenuController {
  _MovableFabMenuState? _state;

  bool get isOpen => _state?._menuOpen ?? false;

  void open() => _state?._setMenuOpen(true);
  void close() => _state?._setMenuOpen(false);
  void toggle() => _state?._setMenuOpen(!isOpen);

  void _attach(_MovableFabMenuState state) => _state = state;

  void _detach(_MovableFabMenuState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class MovableFabMenu extends StatefulWidget {
  const MovableFabMenu({
    super.key,
    required this.actions,
    required this.heroTag,
    this.controller,
    this.margin = const EdgeInsets.only(right: 24, bottom: 24),
    this.menuIcon = const Icon(Icons.menu),
    this.closeIcon = const Icon(Icons.close),
  });

  final List<FabMenuAction> actions;
  final String heroTag;
  final MovableFabMenuController? controller;
  final EdgeInsets margin;
  final Widget menuIcon;
  final Widget closeIcon;

  @override
  State<MovableFabMenu> createState() => _MovableFabMenuState();
}

class _MovableFabMenuState extends State<MovableFabMenu> {
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant MovableFabMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  void _setMenuOpen(bool open) {
    if (_menuOpen == open) {
      return;
    }
    setState(() {
      _menuOpen = open;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              right: widget.margin.right,
              bottom: widget.margin.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_menuOpen && widget.actions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (
                            int index = 0;
                            index < widget.actions.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                              child: _buildAction(widget.actions[index]),
                            ),
                        ],
                      ),
                    ),
                  FloatingActionButton(
                    heroTag: widget.heroTag,
                    onPressed: () => _setMenuOpen(!_menuOpen),
                    child: _menuOpen ? widget.closeIcon : widget.menuIcon,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAction(FabMenuAction action) {
    final bool isEnabled = action.enabled && action.onPressed != null;
    return FilledButton.icon(
      onPressed: isEnabled
          ? () {
              action.onPressed?.call();
              if (action.closeOnTap) {
                _setMenuOpen(false);
              }
            }
          : null,
      icon: action.icon,
      label: Text(action.label),
    );
  }
}
