import 'package:flutter/material.dart';
import 'package:moustra/services/clients/favorite_api.dart';

/// A small star icon button that toggles favorite status.
///
/// Uses optimistic toggling: flips the UI immediately, then calls the API
/// in the background. Reverts on failure.
class FavoriteButton extends StatefulWidget {
  final String objectType;
  final String objectUuid;
  final bool isFavorited;
  final VoidCallback? onToggle;
  final double iconSize;

  const FavoriteButton({
    super.key,
    required this.objectType,
    required this.objectUuid,
    this.isFavorited = false,
    this.onToggle,
    this.iconSize = 22,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorited != widget.isFavorited) {
      _isFavorited = widget.isFavorited;
    }
  }

  Future<void> _handleToggle() async {
    // Optimistic toggle
    setState(() {
      _isFavorited = !_isFavorited;
    });
    widget.onToggle?.call();

    try {
      await favoriteApi.toggle(widget.objectType, widget.objectUuid);
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
      button: true,
      child: IconButton(
        icon: Icon(
          _isFavorited ? Icons.star : Icons.star_border,
          color: _isFavorited ? Colors.amber : null,
          size: widget.iconSize,
        ),
        onPressed: _handleToggle,
        tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
