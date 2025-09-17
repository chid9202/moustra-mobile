import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/strain_store.dart';

class SelectStrain extends StatefulWidget {
  const SelectStrain({
    super.key,
    required this.selectedStrain,
    required this.onChanged,
    this.label,
  });
  final StrainStoreDto? selectedStrain;
  final Function(StrainStoreDto?) onChanged;
  final String? label;
  @override
  State<SelectStrain> createState() => _SelectStrainState();
}

class _SelectStrainState extends State<SelectStrain> {
  List<StrainStoreDto>? strains;

  @override
  void initState() {
    super.initState();
    _loadStrains();
  }

  void _loadStrains() async {
    if (strains == null && mounted) {
      final loadedStrains = await getStrainsHook();
      setState(() {
        strains = loadedStrains;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showStrainPicker() {
      StrainStoreDto? tempSelectedStrain = widget.selectedStrain;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Strains'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: strains?.length ?? 0,
                    itemBuilder: (context, index) {
                      final strain = strains?[index];
                      return RadioListTile<StrainStoreDto?>(
                        title: Text(strain?.strainName ?? ''),
                        value: strain,
                        // ignore: deprecated_member_use
                        groupValue: tempSelectedStrain,
                        // ignore: deprecated_member_use
                        onChanged: (StrainStoreDto? value) {
                          setDialogState(() {
                            tempSelectedStrain = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedStrain);
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
          widget.onChanged(widget.selectedStrain);
        }
      });
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: showStrainPicker,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label ?? 'Strains',
                border: OutlineInputBorder(),
              ),
              child: Text(
                widget.selectedStrain?.strainName ?? 'Select strain',
                style: TextStyle(
                  color: widget.selectedStrain != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedStrain != null) ...[
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
