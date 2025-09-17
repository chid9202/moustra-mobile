import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/stores/cage_store.dart';

class SelectCage extends StatefulWidget {
  const SelectCage({
    super.key,
    required this.selectedCage,
    required this.onChanged,
  });
  final CageStoreDto? selectedCage;
  final Function(CageStoreDto?) onChanged;

  @override
  State<SelectCage> createState() => _SelectCageState();
}

class _SelectCageState extends State<SelectCage> {
  List<CageStoreDto>? cages;

  _getCageOptionLabel(CageStoreDto cage) {
    return cage.cageTag ?? 'N/A';
  }

  @override
  void initState() {
    super.initState();
    _loadCages();
  }

  void _loadCages() async {
    if (cages == null && mounted) {
      final loadedCages = await getCagesHook();
      if (mounted) {
        setState(() {
          cages = loadedCages;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void showCagePicker() {
      CageStoreDto? tempSelectedCage = widget.selectedCage;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Cages'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final cage = cages?[index];
                      return RadioListTile<CageStoreDto?>(
                        title: Text(_getCageOptionLabel(cage!)),
                        value: cage,
                        // ignore: deprecated_member_use
                        groupValue: tempSelectedCage,
                        // ignore: deprecated_member_use
                        onChanged: (CageStoreDto? value) {
                          setDialogState(() {
                            tempSelectedCage = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedCage);
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      ).then((saved) {
        if (saved != true) {
          // Dialog was closed without saving, reset to original values
          widget.onChanged(widget.selectedCage);
        }
      });
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: showCagePicker,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Cages',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.selectedCage?.cageTag ?? 'Select cage',
                style: TextStyle(
                  color: widget.selectedCage != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedCage != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              widget.onChanged(null);
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            tooltip: 'Clear selection',
          ),
        ],
      ],
    );
  }
}
