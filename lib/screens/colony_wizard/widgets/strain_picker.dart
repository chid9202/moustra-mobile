import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

/// Dropdown picker for strains
class StrainPicker extends StatelessWidget {
  final String label;
  final StrainStoreDto? value;
  final List<StrainStoreDto> strains;
  final Function(StrainStoreDto?) onChanged;
  final bool allowNull;

  const StrainPicker({
    super.key,
    required this.label,
    required this.value,
    required this.strains,
    required this.onChanged,
    this.allowNull = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<StrainStoreDto?>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        if (allowNull)
          const DropdownMenuItem<StrainStoreDto?>(
            value: null,
            child: Text('No strain'),
          ),
        ...strains.map((strain) => DropdownMenuItem(
              value: strain,
              child: Text(strain.strainName),
            )),
      ],
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
