import 'package:flutter/material.dart';
import 'package:moustra/helpers/note_helper.dart';
import 'package:moustra/services/clients/note_api.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/widgets/note/single_note.dart';

class NoteList extends StatefulWidget {
  final String? entityUuid;
  final NoteEntityType entityType;
  final List<NoteDto>? initialNotes;
  final Function(NoteDto)? onNoteAdded;
  final Function(NoteDto)? onNoteUpdated;
  final Function(String)? onNoteDeleted;

  const NoteList({
    super.key,
    required this.entityUuid,
    required this.entityType,
    this.initialNotes,
    this.onNoteAdded,
    this.onNoteUpdated,
    this.onNoteDeleted,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final ValueNotifier<List<NoteDto>> _notesNotifier =
      ValueNotifier<List<NoteDto>>([]);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _addNoteController = TextEditingController();
  bool _showAddForm = false;
  bool _isLoading = false;
  String? _editingNoteUuid;
  String _editingContent = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialNotes != null) {
      _notesNotifier.value = _sortNotesByDate(widget.initialNotes!);
    }
    // Listen to text changes to update button state
    _addNoteController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notesNotifier.dispose();
    _scrollController.dispose();
    _addNoteController.dispose();
    super.dispose();
  }

  List<NoteDto> _sortNotesByDate(List<NoteDto> notes) {
    final sorted = List<NoteDto>.from(notes);
    sorted.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sorted;
  }

  Future<void> _addNote() async {
    if (widget.entityUuid == null || _addNoteController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = await noteApi.createNote(
        widget.entityUuid!,
        widget.entityType,
        _addNoteController.text.trim(),
      );

      final updatedNotes = [note, ..._notesNotifier.value];
      _notesNotifier.value = _sortNotesByDate(updatedNotes);

      _addNoteController.clear();
      setState(() {
        _showAddForm = false;
      });

      // Auto-scroll to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      if (widget.onNoteAdded != null) {
        widget.onNoteAdded!(note);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = NoteHelper.extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding note: $errorMessage'),
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

  void _startEdit(NoteDto note) {
    setState(() {
      _editingNoteUuid = note.noteUuid;
      _editingContent = note.content;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteUuid = null;
      _editingContent = '';
    });
  }

  Future<void> _saveEdit() async {
    if (widget.entityUuid == null ||
        _editingNoteUuid == null ||
        _editingContent.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedNote = await noteApi.updateNote(
        widget.entityUuid!,
        widget.entityType,
        _editingNoteUuid!,
        _editingContent.trim(),
      );

      final updatedNotes = _notesNotifier.value.map((note) {
        return note.noteUuid == _editingNoteUuid ? updatedNote : note;
      }).toList();

      _notesNotifier.value = _sortNotesByDate(updatedNotes);

      setState(() {
        _editingNoteUuid = null;
        _editingContent = '';
      });

      if (widget.onNoteUpdated != null) {
        widget.onNoteUpdated!(updatedNote);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = NoteHelper.extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating note: $errorMessage'),
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

  Future<void> _deleteNote(String noteUuid) async {
    if (widget.entityUuid == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await noteApi.deleteNote(
        widget.entityUuid!,
        widget.entityType,
        noteUuid,
      );

      final updatedNotes =
          _notesNotifier.value.where((n) => n.noteUuid != noteUuid).toList();
      _notesNotifier.value = updatedNotes;

      if (widget.onNoteDeleted != null) {
        widget.onNoteDeleted!(noteUuid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = NoteHelper.extractErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: $errorMessage'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Note button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: widget.entityUuid == null
                  ? null
                  : () {
                      setState(() {
                        _showAddForm = !_showAddForm;
                      });
                    },
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Add Note Form
        if (_showAddForm) ...[
          TextField(
            controller: _addNoteController,
            decoration: const InputDecoration(
              hintText: 'Enter note content...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _showAddForm = false;
                          _addNoteController.clear();
                        });
                      },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ||
                        widget.entityUuid == null ||
                        _addNoteController.text.trim().isEmpty
                    ? null
                    : _addNote,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Note'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Notes List
        ValueListenableBuilder<List<NoteDto>>(
          valueListenable: _notesNotifier,
          builder: (context, notes, child) {
            if (notes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No notes yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isEditing = _editingNoteUuid == note.noteUuid;
                  return SingleNote(
                    note: note,
                    isEditing: isEditing,
                    editingContent: _editingContent,
                    onStartEdit: () => _startEdit(note),
                    onCancelEdit: _cancelEdit,
                    onSaveEdit: _saveEdit,
                    onDelete: () => _deleteNote(note.noteUuid),
                    onEditingContentChange: (value) {
                      setState(() {
                        _editingContent = value;
                      });
                    },
                    isLast: index == notes.length - 1,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

