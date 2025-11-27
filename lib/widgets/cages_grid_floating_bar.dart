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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Rack selector and settings
          Row(
            children: [
              // Rack selector dropdown
              if (widget.racks != null && widget.racks!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<RackSimpleDto>(
                    value: widget.selectedRack,
                    hint: const Text('Select Rack'),
                    underline: const SizedBox(),
                    isDense: true,
                    items: widget.racks!.map((rack) {
                      return DropdownMenuItem<RackSimpleDto>(
                        value: rack,
                        child: Text(rack.rackName ?? 'Unnamed Rack'),
                      );
                    }).toList(),
                    onChanged: (rack) {
                      if (rack != null) {
                        widget.onRackSelected(rack);
                      }
                    },
                  ),
                ),
              const SizedBox(width: 8),
              // Settings button
              PopupMenuButton<String>(
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
              ),
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
                    // Search type dropdown
                    DropdownButton<String>(
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
                    ),
                    const SizedBox(width: 8),
                    // Search text field
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _searchController,
                        onChanged: widget.onSearchQueryChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Zoom percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
