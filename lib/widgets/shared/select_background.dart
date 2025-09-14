import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/stores/background_store.dart';

class SelectBackground extends StatelessWidget {
  const SelectBackground({
    super.key,
    required this.selectedBackgrounds,
    required this.onChanged,
  });
  final List<BackgroundStoreDto> selectedBackgrounds;
  final Function(List<BackgroundStoreDto>) onChanged;

  @override
  Widget build(BuildContext context) {
    if (backgroundStore.value.isEmpty) {
      StoreApi<BackgroundStoreDto>().getStore(StoreKeys.background).then((
        value,
      ) {
        backgroundStore.value = value;
      });
    }

    void showBackgroundPicker() {
      List<BackgroundStoreDto> tempSelectedBackgrounds = List.from(
        selectedBackgrounds,
      );

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Backgrounds'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: backgroundStore.value.length,
                    itemBuilder: (context, index) {
                      final background = backgroundStore.value[index];
                      final isSelected = tempSelectedBackgrounds.any(
                        (bg) => bg.uuid == background.uuid,
                      );

                      return CheckboxListTile(
                        title: Text(background.name),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelectedBackgrounds.add(background);
                            } else {
                              tempSelectedBackgrounds.removeWhere(
                                (bg) => bg.uuid == background.uuid,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      onChanged(tempSelectedBackgrounds);
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
          onChanged(List.from(selectedBackgrounds));
        }
      });
    }

    return InkWell(
      onTap: showBackgroundPicker,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Backgrounds',
          border: OutlineInputBorder(),
        ),
        child: selectedBackgrounds.isEmpty
            ? const Text(
                'Select backgrounds',
                style: TextStyle(color: Colors.grey),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedBackgrounds.map((bg) {
                  return Chip(
                    label: Text(bg.name),
                    onDeleted: () {
                      onChanged(
                        selectedBackgrounds
                            .where((background) => background.uuid != bg.uuid)
                            .toList(),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
