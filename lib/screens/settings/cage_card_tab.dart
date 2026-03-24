import 'package:flutter/material.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/cage_card_template_api.dart';
import 'package:moustra/services/dtos/cage_card_template_dto.dart';
import 'package:moustra/services/clients/event_api.dart';

class CageCardTab extends StatefulWidget {
  const CageCardTab({super.key});

  @override
  State<CageCardTab> createState() => _CageCardTabState();
}

class _CageCardTabState extends State<CageCardTab> {
  List<CageCardTemplateDto> _templates = [];
  bool _isLoading = true;
  String? _settingDefaultUuid;

  @override
  void initState() {
    super.initState();
    eventApi.trackEvent('cage_card_template_view');
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await cageCardTemplateApi.getTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cage card templates: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        showAppSnackBar(context, 'Error loading templates: $e', isError: true);
      }
    }
  }

  Future<void> _setDefault(CageCardTemplateDto template) async {
    if (template.isDefault) return;

    setState(() => _settingDefaultUuid = template.cageCardTemplateUuid);

    try {
      await cageCardTemplateApi.setDefaultTemplate(
        template.cageCardTemplateUuid,
      );
      // Reload to get updated isDefault flags
      await _loadTemplates();
      if (mounted) {
        showAppSnackBar(context, '${template.name} set as default', isSuccess: true);
      }
    } catch (e) {
      debugPrint('Error setting default template: $e');
      if (mounted) {
        showAppSnackBar(context, 'Error setting default: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _settingDefaultUuid = null);
      }
    }
  }

  String _formatCodeType(CageCardCodeConfigDto? codeConfig) {
    if (codeConfig == null) return 'None';
    switch (codeConfig.type) {
      case 'qr':
        return 'QR Code';
      case 'barcode':
        return 'Barcode';
      default:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_templates.isEmpty) {
      return const Center(
        child: Text('No cage card templates found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        final isSettingDefault =
            _settingDefaultUuid == template.cageCardTemplateUuid;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: template.isDefault
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide(color: Colors.grey.shade300),
          ),
          child: InkWell(
            onTap: isSettingDefault ? null : () => _setDefault(template),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: template.isDefault ? true : null,
                    onChanged: isSettingDefault
                        ? null
                        : (_) => _setDefault(template),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (template.isDefault)
                              Chip(
                                label: const Text(
                                  'Default',
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: ${template.cardSize}  |  Code: ${_formatCodeType(template.codeConfig)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (template.enabledFields.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${template.enabledFields.length} fields enabled',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSettingDefault)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
