import 'package:flutter/material.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/services/error_report_service.dart';
import 'package:moustra/stores/profile_store.dart';

/// Debug tab for testing error reporting and viewing context
/// Only visible in debug builds
class DebugTab extends StatelessWidget {
  const DebugTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error Testing Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Reporting Test',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trigger test errors to verify error reporting includes proper context.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _triggerCaughtError(context),
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Caught Exception'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _triggerNullError(context),
                        icon: const Icon(Icons.dangerous),
                        label: const Text('Null Error'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _triggerAsyncError(context),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Async Error'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Current Context Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Error Context',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () => _copyContext(context),
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy context',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      errorContextService.buildFullContext(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breadcrumbs Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation Breadcrumbs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (errorContextService.breadcrumbs.isEmpty)
                    const Text(
                      'No navigation history yet',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: errorContextService.breadcrumbs.length,
                      itemBuilder: (context, index) {
                        final crumb = errorContextService.breadcrumbs[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(crumb.screenName ?? crumb.route),
                          subtitle: Text(
                            crumb.route,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                          trailing: Text(
                            _formatTime(crumb.timestamp),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Profile Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile State',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: profileState,
                    builder: (context, profile, _) {
                      if (profile == null) {
                        return const Text(
                          'Not logged in',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Account UUID', profile.accountUuid),
                          _infoRow('Email', profile.email),
                          _infoRow('Name', '${profile.firstName} ${profile.lastName}'),
                          _infoRow('Lab', profile.labName),
                          _infoRow('Role', profile.role),
                          if (profile.position != null)
                            _infoRow('Position', profile.position!),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  void _triggerCaughtError(BuildContext context) {
    try {
      throw Exception('Test error: This is a deliberate test exception');
    } catch (e, stackTrace) {
      reportError(
        error: e,
        stackTrace: stackTrace,
        context: 'Triggered from Debug tab',
      );
      _showSnackBar(context, 'Caught exception reported!');
    }
  }

  void _triggerNullError(BuildContext context) {
    try {
      String? nullValue;
      // This will throw a null check error
      final _ = nullValue!.length;
    } catch (e, stackTrace) {
      reportError(
        error: e,
        stackTrace: stackTrace,
        context: 'Null check test from Debug tab',
      );
      _showSnackBar(context, 'Null error reported!');
    }
  }

  void _triggerAsyncError(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        throw StateError('Test async error: Simulated async failure');
      } catch (e, stackTrace) {
        reportError(
          error: e,
          stackTrace: stackTrace,
          context: 'Async error test from Debug tab',
        );
      }
    });
    _showSnackBar(context, 'Async error will be reported in 100ms');
  }

  void _copyContext(BuildContext context) {
    // In a real app, you'd use Clipboard.setData here
    final contextText = errorContextService.buildFullContext();
    debugPrint('=== Error Context ===\n$contextText\n===================');
    _showSnackBar(context, 'Context printed to debug console');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
