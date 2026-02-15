import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/widgets/cage/cage_label_pdf.dart';

void main() {
  group('CageLabelPdf', () {
    CageDto createCage({
      String cageTag = 'C001',
      String cageUuid = 'cage-uuid-1',
      String firstName = 'John',
      String lastName = 'Doe',
      StrainSummaryDto? strain,
      List<AnimalSummaryDto> animals = const [],
      DateTime? createdDate,
    }) {
      return CageDto(
        cageId: 1,
        cageTag: cageTag,
        cageUuid: cageUuid,
        owner: AccountDto(
          accountId: 1,
          accountUuid: 'owner-uuid-1',
          user: UserDto(
            firstName: firstName,
            lastName: lastName,
            email: 'john@example.com',
          ),
        ),
        status: 'active',
        animals: animals,
        strain: strain,
        createdDate: createdDate,
      );
    }

    test('should build a PDF document', () {
      final cage = createCage();
      final doc = CageLabelPdf.build(cage);

      expect(doc, isNotNull);
    });

    test('should generate saveable PDF bytes', () async {
      final cage = createCage();
      final doc = CageLabelPdf.build(cage);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
    });

    test('should build PDF with strain info', () async {
      final cage = createCage(
        strain: StrainSummaryDto(
          strainId: 1,
          strainUuid: 'strain-uuid-1',
          strainName: 'C57BL/6',
        ),
      );
      final doc = CageLabelPdf.build(cage);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
    });

    test('should build PDF with animals', () async {
      final cage = createCage(
        animals: [
          AnimalSummaryDto(
            animalId: 1,
            animalUuid: 'animal-1',
            physicalTag: 'A001',
            sex: 'Male',
            dateOfBirth: DateTime(2023, 1, 1),
          ),
          AnimalSummaryDto(
            animalId: 2,
            animalUuid: 'animal-2',
            physicalTag: 'A002',
            sex: 'Female',
            dateOfBirth: DateTime(2023, 2, 1),
          ),
        ],
      );
      final doc = CageLabelPdf.build(cage);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
    });

    test('should build PDF with no strain', () async {
      final cage = createCage(strain: null);
      final doc = CageLabelPdf.build(cage);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
    });

    test('should build PDF with created date', () async {
      final cage = createCage(createdDate: DateTime(2023, 6, 15));
      final doc = CageLabelPdf.build(cage);
      final bytes = await doc.save();

      expect(bytes, isNotEmpty);
    });
  });
}
