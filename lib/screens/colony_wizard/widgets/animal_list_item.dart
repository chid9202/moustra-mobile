import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import '../steps/cage_animal_dialog_screen.dart';
import 'strain_picker.dart';

/// List item for displaying an animal with expand/collapse detail form
class AnimalListItem extends StatefulWidget {
  final TempAnimalData animal;
  final List<StrainStoreDto> strains;
  final Function(TempAnimalData) onUpdate;
  final VoidCallback onDelete;

  const AnimalListItem({
    super.key,
    required this.animal,
    required this.strains,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<AnimalListItem> createState() => _AnimalListItemState();
}

class _AnimalListItemState extends State<AnimalListItem> {
  bool _isExpanded = false;
  late TextEditingController _tagController;
  late TextEditingController _commentController;
  late DateTime _dateOfBirth;
  StrainStoreDto? _strain;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.animal.physicalTag);
    _commentController = TextEditingController(text: widget.animal.comment);
    _dateOfBirth = widget.animal.dateOfBirth;
    _strain = widget.animal.strain;
  }

  @override
  void dispose() {
    _tagController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updated = TempAnimalData(
      id: widget.animal.id,
      animalUuid: widget.animal.animalUuid,
      physicalTag: _tagController.text.trim(),
      sex: widget.animal.sex,
      dateOfBirth: _dateOfBirth,
      strain: _strain,
      comment: _commentController.text.trim(),
      genotypes: widget.animal.genotypes,
      isLitterPup: widget.animal.isLitterPup,
    );
    widget.onUpdate(updated);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() => _dateOfBirth = picked);
      _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sexColor = _getSexColor(widget.animal.sex);
    final sexIcon = _getSexIcon(widget.animal.sex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Collapsed row
          ListTile(
            leading: Icon(sexIcon, color: sexColor),
            title: Text(
              widget.animal.physicalTag,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${widget.animal.strain?.strainName ?? "No strain"} | ${_formatDate(_dateOfBirth)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),

          // Expanded detail form
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),

                  // Physical tag
                  TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Physical Tag',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _saveChanges(),
                  ),
                  const SizedBox(height: 12),

                  // Strain picker
                  StrainPicker(
                    label: 'Strain',
                    value: _strain,
                    strains: widget.strains,
                    onChanged: (strain) {
                      setState(() => _strain = strain);
                      _saveChanges();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date of birth
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_dateOfBirth)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comment
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    onChanged: (_) => _saveChanges(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getSexIcon(String sex) {
    switch (sex) {
      case 'M':
        return Icons.male;
      case 'F':
        return Icons.female;
      default:
        return Icons.question_mark;
    }
  }

  Color _getSexColor(String sex) {
    switch (sex) {
      case 'M':
        return Colors.blue;
      case 'F':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
