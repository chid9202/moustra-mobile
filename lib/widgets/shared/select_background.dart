import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/stores/background_store.dart' show getBackgroundsHook, postBackgroundHook;

class SelectBackground extends StatefulWidget {
  const SelectBackground({
    super.key,
    required this.selectedBackgrounds,
    required this.onChanged,
  });
  final List<BackgroundStoreDto> selectedBackgrounds;
  final Function(List<BackgroundStoreDto>) onChanged;

  @override
  State<SelectBackground> createState() => _SelectBackgroundState();
}

class _SelectBackgroundState extends State<SelectBackground> {
  List<BackgroundStoreDto>? backgrounds;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  void _loadBackgrounds() async {
    if (backgrounds == null && mounted) {
      final loadedBackgrounds = await getBackgroundsHook();
      setState(() {
        backgrounds = loadedBackgrounds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (backgrounds == null) {
      StoreApi<BackgroundStoreDto>().getStore(StoreKeys.background).then((
        value,
      ) {
        backgrounds = value;
      });
    }

    void showBackgroundPicker() {
      List<BackgroundStoreDto> tempSelectedBackgrounds = List.from(
        widget.selectedBackgrounds,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: backgrounds?.length ?? 0,
                          itemBuilder: (context, index) {
                            final background = backgrounds?[index];
                            final isSelected = tempSelectedBackgrounds.any(
                              (bg) => bg.uuid == background?.uuid,
                            );

                            return CheckboxListTile(
                              title: Text(background?.name ?? ''),
                              value: isSelected,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelectedBackgrounds.add(background!);
                                  } else {
                                    tempSelectedBackgrounds.removeWhere(
                                      (bg) => bg.uuid == background?.uuid,
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddBackgroundDialog(setDialogState),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Background'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.onChanged(tempSelectedBackgrounds);
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
          widget.onChanged(List.from(widget.selectedBackgrounds));
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
        child: widget.selectedBackgrounds.isEmpty
            ? const Text(
                'Select backgrounds',
                style: TextStyle(color: Colors.grey),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.selectedBackgrounds.map((bg) {
                  return Chip(
                    label: Text(bg.name),
                    onDeleted: () {
                      widget.onChanged(
                        widget.selectedBackgrounds
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

  void _showAddBackgroundDialog(StateSetter setDialogState) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Background'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Background Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  debugPrint('Creating background: ${controller.text}');
                  Navigator.of(context).pop();
                  await postBackgroundHook(controller.text);
                  // Reload backgrounds list
                  final loadedBackgrounds = await getBackgroundsHook();
                  setState(() {
                    backgrounds = loadedBackgrounds;
                  });
                  setDialogState(() {});
                  debugPrint('Background creation completed');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
