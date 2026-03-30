import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/dialogs/add_or_update_rack.dart';

class RackDetailScreen extends StatefulWidget {
  const RackDetailScreen({super.key});

  @override
  State<RackDetailScreen> createState() => _RackDetailScreenState();
}

class _RackDetailScreenState extends State<RackDetailScreen> {
  RackDto? _rack;
  bool _isLoading = true;
  String? _error;

  // Arrange mode
  bool _isArrangeMode = false;
  String? _selectedCageUuid;
  bool _isMoving = false;

  // Sort
  String _sortField = 'position';
  bool _sortAsc = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rack == null && _isLoading) {
      _fetchRack();
    }
  }

  String get _rackUuid {
    return GoRouterState.of(context).pathParameters['rackUuid'] ?? '';
  }

  Future<void> _fetchRack({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final rack = await rackApi.getRack(rackUuid: _rackUuid);
      if (mounted) {
        setState(() {
          _rack = rack;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (!silent) _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddOrUpdateRackDialog(
        rackData: _rack,
        onSuccess: ({String? rackUuid}) async {
          await _fetchRack();
        },
      ),
    );
  }

  void _toggleArrangeMode() {
    setState(() {
      _isArrangeMode = !_isArrangeMode;
      _selectedCageUuid = null;
    });
  }

  Future<void> _handleSnapshotCellTap(
    String? cellCageUuid,
    int x,
    int y,
  ) async {
    if (!_isArrangeMode || _isMoving) return;

    // Nothing selected yet — select a cage
    if (_selectedCageUuid == null) {
      if (cellCageUuid != null) {
        setState(() => _selectedCageUuid = cellCageUuid);
      }
      return;
    }

    // Clicking the already-selected cage — deselect
    if (cellCageUuid == _selectedCageUuid) {
      setState(() => _selectedCageUuid = null);
      return;
    }

    // A cage is selected — perform move or swap
    setState(() => _isMoving = true);
    try {
      if (cellCageUuid != null) {
        // Target is occupied → swap
        await cageApi.swapCage(_selectedCageUuid!, cellCageUuid);
        if (mounted) {
          showAppSnackBar(context, 'Cages swapped', isSuccess: true);
        }
      } else {
        // Target is empty → move
        await cageApi.moveCage(_selectedCageUuid!, x: x, y: y);
        if (mounted) {
          showAppSnackBar(context, 'Cage moved', isSuccess: true);
        }
      }
      setState(() => _selectedCageUuid = null);
      await _fetchRack(silent: true);
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to update cage position', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isMoving = false);
    }
  }

  void _handleOverflowCageTap(String cageUuid) {
    if (!_isArrangeMode) return;
    if (_selectedCageUuid == cageUuid) {
      setState(() => _selectedCageUuid = null);
    } else {
      setState(() => _selectedCageUuid = cageUuid);
    }
  }

  Future<void> _handleUnsetPosition(String cageUuid) async {
    setState(() => _isMoving = true);
    try {
      await cageApi.unsetCagePosition(cageUuid);
      if (mounted) {
        showAppSnackBar(context, 'Position cleared', isSuccess: true);
      }
      await _fetchRack(silent: true);
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to clear position', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isMoving = false);
    }
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(_rack?.rackName ?? 'Rack'),
    );

    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _rack == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Rack not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final rack = _rack!;
    final rackWidth = rack.rackWidth ?? 1;
    final rackHeight = rack.rackHeight ?? 1;
    final insights = getRackInsights(rack);
    final cagesWithPosition = getRackCagesWithPosition(
      rack.cages ?? [],
      rackWidth,
      rackHeight,
    );

    // Build cage position map
    final cagesByPosition = <String, RackCageWithPosition>{};
    for (final cwp in cagesWithPosition) {
      if (cwp.position != null) {
        cagesByPosition['${cwp.position!.x}-${cwp.position!.y}'] = cwp;
      }
    }

    // Overflow cages (no position or out of bounds)
    final overflowCages = cagesWithPosition.where((cwp) {
      if (cwp.position == null) return true;
      return cwp.position!.x >= rackWidth || cwp.position!.y >= rackHeight;
    }).toList();

    // Build sorted cage list
    final cageRows = cagesWithPosition.map((cwp) => cwp).toList();
    cageRows.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'cage':
          cmp = (a.cage.cageTag ?? '').compareTo(b.cage.cageTag ?? '');
          break;
        case 'strain':
          cmp = (a.cage.strain?.strainName ?? '')
              .compareTo(b.cage.strain?.strainName ?? '');
          break;
        case 'animals':
          cmp = (a.cage.animals?.length ?? 0)
              .compareTo(b.cage.animals?.length ?? 0);
          break;
        case 'status':
          cmp = (a.cage.status ?? '').compareTo(b.cage.status ?? '');
          break;
        case 'position':
        default:
          cmp = a.positionLabel.compareTo(b.positionLabel);
          break;
      }
      return _sortAsc ? cmp : -cmp;
    });

    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: _fetchRack,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(rack, insights),
            ),

            // Insight cards
            SliverToBoxAdapter(
              child: _buildInsightCards(insights),
            ),

            // Rack Snapshot
            SliverToBoxAdapter(
              child: _buildRackSnapshot(
                rack,
                rackWidth,
                rackHeight,
                cagesByPosition,
                overflowCages: overflowCages,
              ),
            ),

            // Cage list header
            SliverToBoxAdapter(
              child: _buildCageListHeader(cageRows.length, overflowCages.length),
            ),

            // Cage list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cwp = cageRows[index];
                  return _buildCageListTile(cwp);
                },
                childCount: cageRows.length,
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RackDto rack, RackInsights insights) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rack.rackName ?? 'Unnamed Rack',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rack.rackWidth} × ${rack.rackHeight} rack · ${insights.totalPositions} positions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _openEditDialog();
                      break;
                    case 'grid':
                      context.go('/cage/grid');
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'grid',
                    child: Row(
                      children: [
                        Icon(Icons.grid_view, size: 20),
                        SizedBox(width: 8),
                        Text('Grid View'),
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
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCards(RackInsights insights) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _InsightCard(
              icon: Icons.grid_view,
              label: 'Utilization',
              value: '${insights.utilizationPct.toStringAsFixed(0)}%',
              caption: '${insights.occupiedCages} / ${insights.totalPositions}',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InsightCard(
              icon: Icons.pets,
              label: 'Animals',
              value: '${insights.totalAnimals}',
              caption: 'across all cages',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InsightCard(
              icon: Icons.attach_money,
              label: 'Weekly',
              value: '\$${insights.estimatedWeeklyCost.toStringAsFixed(0)}',
              caption: '\$${estimatedCageCostPerDay.toStringAsFixed(2)}/cage/day',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRackSnapshot(
    RackDto rack,
    int rackWidth,
    int rackHeight,
    Map<String, RackCageWithPosition> cagesByPosition, {
    List<RackCageWithPosition> overflowCages = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _isArrangeMode
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: _isArrangeMode ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Snapshot header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rack Snapshot',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isArrangeMode
                              ? _selectedCageUuid != null
                                  ? 'Tap a position to move, or another cage to swap'
                                  : 'Select a cage to move'
                              : 'Tap any cage to view details',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (_isArrangeMode)
                    TextButton.icon(
                      onPressed: _toggleArrangeMode,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Done'),
                    )
                  else
                    TextButton.icon(
                      onPressed: _toggleArrangeMode,
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Arrange'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Unpositioned cages (arrange mode only)
              if (_isArrangeMode && overflowCages.isNotEmpty) ...[
                Text(
                  'Unpositioned (${overflowCages.length}) — select, then tap an empty cell',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: overflowCages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final cwp = overflowCages[index];
                      final isSelected = cwp.cage.cageUuid == _selectedCageUuid;
                      return ActionChip(
                        label: Text(
                          cwp.cage.cageTag ?? '(untagged)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _handleOverflowCageTap(cwp.cage.cageUuid),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Grid
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: rackWidth * 80.0 < MediaQuery.of(context).size.width - 48
                          ? MediaQuery.of(context).size.width - 48
                          : rackWidth * 80.0,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rackWidth * rackHeight,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rackWidth,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final x = index % rackWidth;
                          final y = index ~/ rackWidth;
                          final posLabel = getRackPositionLabel(
                            RackGridPosition(x: x, y: y),
                          );
                          final cwp = cagesByPosition['$x-$y'];
                          final cage = cwp?.cage;
                          final isSelected = cage != null &&
                              cage.cageUuid == _selectedCageUuid;
                          final isValidTarget = _isArrangeMode &&
                              _selectedCageUuid != null &&
                              !isSelected;

                          return _SnapshotCell(
                            positionLabel: posLabel,
                            cageTag: cage?.cageTag,
                            animalCount: cage?.animals?.length ?? 0,
                            isOccupied: cage != null,
                            isSelected: isSelected,
                            isValidTarget: isValidTarget,
                            isArrangeMode: _isArrangeMode,
                            onTap: () {
                              if (_isArrangeMode) {
                                _handleSnapshotCellTap(
                                  cage?.cageUuid,
                                  x,
                                  y,
                                );
                              } else if (cage != null) {
                                context.push('/cage/${cage.cageUuid}');
                              }
                            },
                            onUnset: _isArrangeMode && cage != null
                                ? () => _handleUnsetPosition(cage.cageUuid)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  if (_isMoving)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCageListHeader(int count, int unpositionedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cages in Rack',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count cage${count == 1 ? '' : 's'} total${unpositionedCount > 0 ? ' · $unpositionedCount unpositioned' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          // Sort chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  label: 'Position',
                  field: 'position',
                  currentField: _sortField,
                  isAsc: _sortAsc,
                  onTap: _setSort,
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Cage',
                  field: 'cage',
                  currentField: _sortField,
                  isAsc: _sortAsc,
                  onTap: _setSort,
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Strain',
                  field: 'strain',
                  currentField: _sortField,
                  isAsc: _sortAsc,
                  onTap: _setSort,
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Animals',
                  field: 'animals',
                  currentField: _sortField,
                  isAsc: _sortAsc,
                  onTap: _setSort,
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Status',
                  field: 'status',
                  currentField: _sortField,
                  isAsc: _sortAsc,
                  onTap: _setSort,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCageListTile(RackCageWithPosition cwp) {
    final cage = cwp.cage;
    final animalCount = cage.animals?.length ?? 0;
    final ownerName = getOwnerName(cage.owner);
    final rack = _rack;
    final isPositioned = cwp.position != null &&
        rack != null &&
        cwp.position!.x < (rack.rackWidth ?? 1) &&
        cwp.position!.y < (rack.rackHeight ?? 1);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isPositioned
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          isPositioned ? cwp.positionLabel : '—',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isPositioned
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
        ),
      ),
      title: Text(
        cage.cageTag ?? '(untagged)',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        [
          if (cage.strain?.strainName != null) cage.strain!.strainName!,
          '$animalCount animal${animalCount == 1 ? '' : 's'}',
          if (ownerName != '-') ownerName,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: cage.status != null && cage.status!.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(cage.status!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cage.status!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _statusColor(cage.status!),
                ),
              ),
            )
          : null,
      onTap: () => context.push('/cage/${cage.cageUuid}'),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mating':
        return Colors.pink;
      case 'stored':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// ────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(
                caption!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SnapshotCell extends StatelessWidget {
  final String positionLabel;
  final String? cageTag;
  final int animalCount;
  final bool isOccupied;
  final bool isSelected;
  final bool isValidTarget;
  final bool isArrangeMode;
  final VoidCallback onTap;
  final VoidCallback? onUnset;

  const _SnapshotCell({
    required this.positionLabel,
    required this.cageTag,
    required this.animalCount,
    required this.isOccupied,
    required this.isSelected,
    required this.isValidTarget,
    required this.isArrangeMode,
    required this.onTap,
    this.onUnset,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    double borderWidth = 1;

    if (isSelected) {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
      borderWidth = 2;
    } else if (isOccupied) {
      bgColor = Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3);
      borderColor = Theme.of(context).colorScheme.primary.withOpacity(0.3);
    } else {
      bgColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
    }

    final showTapFeedback =
        isArrangeMode ? (isOccupied || _selectedCageUuidPresent) : isOccupied;

    return GestureDetector(
      onTap: (showTapFeedback || isValidTarget) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  positionLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onUnset != null)
                  GestureDetector(
                    onTap: onUnset,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
            Text(
              cageTag ?? (isArrangeMode && isValidTarget ? 'Move here' : 'Empty'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOccupied ? Colors.black87 : Colors.grey[400],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              isOccupied
                  ? '$animalCount animal${animalCount == 1 ? '' : 's'}'
                  : (isArrangeMode && isValidTarget ? '' : 'Available'),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  bool get _selectedCageUuidPresent => isValidTarget;
}

class _SortChip extends StatelessWidget {
  final String label;
  final String field;
  final String currentField;
  final bool isAsc;
  final void Function(String) onTap;

  const _SortChip({
    required this.label,
    required this.field,
    required this.currentField,
    required this.isAsc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentField == field;
    return GestureDetector(
      onTap: () => onTap(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
