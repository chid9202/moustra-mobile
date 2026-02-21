import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/protocol_api.dart';
import 'package:moustra/services/dtos/animal_protocol_dto.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';

class ProtocolDetailScreen extends StatefulWidget {
  const ProtocolDetailScreen({super.key});

  @override
  State<ProtocolDetailScreen> createState() => _ProtocolDetailScreenState();
}

class _ProtocolDetailScreenState extends State<ProtocolDetailScreen> {
  ProtocolDto? _protocol;
  List<AnimalProtocolDto> _animals = [];
  bool _isLoading = true;
  bool _detailsExpanded = true;
  String? _error;

  String? get _protocolUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['protocolUuid'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        protocolApi.getProtocol(uuid),
        protocolApi.getProtocolAnimals(uuid),
      ]);
      if (mounted) {
        setState(() {
          _protocol = results[0] as ProtocolDto;
          _animals = results[1] as List<AnimalProtocolDto>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'expiring':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      case 'suspended':
        return Colors.red.shade800;
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'closed':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/protocol'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Protocol Detail'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading protocol',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final protocol = _protocol!;
    final statusColor = _statusColor(protocol.status);
    final piName = protocol.pi != null
        ? '${protocol.pi!.user.firstName} ${protocol.pi!.user.lastName}'
        : 'Unknown PI';
    final pct = protocol.animalCountPct ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/protocol'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(protocol.protocolNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.go('/protocol/${protocol.protocolUuid}/edit'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Status Header Banner
                    _buildStatusBanner(protocol, statusColor),
                    // 2. Key Metrics Row
                    _buildKeyMetrics(protocol, pct),
                    // 3. Details Section (collapsible)
                    _buildDetailsSection(protocol, piName),
                    // 4. Animals Section
                    _buildAnimalsSection(),
                  ],
                ),
              ),
            ),
          ),
          // 5. Sticky bottom bar
          _buildBottomActionBar(protocol),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ProtocolDto protocol, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (protocol.status ?? 'unknown').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (protocol.alertStatus != null &&
                  protocol.alertStatus != 'ok') ...[
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  protocol.alertStatus!,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            protocol.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(ProtocolDto protocol, double pct) {
    final daysLeft = protocol.daysUntilExpiry;
    final animalCountColor = pct >= 95
        ? Colors.red
        : pct >= 80
            ? Colors.orange
            : pct >= 60
                ? Colors.yellow.shade700
                : Colors.green;
    final daysColor = daysLeft != null && daysLeft <= 30
        ? Colors.red
        : daysLeft != null && daysLeft <= 90
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Animal Count Gauge
          Expanded(
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: (pct / 100).clamp(0.0, 1.0),
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                animalCountColor,
                              ),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: animalCountColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${protocol.currentAnimalCount}/${protocol.maxAnimalCount}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Animals',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Days Until Expiry
          Expanded(
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Text(
                          daysLeft != null ? '$daysLeft' : '—',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: daysColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      protocol.expirationDate,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Days Until Expiry',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ProtocolDto protocol, String piName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        child: ExpansionTile(
          initiallyExpanded: _detailsExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _detailsExpanded = expanded);
          },
          title: const Text(
            'Details',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _detailRow('PI', piName),
                  _detailRow('Species', protocol.species ?? '—'),
                  _detailRow(
                    'Pain Category',
                    protocol.painCategory,
                  ),
                  _detailRow(
                    'Approval Date',
                    protocol.approvalDate ?? '—',
                  ),
                  _detailRow(
                    'Effective Date',
                    protocol.effectiveDate ?? '—',
                  ),
                  _detailRow('Expiration Date', protocol.expirationDate),
                  _detailRow(
                    'Funding',
                    protocol.fundingSource ?? '—',
                  ),
                  if (protocol.description != null &&
                      protocol.description!.isNotEmpty)
                    _detailRow('Description', protocol.description!),
                  if (protocol.alertThresholdPct != null)
                    _detailRow(
                      'Alert Threshold',
                      '${protocol.alertThresholdPct}%',
                    ),
                  if (protocol.alertDays != null &&
                      protocol.alertDays!.isNotEmpty)
                    _detailRow(
                      'Alert Days',
                      protocol.alertDays!.join(', '),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalsSection() {
    final previewAnimals = _animals.take(5).toList();
    final hasMore = _animals.length > 5;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Animals',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_animals.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (previewAnimals.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'No animals assigned to this protocol',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else ...[
              ...previewAnimals.map((ap) => _buildAnimalTile(ap)),
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to full animal list for this protocol
                    },
                    child: Text(
                      'View All ${_animals.length} Animals →',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalTile(AnimalProtocolDto ap) {
    final animal = ap.animal;
    final tag = animal?.physicalTag ?? 'Unknown';
    final sex = animal?.sex ?? '?';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: sex == 'M'
            ? Colors.blue.withValues(alpha: 0.1)
            : sex == 'F'
                ? Colors.pink.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        child: Text(
          sex,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: sex == 'M'
                ? Colors.blue
                : sex == 'F'
                    ? Colors.pink
                    : Colors.grey,
          ),
        ),
      ),
      title: Text(tag, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        'Role: ${ap.role ?? 'primary'} • Assigned: ${ap.assignedDate}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        if (animal != null) {
          context.go('/animal/${animal.animalUuid}');
        }
      },
    );
  }

  Widget _buildBottomActionBar(ProtocolDto protocol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Add animals flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Animals coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Animals'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Census view
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Census coming soon')),
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text('Census'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.go('/protocol/${protocol.protocolUuid}/edit'),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Amend'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
