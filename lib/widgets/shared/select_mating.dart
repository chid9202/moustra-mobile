import 'package:flutter/material.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

class SelectMating extends StatefulWidget {
  final MatingDto? selectedMating;
  final Function(MatingDto?) onChanged;
  final String label;
  final String placeholderText;
  final bool disabled;

  const SelectMating({
    super.key,
    required this.selectedMating,
    required this.onChanged,
    required this.label,
    required this.placeholderText,
    this.disabled = false,
  });

  @override
  State<SelectMating> createState() => _SelectMatingState();
}

class _SelectMatingState extends State<SelectMating> {
  List<MatingDto> _matings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatings();
  }

  Future<void> _loadMatings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pageData = await matingService.getMatingsPage(pageSize: 100);
      setState(() {
        _matings = pageData.results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading matings: $e')));
      }
    }
  }

  void _showMatingPicker() {
    if (widget.disabled) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${widget.label}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _matings.length,
                  itemBuilder: (context, index) {
                    final mating = _matings[index];
                    final isSelected =
                        widget.selectedMating?.matingUuid == mating.matingUuid;

                    return ListTile(
                      title: Text(
                        mating.matingTag ?? 'Mating ${mating.matingId}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mating.setUpDate != null)
                            Text(
                              'Set up: ${mating.setUpDate!.toLocal().toString().split(' ')[0]}',
                            ),
                          Text('Animals: ${mating.animals?.length ?? 0}'),
                          if (mating.litterStrain != null)
                            Text('Strain: ${mating.litterStrain!.strainName}'),
                        ],
                      ),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      selected: isSelected,
                      onTap: () {
                        widget.onChanged(mating);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onChanged(null);
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.disabled ? null : _showMatingPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          enabled: !widget.disabled,
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: widget.selectedMating == null
            ? Text(widget.placeholderText, style: TextStyle(color: Colors.grey))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedMating!.matingTag ??
                        'Mating ${widget.selectedMating!.matingId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (widget.selectedMating!.setUpDate != null)
                    Text(
                      'Set up: ${widget.selectedMating!.setUpDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Text(
                    'Animals: ${widget.selectedMating!.animals?.length ?? 0}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (widget.selectedMating!.litterStrain != null)
                    Text(
                      'Strain: ${widget.selectedMating!.litterStrain!.strainName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
      ),
    );
  }
}
