import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:moustra/services/clients/attachment_api.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentList extends StatefulWidget {
  final String? animalUuid;
  final List<AttachmentDto>? initialAttachments;

  const AttachmentList({
    super.key,
    required this.animalUuid,
    this.initialAttachments,
  });

  @override
  State<AttachmentList> createState() => _AttachmentListState();
}

class _AttachmentListState extends State<AttachmentList> {
  final ValueNotifier<List<AttachmentDto>> _attachmentsNotifier =
      ValueNotifier<List<AttachmentDto>>([]);
  bool _isLoading = false;
  bool _isUploading = false;
  final Map<String, String> _imageLinks = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialAttachments != null) {
      _attachmentsNotifier.value = widget.initialAttachments!;
      _loadImageLinks(widget.initialAttachments!);
    } else {
      _loadAttachments();
    }
  }

  @override
  void dispose() {
    _attachmentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadImageLinks(List<AttachmentDto> attachments) async {
    for (final attachment in attachments) {
      if (attachment.isImage && attachment.attachmentUuid != null) {
        try {
          final link = await attachmentApi.getAttachmentLink(
            widget.animalUuid!,
            attachment.attachmentUuid!,
          );
          if (mounted) {
            setState(() {
              _imageLinks[attachment.attachmentUuid!] = link;
            });
          }
        } catch (e) {
          // Silently fail for individual image links
        }
      }
    }
  }

  Future<void> _loadAttachments() async {
    if (widget.animalUuid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final attachments = await attachmentApi.getAnimalAttachments(
        widget.animalUuid!,
      );
      _attachmentsNotifier.value = attachments;
      _loadImageLinks(attachments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attachments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadAttachment() async {
    if (widget.animalUuid == null) return;

    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);

      setState(() {
        _isUploading = true;
      });

      final attachment = await attachmentApi.uploadAnimalAttachment(
        widget.animalUuid!,
        file,
      );

      _attachmentsNotifier.value = [..._attachmentsNotifier.value, attachment];

      // Load image link if it's an image
      if (attachment.isImage && attachment.attachmentUuid != null) {
        _loadImageLinks([attachment]);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteAttachment(AttachmentDto attachment) async {
    if (widget.animalUuid == null || attachment.attachmentUuid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text(
          'Are you sure you want to delete "${attachment.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await attachmentApi.deleteAnimalAttachment(
        widget.animalUuid!,
        attachment.attachmentUuid!,
      );

      _attachmentsNotifier.value = _attachmentsNotifier.value
          .where((a) => a.attachmentUuid != attachment.attachmentUuid)
          .toList();

      // Remove from image links cache
      _imageLinks.remove(attachment.attachmentUuid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attachment deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting attachment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAttachment(AttachmentDto attachment) async {
    if (widget.animalUuid == null || attachment.attachmentUuid == null) return;

    // For images, show full-screen preview
    if (attachment.isImage) {
      final link = _imageLinks[attachment.attachmentUuid];
      if (link != null) {
        _showImagePreview(attachment, link);
        return;
      }
    }

    // For non-images, open in external app
    try {
      final link = await attachmentApi.getAttachmentLink(
        widget.animalUuid!,
        attachment.attachmentUuid!,
      );

      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open link');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening attachment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePreview(AttachmentDto attachment, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImagePreviewScreen(
          imageUrl: imageUrl,
          fileName: attachment.displayName,
          onDownload: () async {
            final uri = Uri.parse(imageUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    );
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildAttachmentThumbnail(AttachmentDto attachment) {
    if (attachment.isImage && _imageLinks.containsKey(attachment.attachmentUuid)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          _imageLinks[attachment.attachmentUuid]!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    return Icon(
      _getFileIcon(attachment.fileName),
      color: Theme.of(context).colorScheme.primary,
      size: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Attachment button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: widget.animalUuid == null || _isUploading
                  ? null
                  : _uploadAttachment,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_isUploading ? 'Uploading...' : 'Add File'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Loading indicator
        if (_isLoading && _attachmentsNotifier.value.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),

        // Attachments List
        ValueListenableBuilder<List<AttachmentDto>>(
          valueListenable: _attachmentsNotifier,
          builder: (context, attachments, child) {
            if (attachments.isEmpty && !_isLoading) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No attachments yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(child: _buildAttachmentThumbnail(attachment)),
                    ),
                    title: Text(
                      attachment.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(attachment.fileSizeFormatted),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _isLoading
                          ? null
                          : () => _deleteAttachment(attachment),
                      tooltip: 'Delete',
                      color: Colors.red,
                    ),
                    onTap: () => _openAttachment(attachment),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String fileName;
  final VoidCallback onDownload;

  const _ImagePreviewScreen({
    required this.imageUrl,
    required this.fileName,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          fileName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onDownload,
            tooltip: 'Download',
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
