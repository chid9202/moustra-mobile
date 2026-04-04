import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/family_tree_v2_dto.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const double _kAnimalW = 220;
const double _kAnimalH = 200;
const double _kNodeSepX = 32;
const double _kRankSepY = 80;

// ─── Graph model ─────────────────────────────────────────────────────────────

class _AnimalNode {
  final String key;
  final FamilyTreeAnimalDto animal;
  String? birthLitterTag;
  String? birthLitterUuid;
  String? birthMatingTag;
  String? birthMatingUuid;
  final List<String> parentAnimalKeys = [];
  final List<String> childAnimalKeys = [];
  _AnimalNode({required this.key, required this.animal});
}

class _LitterNode {
  final String key;
  final FamilyTreeLitterDto litter;
  final List<String> parentAnimalKeys = [];
  final List<String> childAnimalKeys = [];
  _LitterNode({required this.key, required this.litter});
}

class _Edge {
  final String source;
  final String target;
  _Edge(this.source, this.target);
}

class _Graph {
  final String rootKey;
  final Map<String, _AnimalNode> animals = {};
  final Map<String, _LitterNode> litters = {};
  final List<_Edge> edges = [];
  final Set<String> _edgeSet = {};
  _Graph(this.rootKey);

  void addEdge(String source, String target) {
    if (source.isEmpty || target.isEmpty) return;
    final id = '$source->$target';
    if (_edgeSet.contains(id)) return;
    _edgeSet.add(id);
    edges.add(_Edge(source, target));
  }
}

class _LayoutRect {
  final String key;
  double x = 0, y = 0;
  final double w = _kAnimalW, h = _kAnimalH;
  _LayoutRect(this.key);
}

// ─── Graph building ──────────────────────────────────────────────────────────

String _animalKey(FamilyTreeAnimalDto? a) => a?.animalUuid ?? '';
String _litterKey(FamilyTreeLitterDto? l) => l?.litterUuid ?? '';

void _addUnique(List<String> list, String val) {
  if (val.isNotEmpty && !list.contains(val)) list.add(val);
}

_Graph _buildGraph(FamilyTreeNodeDto root) {
  final graph = _Graph(_animalKey(root.animal));
  _walkTree(graph, root);

  // Replace litter nodes with direct parent→child edges.
  // Store litter/mating info on child animal nodes.
  for (final ln in graph.litters.values) {
    final litterKey = ln.key;

    // Remove all litter edges
    graph.edges.removeWhere(
      (e) => e.source == litterKey || e.target == litterKey,
    );
    graph._edgeSet.removeWhere((id) => id.contains(litterKey));

    // Add direct parent→child edges and store litter info on children
    for (final childKey in ln.childAnimalKeys) {
      final childNode = graph.animals[childKey];
      if (childNode != null) {
        childNode.birthLitterTag = ln.litter.litterTag;
        childNode.birthLitterUuid = ln.litter.litterUuid;
        childNode.birthMatingTag = ln.litter.mating?.matingTag;
        childNode.birthMatingUuid = ln.litter.mating?.matingUuid;
      }
      for (final parentKey in ln.parentAnimalKeys) {
        graph.addEdge(parentKey, childKey);
      }
    }
  }

  return graph;
}

String _ensureAnimal(_Graph g, FamilyTreeAnimalDto a) {
  final k = _animalKey(a);
  if (k.isEmpty) return '';
  g.animals.putIfAbsent(k, () => _AnimalNode(key: k, animal: a));
  return k;
}

String _ensureLitter(_Graph g, FamilyTreeLitterDto l) {
  final k = _litterKey(l);
  if (k.isEmpty) return '';
  g.litters.putIfAbsent(k, () => _LitterNode(key: k, litter: l));
  return k;
}

void _walkTree(_Graph g, FamilyTreeNodeDto node) {
  final aKey = _ensureAnimal(g, node.animal);
  if (aKey.isEmpty) return;

  if (node.birthLitter != null) {
    _connectBirthLitter(g, aKey, node.birthLitter!);
  }
  for (final l in node.offspringLitters) {
    _connectOffspringLitter(g, aKey, l);
  }
  for (final p in node.parents) {
    final pKey = _ensureAnimal(g, p.animal);
    if (pKey.isEmpty) continue;
    _addUnique(g.animals[aKey]!.parentAnimalKeys, pKey);
    _addUnique(g.animals[pKey]!.childAnimalKeys, aKey);
    _walkTree(g, p);
  }
  for (final c in node.children) {
    final cKey = _ensureAnimal(g, c.animal);
    if (cKey.isEmpty) continue;
    _addUnique(g.animals[aKey]!.childAnimalKeys, cKey);
    _addUnique(g.animals[cKey]!.parentAnimalKeys, aKey);
    _walkTree(g, c);
  }
}

void _connectBirthLitter(_Graph g, String aKey, FamilyTreeLitterDto litter) {
  final lKey = _ensureLitter(g, litter);
  if (lKey.isEmpty) return;
  final ln = g.litters[lKey]!;
  for (final a in litter.animals) {
    _addUnique(ln.childAnimalKeys, _ensureAnimal(g, a));
  }
  for (final a in (litter.mating?.animals ?? <FamilyTreeAnimalDto>[])) {
    _addUnique(ln.parentAnimalKeys, _ensureAnimal(g, a));
  }
}

void _connectOffspringLitter(_Graph g, String aKey, FamilyTreeLitterDto litter) {
  final lKey = _ensureLitter(g, litter);
  if (lKey.isEmpty) return;
  final ln = g.litters[lKey]!;
  final parents = (litter.mating?.animals.isNotEmpty ?? false)
      ? litter.mating!.animals
      : [g.animals[aKey]!.animal];
  for (final p in parents) {
    _addUnique(ln.parentAnimalKeys, _ensureAnimal(g, p));
  }
  for (final c in litter.animals) {
    _addUnique(ln.childAnimalKeys, _ensureAnimal(g, c));
  }
}

// ─── Layout ──────────────────────────────────────────────────────────────────

Map<String, _LayoutRect> _layoutGraph(_Graph graph) {
  final rects = <String, _LayoutRect>{};
  for (final a in graph.animals.values) {
    rects[a.key] = _LayoutRect(a.key);
  }
  if (rects.isEmpty) return rects;

  final ranks = <String, int>{};
  ranks[graph.rootKey] = 0;
  final visited = <String>{graph.rootKey};
  final queue = <String>[graph.rootKey];

  while (queue.isNotEmpty) {
    final cur = queue.removeAt(0);
    final curRank = ranks[cur]!;
    for (final e in graph.edges) {
      if (e.source == cur && !visited.contains(e.target)) {
        ranks[e.target] = curRank + 1;
        visited.add(e.target);
        queue.add(e.target);
      }
      if (e.target == cur && !visited.contains(e.source)) {
        ranks[e.source] = curRank - 1;
        visited.add(e.source);
        queue.add(e.source);
      }
    }
    final aNode = graph.animals[cur];
    if (aNode != null) {
      for (final pKey in aNode.parentAnimalKeys) {
        if (!visited.contains(pKey)) {
          ranks[pKey] = curRank - 1;
          visited.add(pKey);
          queue.add(pKey);
        }
      }
      for (final cKey in aNode.childAnimalKeys) {
        if (!visited.contains(cKey)) {
          ranks[cKey] = curRank + 1;
          visited.add(cKey);
          queue.add(cKey);
        }
      }
    }
  }

  for (final key in rects.keys) {
    ranks.putIfAbsent(key, () => 0);
  }
  final minRank = ranks.values.fold(0, math.min);
  for (final key in ranks.keys) {
    ranks[key] = ranks[key]! - minRank;
  }

  final byRank = <int, List<String>>{};
  for (final entry in ranks.entries) {
    byRank.putIfAbsent(entry.value, () => []).add(entry.key);
  }

  for (final entry in byRank.entries) {
    final rank = entry.key;
    final keys = entry.value;
    final totalW = keys.length * _kAnimalW + (keys.length - 1) * _kNodeSepX;
    double x = -totalW / 2;
    for (final k in keys) {
      final r = rects[k]!;
      r.x = x;
      r.y = rank * (_kAnimalH + _kRankSepY);
      x += _kAnimalW + _kNodeSepX;
    }
  }

  return rects;
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class FamilyTreeV2Widget extends StatefulWidget {
  final String animalUuid;
  const FamilyTreeV2Widget({super.key, required this.animalUuid});

  @override
  State<FamilyTreeV2Widget> createState() => _FamilyTreeV2WidgetState();
}

class _FamilyTreeV2WidgetState extends State<FamilyTreeV2Widget> {
  late Future<FamilyTreeNodeDto> _future;
  final TransformationController _transformCtrl = TransformationController();
  bool _didCenter = false;

  @override
  void initState() {
    super.initState();
    _future = animalService.getAnimalFamilyTreeV2(widget.animalUuid);
  }

  @override
  void didUpdateWidget(FamilyTreeV2Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animalUuid != widget.animalUuid) {
      _didCenter = false;
      _future = animalService.getAnimalFamilyTreeV2(widget.animalUuid);
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _centerOnRoot(Size viewport, _LayoutRect rootRect, double offX, double offY) {
    if (_didCenter) return;
    _didCenter = true;
    final rootCx = rootRect.x + offX + rootRect.w / 2;
    final rootCy = rootRect.y + offY + rootRect.h / 2;
    final m = Matrix4.identity();
    m.storage[12] = viewport.width / 2 - rootCx;
    m.storage[13] = viewport.height / 2 - rootCy;
    _transformCtrl.value = m;
  }

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FamilyTreeNodeDto>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load lineage: ${snapshot.error}'),
            ),
          );
        }
        final node = snapshot.data;
        if (node == null || !node.hasConnections) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No lineage found', style: TextStyle(fontSize: 16)),
            ),
          );
        }

        final graph = _buildGraph(node);
        final layout = _layoutGraph(graph);
        if (layout.isEmpty) {
          return const Center(child: Text('No lineage found'));
        }

        double minX = double.infinity, minY = double.infinity;
        double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
        for (final r in layout.values) {
          minX = math.min(minX, r.x);
          minY = math.min(minY, r.y);
          maxX = math.max(maxX, r.x + r.w);
          maxY = math.max(maxY, r.y + r.h);
        }
        const pad = 60.0;
        final canvasW = (maxX - minX) + pad * 2;
        final canvasH = (maxY - minY) + pad * 2;
        final offX = -minX + pad;
        final offY = -minY + pad;

        return LayoutBuilder(
          builder: (context, constraints) {
            final rootRect = layout[graph.rootKey];
            if (rootRect != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _centerOnRoot(
                  Size(constraints.maxWidth, constraints.maxHeight),
                  rootRect, offX, offY,
                );
              });
            }

            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(300),
                minScale: 0.2,
                maxScale: 2.5,
                child: SizedBox(
                  width: canvasW,
                  height: canvasH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(canvasW, canvasH),
                        painter: _EdgePainter(
                          edges: graph.edges,
                          layout: layout,
                          offX: offX,
                          offY: offY,
                        ),
                      ),
                      for (final entry in graph.animals.entries)
                        if (layout.containsKey(entry.key))
                          Positioned(
                            left: layout[entry.key]!.x + offX,
                            top: layout[entry.key]!.y + offY,
                            child: _AnimalCard(
                              node: entry.value,
                              isRoot: entry.key == graph.rootKey,
                              fmtDate: _fmtDate,
                              onTap: entry.key != graph.rootKey
                                  ? () => context.push('/animal/${entry.key}')
                                  : null,
                              onLitterTap: entry.value.birthLitterUuid != null
                                  ? () => context.push('/litter/${entry.value.birthLitterUuid}')
                                  : null,
                              onMatingTap: entry.value.birthMatingUuid != null
                                  ? () => context.push('/mating/${entry.value.birthMatingUuid}')
                                  : null,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Edge painter ────────────────────────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  final List<_Edge> edges;
  final Map<String, _LayoutRect> layout;
  final double offX, offY;

  _EdgePainter({required this.edges, required this.layout, required this.offX, required this.offY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93A4B8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final src = layout[edge.source];
      final tgt = layout[edge.target];
      if (src == null || tgt == null) continue;

      final x1 = src.x + offX + src.w / 2;
      final y1 = src.y + offY + src.h;
      final x2 = tgt.x + offX + tgt.w / 2;
      final y2 = tgt.y + offY;

      final path = Path()..moveTo(x1, y1);
      final midY = (y1 + y2) / 2;
      path.cubicTo(x1, midY, x2, midY, x2, y2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) => false;
}

// ─── Animal card ─────────────────────────────────────────────────────────────

class _AnimalCard extends StatelessWidget {
  final _AnimalNode node;
  final bool isRoot;
  final String Function(DateTime) fmtDate;
  final VoidCallback? onTap;
  final VoidCallback? onLitterTap;
  final VoidCallback? onMatingTap;

  const _AnimalCard({
    required this.node,
    required this.isRoot,
    required this.fmtDate,
    this.onTap,
    this.onLitterTap,
    this.onMatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animal = node.animal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kAnimalW,
        constraints: const BoxConstraints(minHeight: _kAnimalH),
        decoration: BoxDecoration(
          color: isRoot ? const Color(0xFFF0F6FF) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRoot ? theme.colorScheme.primary : theme.dividerColor,
            width: isRoot ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isRoot ? 0.12 : 0.06),
              blurRadius: isRoot ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  Icon(
                    animal.sex == 'M' ? Icons.male : Icons.female,
                    size: 16,
                    color: animal.sex == 'M' ? Colors.blue : Colors.pink,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      animal.physicalTag ?? 'Untitled animal',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isRoot ? theme.colorScheme.primary : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRoot)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (!isRoot && animal.animalUuid != null)
                    Icon(Icons.open_in_new, size: 14, color: Colors.grey.shade400),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOB: ${animal.dateOfBirth != null ? fmtDate(animal.dateOfBirth!) : '-'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Strain: ${animal.strain?.strainName ?? '-'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (node.birthLitterTag != null || node.birthMatingTag != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (node.birthLitterTag != null)
                          GestureDetector(
                            onTap: onLitterTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Litter: ${node.birthLitterTag}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                        if (node.birthMatingTag != null)
                          GestureDetector(
                            onTap: onMatingTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Mating: ${node.birthMatingTag}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
