import 'package:flutter/material.dart';
import 'package:moustra/helpers/note_helper.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/widgets/note/mention_input.dart';
import 'package:moustra/widgets/note/mention_text.dart';

class SingleNote extends StatefulWidget {
  final NoteDto note;
  final bool isEditing;
  final String editingContent;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onEditingContentChange;
  final bool isLast;

  const SingleNote({
    super.key,
    required this.note,
    required this.isEditing,
    required this.editingContent,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
    required this.onDelete,
    required this.onEditingContentChange,
    this.isLast = false,
  });

  @override
  State<SingleNote> createState() => _SingleNoteState();
}

class _SingleNoteState extends State<SingleNote> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.editingContent);
  }

  @override
  void didUpdateWidget(SingleNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing != oldWidget.isEditing) {
      if (widget.isEditing) {
        _editController.text = widget.editingContent;
        // Focus the text field when entering edit mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _editController.selection = TextSelection.collapsed(
            offset: _editController.text.length,
          );
        });
      }
    } else if (widget.editingContent != oldWidget.editingContent) {
      _editController.text = widget.editingContent;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creatorName = NoteHelper.getCreatorName(widget.note.createdBy);
    final initials = NoteHelper.getInitials(widget.note.createdBy);
    final avatarColor = NoteHelper.stringToColor(creatorName);
    final formattedDate = NoteHelper.formatNoteDate(widget.note.createdDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 20,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: widget.isEditing
                      ? MentionInput(
                          value: widget.editingContent,
                          onChanged: widget.onEditingContentChange,
                          maxLines: 3,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(8),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MentionText(
                              content: widget.note.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  formattedDate,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Text(' • '),
                                Text(
                                  creatorName,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: widget.onStartEdit,
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: widget.onDelete,
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancelEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onSaveEdit,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
