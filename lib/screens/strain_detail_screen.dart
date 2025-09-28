import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/shared/select_background.dart';
import 'package:moustra/widgets/shared/select_owner.dart';

class StrainDetailScreen extends StatefulWidget {
  const StrainDetailScreen({super.key});

  @override
  State<StrainDetailScreen> createState() => _StrainDetailScreenState();
}

class _StrainDetailScreenState extends State<StrainDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _strainNameController = TextEditingController();
  final _commentController = TextEditingController();

  Color _selectedColor = Colors.white;
  AccountStoreDto? _selectedOwner;
  List<BackgroundStoreDto> _selectedBackgrounds = [];
  StrainDto? _strainData;
  bool _strainDataLoaded = false;

  // Get the strain UUID from the route parameters
  String? get _strainUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['strainUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_strainDataLoaded) {
      _loadStrainData();
    }
  }

  void _loadDefaultOwner() async {
    final owner = await AccountHelper.getDefaultOwner();
    if (mounted) {
      setState(() {
        _selectedOwner = owner;
      });
    }
  }

  void _loadStrainData() async {
    final strainUuid = _strainUuid;
    if (strainUuid == null || strainUuid == 'new') {
      _strainDataLoaded = true;
      return;
    }
    try {
      // Load existing strain data for editing
      final strain = await StrainApi().getStrain(strainUuid);
      if (mounted) {
        setState(() {
          _strainNameController.text = strain.strainName;
          _commentController.text = strain.comment ?? '';

          // Set color if available
          if (strain.color != null && strain.color!.isNotEmpty) {
            final colorValue = int.tryParse('FF${strain.color}', radix: 16);
            if (colorValue != null) {
              _selectedColor = Color(colorValue);
            }
          }

          // Set owner
          _selectedOwner = strain.owner.toAccountStoreDto();

          // Set backgrounds
          _selectedBackgrounds = strain.backgrounds
              .map((e) => e.toBackgroundStoreDto())
              .toList();
          _strainData = strain;
          _strainDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading strain: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading strain: $e')));
      }
      _strainDataLoaded = true; // Mark as loaded even on error to prevent retry
    }
  }

  @override
  void dispose() {
    _strainNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final predefinedColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) {
        if (_strainUuid != null && !_strainDataLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return AlertDialog(
          title: const Text('Select Color'),
          content: SizedBox(
            width: 300,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: predefinedColors.length,
              itemBuilder: (context, index) {
                final color = predefinedColors[index];
                final isSelected = _selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _saveStrain() async {
    if (_formKey.currentState!.validate()) {
      try {
        final strainUuid = _strainUuid;
        if (strainUuid == null || strainUuid == 'new') {
          // Create new strain
          final strain = PostStrainDto(
            strainName: _strainNameController.text,
            color: _selectedColor.value
                .toRadixString(16)
                .substring(2)
                .toUpperCase(),
            owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
            backgrounds: _selectedBackgrounds,
            comment: _commentController.text,
          );
          await StrainApi().createStrain(strain);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Strain created successfully!')),
          );
        } else {
          // Update existing strain
          StrainApi().putStrain(
            strainUuid,
            PutStrainDto(
              strainId: _strainData!.strainId,
              strainUuid: strainUuid,
              backgrounds: _selectedBackgrounds,
              color: _selectedColor.value
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase(),
              comment: _commentController.text,
              owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
              strainName: _strainNameController.text,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Strain updated successfully!')),
          );
        }
        context.go('/strains');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving strain: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/strains');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _strainUuid == null || _strainUuid == 'new'
              ? 'Create Strain'
              : 'Edit Strain',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strain Name Field
              TextFormField(
                controller: _strainNameController,
                decoration: const InputDecoration(
                  labelText: 'Strain Name',
                  hintText: 'Enter strain name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a strain name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Color Picker
              InkWell(
                onTap: _showColorPicker,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Owner Select Field
              SelectOwner(
                selectedOwner: _selectedOwner,
                onChanged: (owner) {
                  setState(() {
                    _selectedOwner = owner;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Comment Field
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  hintText: 'Enter any additional comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Background Multi-Select
              SelectBackground(
                selectedBackgrounds: _selectedBackgrounds,
                onChanged: (backgrounds) {
                  setState(() {
                    _selectedBackgrounds = backgrounds;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  label: 'Save',
                  onPressed: _saveStrain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
