import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/constants/cages_grid_constants.dart';

class CagesGridFloatingBar extends StatefulWidget {
  final List<RackSimpleDto>? racks;
  final RackSimpleDto? selectedRack;
  final Function(RackSimpleDto) onRackSelected;
  final VoidCallback onAddRack;
  final VoidCallback onEditRack;
  final String searchType;
  final String searchQuery;
  final Function(String) onSearchTypeChanged;
  final Function(String) onSearchQueryChanged;
  final double zoomLevel;

  const CagesGridFloatingBar({
    super.key,
    required this.racks,
    required this.selectedRack,
    required this.onRackSelected,
    required this.onAddRack,
    required this.onEditRack,
    required this.searchType,
    required this.searchQuery,
    required this.onSearchTypeChanged,
    required this.onSearchQueryChanged,
    required this.zoomLevel,
  });

  @override
  State<CagesGridFloatingBar> createState() => _CagesGridFloatingBarState();
}

class _CagesGridFloatingBarState extends State<CagesGridFloatingBar> {
  late TextEditingController _searchController;
  bool _isSearchExpanded = false;

  // Breakpoint for switching between compact and wide layouts
  static const double _compactBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(CagesGridFloatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
    if (oldWidget.searchType != widget.searchType) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        // Clear search when collapsing
        _searchController.clear();
        widget.onSearchQueryChanged('');
      }
    });
  }

  Widget _buildSettingsButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      onSelected: (value) {
        if (value == 'add') {
          widget.onAddRack();
        } else if (value == 'edit') {
          widget.onEditRack();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'add',
          child: Row(
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text('Add Rack'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit Rack'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTypeDropdown() {
    return DropdownButton<String>(
      value: widget.searchType,
      underline: const SizedBox(),
      isDense: true,
      items: const [
        DropdownMenuItem(
          value: CagesGridConstants.searchTypeAnimalTag,
          child: Text(CagesGridConstants.searchTypeAnimalTag),
        ),
        DropdownMenuItem(
          value: CagesGridConstants.searchTypeCageTag,
          child: Text(CagesGridConstants.searchTypeCageTag),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.onSearchTypeChanged(value);
        }
      },
    );
  }

  Widget _buildSearchField({double? maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 80, maxWidth: maxWidth ?? 150),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchQueryChanged,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.zoom_in,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '${(widget.zoomLevel * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIconButton() {
    final hasActiveSearch = widget.searchQuery.isNotEmpty;
    return IconButton(
      icon: Icon(
        Icons.search,
        color: hasActiveSearch ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: _toggleSearch,
      tooltip: 'Search',
    );
  }

  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Rack selector and settings
        Row(
          children: [
            RackSelector(
              widget.racks,
              onRackSelected: widget.onRackSelected,
              selectedRack: widget.selectedRack,
            ),
            const SizedBox(width: 8),
            _buildSettingsButton(),
          ],
        ),
        // Right side: Search and zoom
        Row(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSearchTypeDropdown(),
                  const SizedBox(width: 8),
                  _buildSearchField(maxWidth: 150),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildZoomIndicator(),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main row: Rack selector, settings, search icon, and zoom
          Row(
            children: [
              Expanded(
                child: RackSelector(
                  widget.racks,
                  onRackSelected: widget.onRackSelected,
                  selectedRack: widget.selectedRack,
                ),
              ),
              _buildSettingsButton(),
              _buildSearchIconButton(),
              const SizedBox(width: 8),
              _buildZoomIndicator(),
            ],
          ),
          // Expandable search row
          if (_isSearchExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  _buildSearchTypeDropdown(),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSearchField(maxWidth: double.infinity)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _toggleSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Close search',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCompact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isCompact ? _buildCompactLayout() : _buildWideLayout(),
        );
      },
    );
  }
}

class RackSelector extends StatelessWidget {
  const RackSelector(
    this.racks, {
    required this.selectedRack,
    required this.onRackSelected,
    super.key,
  });

  final List<RackSimpleDto>? racks;
  final RackSimpleDto? selectedRack;
  final Function(RackSimpleDto) onRackSelected;

  @override
  Widget build(BuildContext context) {
    if (racks == null || racks!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<RackSimpleDto>(
        value: selectedRack,
        hint: const Text('Select Rack'),
        underline: const SizedBox(),
        isDense: true,
        items: racks!.map((rack) {
          return DropdownMenuItem<RackSimpleDto>(
            value: rack,
            child: Text(rack.rackName ?? 'Unnamed Rack'),
          );
        }).toList(),
        onChanged: (rack) {
          if (rack != null) {
            onRackSelected(rack);
          }
        },
      ),
    );
  }
}
