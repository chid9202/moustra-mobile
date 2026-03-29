import 'package:flutter/material.dart';

/// A generic entity for the picker — any object with a label and key.
typedef EntityLabel<T> = String Function(T entity);
typedef EntityKey<T> = String Function(T entity);
typedef EntityFilter<T> = bool Function(T entity, String query);

/// Shows a bottom sheet with a search bar and scrollable list of entities.
/// Used for autocomplete fields (strain, cage, owner, sire) in inline editing.
///
/// Returns the selected entity, or null if dismissed.
Future<T?> showEntityPickerSheet<T>({
  required BuildContext context,
  required List<T> options,
  required EntityLabel<T> getLabel,
  required EntityKey<T> getKey,
  EntityFilter<T>? filter,
  String title = 'Select',
  String searchHint = 'Search...',
  T? currentValue,
  Widget Function(T entity, bool isSelected)? itemBuilder,
  bool showSearch = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _EntityPickerContent<T>(
      options: options,
      getLabel: getLabel,
      getKey: getKey,
      filter: filter,
      title: title,
      searchHint: searchHint,
      currentValue: currentValue,
      itemBuilder: itemBuilder,
      showSearch: showSearch,
    ),
  );
}

class _EntityPickerContent<T> extends StatefulWidget {
  final List<T> options;
  final EntityLabel<T> getLabel;
  final EntityKey<T> getKey;
  final EntityFilter<T>? filter;
  final String title;
  final String searchHint;
  final T? currentValue;
  final Widget Function(T entity, bool isSelected)? itemBuilder;
  final bool showSearch;

  const _EntityPickerContent({
    required this.options,
    required this.getLabel,
    required this.getKey,
    this.filter,
    required this.title,
    required this.searchHint,
    this.currentValue,
    this.itemBuilder,
    this.showSearch = false,
  });

  @override
  State<_EntityPickerContent<T>> createState() =>
      _EntityPickerContentState<T>();
}

class _EntityPickerContentState<T> extends State<_EntityPickerContent<T>> {
  String _query = '';

  List<T> get _filtered {
    if (_query.isEmpty) return widget.options;
    if (widget.filter != null) {
      return widget.options.where((e) => widget.filter!(e, _query)).toList();
    }
    return widget.options
        .where(
          (e) => widget
              .getLabel(e)
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final selectedKey =
        widget.currentValue != null ? widget.getKey(widget.currentValue as T) : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search (optional)
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            const Divider(height: 1),
            // Options list
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entity = filtered[index];
                        final isSelected =
                            selectedKey != null &&
                            widget.getKey(entity) == selectedKey;

                        if (widget.itemBuilder != null) {
                          return InkWell(
                            onTap: () => Navigator.pop(context, entity),
                            child: widget.itemBuilder!(entity, isSelected),
                          );
                        }

                        return ListTile(
                          title: Text(
                            widget.getLabel(entity),
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () => Navigator.pop(context, entity),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
