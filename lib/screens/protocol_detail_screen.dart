import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/protocol_api.dart';
import 'package:moustra/services/dtos/animal_protocol_dto.dart';
import 'package:moustra/services/dtos/protocol_amendment_dto.dart';
import 'package:moustra/services/dtos/protocol_document_dto.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

class ProtocolDetailScreen extends StatefulWidget {
  const ProtocolDetailScreen({super.key});

  @override
  State<ProtocolDetailScreen> createState() => _ProtocolDetailScreenState();
}

class _ProtocolDetailScreenState extends State<ProtocolDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  ProtocolDto? _protocol;
  List<AnimalProtocolDto> _animals = [];
  List<ProtocolAmendmentDto> _amendments = [];
  List<ProtocolDocumentDto> _documents = [];
  bool _isLoading = true;
  bool _detailsExpanded = true;
  String? _error;

  String? get _protocolUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['protocolUuid'];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final protocol = await protocolApi.getProtocol(uuid);
      List<AnimalProtocolDto> animals = [];
      List<ProtocolAmendmentDto> amendments = [];
      try {
        animals = await protocolApi.getProtocolAnimals(uuid);
      } catch (e) {
        debugPrint('Error loading protocol animals: $e');
      }
      try {
        amendments = await protocolApi.getProtocolAmendments(uuid);
      } catch (e) {
        debugPrint('Error loading protocol amendments: $e');
      }
      List<ProtocolDocumentDto> documents = [];
      try {
        documents = await protocolApi.getDocuments(uuid);
      } catch (e) {
        debugPrint('Error loading protocol documents: $e');
      }
      if (mounted) {
        setState(() {
          _protocol = protocol;
          _animals = animals;
          _amendments = amendments;
          _documents = documents;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading protocol: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeAnimal(AnimalProtocolDto ap) async {
    final animalUuid = ap.resolvedAnimalUuid;
    if (animalUuid == null) return;
    final uuid = _protocolUuid;
    if (uuid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Animal'),
        content: Text(
          'Remove ${ap.resolvedPhysicalTag ?? 'this animal'} from protocol?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await protocolApi.removeAnimal(uuid, animalUuid);
      if (mounted) {
        showAppSnackBar(context, 'Animal removed from protocol');
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error removing animal: $e', isError: true);
      }
    }
  }

  Future<void> _showAddAnimalsDialog() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AssignAnimalDialog(protocolUuid: uuid),
    );

    if (result == true && mounted) {
      _loadData();
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
    _tabController ??= TabController(length: 3, vsync: this);

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
    final piName = protocol.pi?.user != null
        ? '${protocol.pi!.user!.firstName} ${protocol.pi!.user!.lastName}'
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
        bottom: TabBar(
          controller: _tabController!,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Animals'),
            Tab(text: 'Amendments'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          // Tab 1: Overview
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(protocol, statusColor),
                  _buildKeyMetrics(protocol, pct),
                  _buildDetailsSection(protocol, piName),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Tab 2: Animals
          _buildAnimalsTab(),
          // Tab 3: Amendments
          _buildAmendmentsTab(),
          // Tab 4: Documents
          _buildDocumentsTab(),
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
                      protocol.expirationDate ?? '—',
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
                    protocol.painCategory ?? '—',
                  ),
                  _detailRow(
                    'Approval Date',
                    protocol.approvalDate ?? '—',
                  ),
                  _detailRow(
                    'Effective Date',
                    protocol.effectiveDate ?? '—',
                  ),
                  _detailRow('Expiration Date', protocol.expirationDate ?? '—'),
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

  // ── Animals Tab ──

  Widget _buildAnimalsTab() {
    return Column(
      children: [
        // Header with Add button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Animals on Protocol',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
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
              const Spacer(),
              FilledButton.icon(
                onPressed: _showAddAnimalsDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Animals'),
              ),
            ],
          ),
        ),
        // Animal list
        Expanded(
          child: _animals.isEmpty
              ? const Center(
                  child: Text(
                    'No animals assigned to this protocol',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _animals.length,
                    itemBuilder: (context, index) {
                      final ap = _animals[index];
                      return _buildAnimalTile(ap);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAnimalTile(AnimalProtocolDto ap) {
    final tag = ap.resolvedPhysicalTag ?? 'Unknown';
    final sex = ap.animal?.sex ?? '?';
    final animalUuid = ap.resolvedAnimalUuid;

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
            onPressed: () => _removeAnimal(ap),
            tooltip: 'Remove',
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
      onTap: animalUuid != null
          ? () => context.push('/animal/$animalUuid?fromProtocol=$_protocolUuid')
          : null,
    );
  }

  // ── Amendments Tab ──

  Widget _buildAmendmentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Amendments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_amendments.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _showAddAmendmentDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Amendment'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _amendments.isEmpty
              ? const Center(
                  child: Text(
                    'No amendments recorded',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _amendments.length,
                    itemBuilder: (context, index) {
                      final a = _amendments[index];
                      return _buildAmendmentTile(a);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showAddAmendmentDialog() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AmendmentFormDialog(protocolUuid: uuid),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Widget _buildAmendmentTile(ProtocolAmendmentDto a) {
    final statusColor = _amendmentStatusColor(a.status);
    final isRecorded = a.status?.toLowerCase() == 'recorded';
    return ListTile(
      dense: true,
      title: Text(
        '#${a.amendmentNumber ?? '?'} - ${a.amendmentType ?? 'Unknown'}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.description != null && a.description!.isNotEmpty)
            Text(
              a.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          if (a.approvedDate != null)
            Text(
              'Approved: ${a.approvedDate}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (a.status ?? 'unknown').toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isRecorded && a.amendmentUuid != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 20),
              tooltip: 'Apply',
              onPressed: () => _applyAmendment(a),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyAmendment(ProtocolAmendmentDto a) async {
    final uuid = _protocolUuid;
    if (uuid == null || a.amendmentUuid == null) return;

    try {
      await protocolApi.applyAmendment(uuid, a.amendmentUuid!);
      if (mounted) {
        showAppSnackBar(context, 'Amendment applied', isSuccess: true);
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error applying amendment: $e', isError: true);
      }
    }
  }

  // ── Documents Tab ──

  Widget _buildDocumentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Documents',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_documents.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _showUploadDocumentDialog,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _documents.isEmpty
              ? const Center(
                  child: Text(
                    'No documents uploaded yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return _buildDocumentTile(doc);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentTile(ProtocolDocumentDto doc) {
    final typeColor = _documentTypeColor(doc.documentType);
    final typeLabel = _documentTypeLabel(doc.documentType);
    return ListTile(
      dense: true,
      leading: Icon(Icons.description, color: typeColor, size: 28),
      title: Text(
        doc.filename ?? 'Unknown file',
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (doc.description != null &&
                  doc.description!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doc.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
          Text(
            '${doc.uploadedBy ?? 'Unknown'} • ${doc.uploadedAt ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (doc.fileLink != null)
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              tooltip: 'Download',
              onPressed: () => _openDocument(doc),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade300),
            tooltip: 'Delete',
            onPressed: () => _deleteDocument(doc),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(ProtocolDocumentDto doc) async {
    if (doc.fileLink == null) return;
    try {
      await launchUrl(Uri.parse(doc.fileLink!), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Cannot open document: $e', isError: true);
      }
    }
  }

  Future<void> _deleteDocument(ProtocolDocumentDto doc) async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Delete "${doc.filename ?? 'this document'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await protocolApi.deleteDocument(uuid, doc.documentUuid);
      if (mounted) {
        showAppSnackBar(context, 'Document deleted');
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error deleting document: $e', isError: true);
      }
    }
  }

  Future<void> _showUploadDocumentDialog() async {
    final uuid = _protocolUuid;
    if (uuid == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _UploadDocumentDialog(protocolUuid: uuid),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Color _documentTypeColor(String? type) {
    switch (type) {
      case 'approval_letter':
        return Colors.green;
      case 'amendment':
        return Colors.blue;
      case 'annual_review':
        return Colors.orange;
      case 'correspondence':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  String _documentTypeLabel(String? type) {
    if (type == null) return 'Other';
    return type
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Color _amendmentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'applied':
        return Colors.green;
      case 'pending':
      case 'recorded':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ── Assign Animal Dialog ──

class _AssignAnimalDialog extends StatefulWidget {
  final String protocolUuid;

  const _AssignAnimalDialog({required this.protocolUuid});

  @override
  State<_AssignAnimalDialog> createState() => _AssignAnimalDialogState();
}

class _AssignAnimalDialogState extends State<_AssignAnimalDialog> {
  final _searchController = TextEditingController();
  List<AnimalStoreDto> _allAnimals = [];
  List<AnimalStoreDto> _filteredAnimals = [];
  final List<AnimalStoreDto> _selectedAnimals = [];
  String _role = 'primary';
  bool _isLoading = true;
  bool _isSubmitting = false;

  static const _roles = ['primary', 'secondary', 'breeding', 'experimental'];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    final animals = await getAnimalsHook();
    if (mounted) {
      setState(() {
        _allAnimals = animals;
        _filteredAnimals = animals;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAnimals = _allAnimals;
      } else {
        _filteredAnimals = _allAnimals
            .where((a) =>
                (a.physicalTag?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  void _toggleSelection(AnimalStoreDto animal) {
    setState(() {
      final idx = _selectedAnimals
          .indexWhere((a) => a.animalUuid == animal.animalUuid);
      if (idx >= 0) {
        _selectedAnimals.removeAt(idx);
      } else {
        _selectedAnimals.add(animal);
      }
    });
  }

  bool _isSelected(AnimalStoreDto animal) {
    return _selectedAnimals.any((a) => a.animalUuid == animal.animalUuid);
  }

  Future<void> _submit() async {
    if (_selectedAnimals.isEmpty) {
      showAppSnackBar(context, 'Select at least one animal');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final uuids = _selectedAnimals.map((a) => a.animalUuid).toList();
      if (uuids.length == 1) {
        await protocolApi.assignAnimal(widget.protocolUuid, {
          'animalUuid': uuids[0],
          'role': _role,
          'assignedDate': DateTime.now().toIso8601String().split('T')[0],
        });
      } else {
        await protocolApi.bulkAssignAnimals(widget.protocolUuid, {
          'animalIds': uuids,
          'role': _role,
        });
      }
      if (mounted) {
        showAppSnackBar(context, '${uuids.length} animal(s) assigned to protocol', isSuccess: true);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        showAppSnackBar(context, 'Failed to assign animals: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Assign Animals to Protocol',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Role selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r[0].toUpperCase() + r.substring(1),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _role = v);
                },
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Filter by physical tag',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
            // Selected chips
            if (_selectedAnimals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected (${_selectedAnimals.length}):',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _selectedAnimals
                          .map((a) => Chip(
                                label: Text(
                                  a.physicalTag ?? a.animalUuid,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () => _toggleSelection(a),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            // Results list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAnimals.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No animals available'
                                : 'No matching animals',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredAnimals.length,
                          itemBuilder: (context, index) {
                            final animal = _filteredAnimals[index];
                            final selected = _isSelected(animal);
                            final sex = animal.sex ?? '?';
                            return ListTile(
                              dense: true,
                              selected: selected,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08),
                              leading: Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleSelection(animal),
                              ),
                              title: Text(
                                animal.physicalTag ?? '—',
                                style:
                                    const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '$sex${animal.dateOfBirth != null ? ' • ${animal.dateOfBirth!.month}/${animal.dateOfBirth!.day}/${animal.dateOfBirth!.year}' : ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () => _toggleSelection(animal),
                            );
                          },
                        ),
            ),
            const Divider(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Assign'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Amendment Form Dialog ──

class _AmendmentFormDialog extends StatefulWidget {
  final String protocolUuid;

  const _AmendmentFormDialog({required this.protocolUuid});

  @override
  State<_AmendmentFormDialog> createState() => _AmendmentFormDialogState();
}

class _AmendmentFormDialogState extends State<_AmendmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prevValuesController = TextEditingController();
  final _newValuesController = TextEditingController();
  String _type = 'modification';
  DateTime? _approvedDate;
  DateTime? _effectiveDate;
  bool _isSubmitting = false;

  static const _types = [
    'modification',
    'renewal',
    'personnel_change',
    'animal_count_change',
    'species_addition',
    'other',
  ];

  @override
  void dispose() {
    _numberController.dispose();
    _descriptionController.dispose();
    _prevValuesController.dispose();
    _newValuesController.dispose();
    super.dispose();
  }

  String _typeLabel(String type) {
    return type
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Future<void> _pickDate(bool isApproved) async {
    final initial = isApproved ? _approvedDate : _effectiveDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        if (isApproved) {
          _approvedDate = picked;
        } else {
          _effectiveDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic>? _tryParseJson(String text) {
    if (text.trim().isEmpty) return null;
    try {
      final parsed = Map<String, dynamic>.from(
        (text.trim().startsWith('{'))
            ? (throw FormatException()) // let it fall through
            : {},
      );
      return parsed;
    } catch (_) {}
    // Try actual JSON parse
    try {
      final decoded = Map<String, dynamic>.from(
        (() {
          final d = text.trim();
          if (d.startsWith('{')) {
            return Map<String, dynamic>.from(
              jsonDecode(d) as Map,
            );
          }
          return <String, dynamic>{'raw': d};
        })(),
      );
      return decoded;
    } catch (_) {
      return {'raw': text.trim()};
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'amendmentNumber': _numberController.text.trim(),
      'amendmentType': _type,
      'description': _descriptionController.text.trim(),
      'status': 'recorded',
    };

    if (_approvedDate != null) {
      data['approvedDate'] = _formatDate(_approvedDate!);
    }
    if (_effectiveDate != null) {
      data['effectiveDate'] = _formatDate(_effectiveDate!);
    }

    final prev = _tryParseJson(_prevValuesController.text);
    if (prev != null) data['previousValues'] = prev;

    final next = _tryParseJson(_newValuesController.text);
    if (next != null) data['newValues'] = next;

    try {
      await protocolApi.createAmendment(widget.protocolUuid, data);
      if (mounted) {
        showAppSnackBar(context, 'Amendment recorded successfully', isSuccess: true);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        showAppSnackBar(context, 'Failed to record amendment: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    'New Amendment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Amendment Number *',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'e.g. AMD-001',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _types
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_typeLabel(t)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _type = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        minLines: 3,
                        maxLines: 5,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      // Date pickers row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Approved Date',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                                ),
                                child: Text(
                                  _approvedDate != null
                                      ? _formatDate(_approvedDate!)
                                      : '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Effective Date',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                                ),
                                child: Text(
                                  _effectiveDate != null
                                      ? _formatDate(_effectiveDate!)
                                      : '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prevValuesController,
                        decoration: const InputDecoration(
                          labelText: 'Previous Values',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'JSON or plain text',
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newValuesController,
                        decoration: const InputDecoration(
                          labelText: 'New Values',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'JSON or plain text',
                        ),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Record Amendment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upload Document Dialog ──

class _UploadDocumentDialog extends StatefulWidget {
  final String protocolUuid;

  const _UploadDocumentDialog({required this.protocolUuid});

  @override
  State<_UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<_UploadDocumentDialog> {
  final _descriptionController = TextEditingController();
  String _documentType = 'approval_letter';
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;

  static const _types = [
    {'value': 'approval_letter', 'label': 'Approval Letter'},
    {'value': 'amendment', 'label': 'Amendment'},
    {'value': 'annual_review', 'label': 'Annual Review'},
    {'value': 'correspondence', 'label': 'Correspondence'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _selectedFileSize = result.files.single.size;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      showAppSnackBar(context, 'Please select a file');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await protocolApi.uploadDocument(
        widget.protocolUuid,
        file: _selectedFile!,
        documentType: _documentType,
        description: _descriptionController.text,
      );
      if (mounted) {
        showAppSnackBar(context, 'Document uploaded successfully', isSuccess: true);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        showAppSnackBar(context, 'Failed to upload document: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Upload Document',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _documentType,
                    decoration: const InputDecoration(
                      labelText: 'Document Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _types
                        .map((t) => DropdownMenuItem(
                              value: t['value'],
                              child: Text(t['label']!),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _documentType = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // File picker
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _selectedFile == null ? 'Choose File' : 'Change File',
                    ),
                  ),
                  if (_selectedFileName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFileName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_selectedFileSize != null)
                                  Text(
                                    '${(_selectedFileSize! / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => setState(() {
                              _selectedFile = null;
                              _selectedFileName = null;
                              _selectedFileSize = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            ),
            const Divider(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed:
                        _isUploading || _selectedFile == null ? null : _upload,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload, size: 18),
                    label: const Text('Upload'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
