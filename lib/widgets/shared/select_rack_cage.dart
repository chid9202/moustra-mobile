import 'package:flutter/material.dart';

import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';

class SelectRackCage extends StatefulWidget {
  const SelectRackCage({
    super.key,
    required this.selectedCage,
    required this.onSubmit,
    this.label,
    this.disabled = false,
  });
  final RackCageDto? selectedCage;
  final Function(RackCageDto?) onSubmit;
  final String? label;
  final bool disabled;
  @override
  State<SelectRackCage> createState() => _SelectRackCageState();
}

class _SelectRackCageState extends State<SelectRackCage> {
  List<RackCageDto>? cages;
  List<RackCageDto>? filteredCages;
  RackCageDto? selection;
  final textController = TextEditingController();

  _getCageOptionLabel(RackCageDto cage) {
    return '${cage.cageTag} ${cage.strain?.strainName != null ? '(${cage.strain?.strainName})' : ''}';
  }

  @override
  void initState() {
    super.initState();
    cages = rackStore.value?.rackData.cages ?? [];
    filteredCages = cages;
    selection = widget.selectedCage;
  }

  @override
  Widget build(BuildContext context) {
    print('widget.selectedCage: ${widget.selectedCage?.cageTag}');

    final widgets = <Widget>[
      TextFormField(
        decoration: InputDecoration(hintText: 'Filter cages...'),
        controller: textController,
        // keyboardType: TextInputType.text,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (value) {
          if (value.isEmpty) {
            filteredCages = cages;
            textController.text = value;
          }
          setState(() {
            filteredCages =
                cages
                    ?.where(
                      (e) =>
                          (e.cageTag?.toLowerCase().startsWith(value) ??
                              false) ||
                          (e.strain?.strainName?.toLowerCase().startsWith(
                                value,
                              ) ??
                              false),
                    )
                    .toList() ??
                [];
            textController.text = value;
          });
        },
      ),
      for (final cage in filteredCages ?? [])
        RadioListTile<RackCageDto?>(
          title: Text(_getCageOptionLabel(cage)),
          value: cage,
          // ignore: deprecated_member_use
          groupValue: selection,
          // ignore: deprecated_member_use
          onChanged: (RackCageDto? value) {
            print('selected ${value?.cageTag}');
            setState(() {
              selection = value;
            });
          },
        ),
    ];

    return AlertDialog(
      title: const Text('Select Destination Cage'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            return widgets[index];
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSubmit(selection);
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
  }
}
