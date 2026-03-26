import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/favorite_api.dart';
import 'package:moustra/services/dtos/favorite_dto.dart';
import 'package:moustra/widgets/favorite_button.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

/// Displays favorited items grouped by type.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteDto>? _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await favoriteApi.getAll();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showAppSnackBar(context, 'Error loading favorites: $e', isError: true);
      }
    }
  }

  /// Group favorites by objectType and return a sorted map.
  Map<String, List<FavoriteDto>> _groupByType(List<FavoriteDto> favorites) {
    final Map<String, List<FavoriteDto>> grouped = {};
    for (final fav in favorites) {
      grouped.putIfAbsent(fav.objectType, () => []).add(fav);
    }
    // Sort keys for consistent ordering
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  String _formatObjectType(String type) {
    switch (type) {
      case 'cage':
        return 'Cages';
      case 'animal':
        return 'Animals';
      case 'mating':
        return 'Matings';
      case 'litter':
        return 'Litters';
      case 'plug_event':
        return 'Plug Events';
      case 'strain':
        return 'Strains';
      default:
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'cage':
        return Icons.grid_view_sharp;
      case 'animal':
        return Icons.pest_control_rodent_sharp;
      case 'mating':
        return Icons.call_merge_sharp;
      case 'litter':
        return Icons.create_new_folder_sharp;
      case 'plug_event':
        return Icons.event_note;
      case 'strain':
        return Icons.bookmark_sharp;
      default:
        return Icons.star;
    }
  }

  void _navigateToDetail(FavoriteDto fav) {
    switch (fav.objectType) {
      case 'cage':
        context.go('/cage/${fav.objectUuid}');
        break;
      case 'animal':
        context.go('/animal/${fav.objectUuid}');
        break;
      case 'mating':
        context.go('/mating/${fav.objectUuid}');
        break;
      case 'litter':
        context.go('/litter/${fav.objectUuid}');
        break;
      case 'plug_event':
        context.go('/plug-event/${fav.objectUuid}');
        break;
      case 'strain':
        context.go('/strain/${fav.objectUuid}');
        break;
    }
  }

  void _handleUnfavorite(FavoriteDto fav) {
    setState(() {
      _favorites?.remove(fav);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final favorites = _favorites;
    if (favorites == null || favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the star icon on any item to add it here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByType(favorites);

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final type = grouped.keys.elementAt(index);
          final items = grouped[type]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 16),
              // Section header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(type),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatObjectType(type),
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${items.length})',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                    ),
                  ],
                ),
              ),
              // Items
              ...items.map(
                (fav) => Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Icon(_getIconForType(fav.objectType)),
                    title: Text(
                      '${_formatObjectType(fav.objectType).replaceAll(RegExp(r's$'), '')} ${fav.objectUuid.substring(0, 8)}…',
                    ),
                    subtitle: Text(
                      'Added ${_formatDate(fav.createdDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: FavoriteButton(
                      objectType: fav.objectType,
                      objectUuid: fav.objectUuid,
                      isFavorited: true,
                      onToggle: () => _handleUnfavorite(fav),
                    ),
                    onTap: () => _navigateToDetail(fav),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
