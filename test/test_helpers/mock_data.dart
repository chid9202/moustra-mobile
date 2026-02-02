import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

/// Mock data factory for creating test data objects
class MockDataFactory {
  /// Creates a mock AnimalStoreDto
  static AnimalStoreDto createAnimalStoreDto({
    int? eid,
    int? animalId,
    String? animalUuid,
    String? physicalTag,
    String? sex,
  }) {
    return AnimalStoreDto(
      eid: eid ?? 1,
      animalId: animalId ?? 1,
      animalUuid: animalUuid ?? 'test-animal-uuid',
      physicalTag: physicalTag ?? 'A001',
      sex: sex ?? 'Male',
      dateOfBirth: DateTime.now(),
    );
  }

  /// Creates a list of mock AnimalStoreDto objects
  static List<AnimalStoreDto> createAnimalStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createAnimalStoreDto(
        eid: index + 1,
        animalId: index + 1,
        animalUuid: 'test-animal-uuid-$index',
        physicalTag: 'A${(index + 1).toString().padLeft(3, '0')}',
        sex: index % 2 == 0 ? 'Male' : 'Female',
      );
    });
  }

  /// Creates a mock AnimalSummaryDto
  static AnimalSummaryDto createAnimalSummaryDto({
    int? animalId,
    String? animalUuid,
    String? physicalTag,
    String? sex,
  }) {
    return AnimalSummaryDto(
      animalId: animalId ?? 1,
      animalUuid: animalUuid ?? 'test-animal-uuid',
      physicalTag: physicalTag ?? 'A001',
      sex: sex ?? 'Male',
      dateOfBirth: DateTime.now(),
    );
  }

  /// Creates a mock CageStoreDto
  static CageStoreDto createCageStoreDto({
    int? cageId,
    String? cageUuid,
    String? cageTag,
  }) {
    return CageStoreDto(
      cageId: cageId ?? 1,
      cageUuid: cageUuid ?? 'test-cage-uuid',
      cageTag: cageTag,
    );
  }

  /// Creates a list of mock CageStoreDto objects
  static List<CageStoreDto> createCageStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createCageStoreDto(
        cageId: index + 1,
        cageUuid: 'test-cage-uuid-$index',
        cageTag: 'C${(index + 1).toString().padLeft(3, '0')}',
      );
    });
  }

  /// Creates a mock StrainStoreDto
  static StrainStoreDto createStrainStoreDto({
    int? strainId,
    String? strainUuid,
    String? strainName,
  }) {
    return StrainStoreDto(
      strainId: strainId ?? 1,
      strainUuid: strainUuid ?? 'test-strain-uuid',
      strainName: strainName ?? 'Test Strain',
      genotypes: [],
    );
  }

  /// Creates a list of mock StrainStoreDto objects
  static List<StrainStoreDto> createStrainStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createStrainStoreDto(
        strainId: index + 1,
        strainUuid: 'test-strain-uuid-$index',
        strainName: 'Test Strain ${index + 1}',
      );
    });
  }

  /// Creates a mock GeneStoreDto
  static GeneStoreDto createGeneStoreDto({
    int? geneId,
    String? geneUuid,
    String? geneName,
    bool? isActive,
  }) {
    return GeneStoreDto(
      geneId: geneId ?? 1,
      geneUuid: geneUuid ?? 'test-gene-uuid',
      geneName: geneName ?? 'Test Gene',
      isActive: isActive ?? true,
    );
  }

  /// Creates a list of mock GeneStoreDto objects
  static List<GeneStoreDto> createGeneStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createGeneStoreDto(
        geneId: index + 1,
        geneUuid: 'test-gene-uuid-$index',
        geneName: 'Test Gene ${index + 1}',
      );
    });
  }

  /// Creates a mock AlleleStoreDto
  static AlleleStoreDto createAlleleStoreDto({
    int? alleleId,
    String? alleleUuid,
    String? alleleName,
    bool? isActive,
  }) {
    return AlleleStoreDto(
      alleleId: alleleId ?? 1,
      alleleUuid: alleleUuid ?? 'test-allele-uuid',
      alleleName: alleleName ?? 'Test Allele',
      isActive: isActive ?? true,
    );
  }

  /// Creates a list of mock AlleleStoreDto objects
  static List<AlleleStoreDto> createAlleleStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createAlleleStoreDto(
        alleleId: index + 1,
        alleleUuid: 'test-allele-uuid-$index',
        alleleName: 'Test Allele ${index + 1}',
      );
    });
  }

  /// Creates a mock BackgroundStoreDto
  static BackgroundStoreDto createBackgroundStoreDto({
    int? id,
    String? uuid,
    String? name,
  }) {
    return BackgroundStoreDto(
      id: id ?? 1,
      uuid: uuid ?? 'test-background-uuid',
      name: name ?? 'Test Background',
    );
  }

  /// Creates a list of mock BackgroundStoreDto objects
  static List<BackgroundStoreDto> createBackgroundStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createBackgroundStoreDto(
        id: index + 1,
        uuid: 'test-background-uuid-$index',
        name: 'Test Background ${index + 1}',
      );
    });
  }

  /// Creates a mock AccountStoreDto
  static AccountStoreDto createAccountStoreDto({
    int? accountId,
    String? accountUuid,
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return AccountStoreDto(
      accountId: accountId ?? 1,
      accountUuid: accountUuid ?? 'test-account-uuid',
      user: UserDto(
        firstName: firstName ?? 'Test',
        lastName: lastName ?? 'User',
        email: email ?? 'test@example.com',
      ),
    );
  }

  /// Creates a list of mock AccountStoreDto objects
  static List<AccountStoreDto> createAccountStoreDtoList(int count) {
    return List.generate(count, (index) {
      return createAccountStoreDto(
        accountId: index + 1,
        accountUuid: 'test-account-uuid-$index',
        firstName: 'Test',
        lastName: 'User ${index + 1}',
        email: 'test${index + 1}@example.com',
      );
    });
  }

  /// Creates a mock MatingDto
  static MatingDto createMatingDto({
    int? matingId,
    String? matingUuid,
    String? matingTag,
    DateTime? setUpDate,
    int? animalCount,
  }) {
    return MatingDto(
      matingId: matingId ?? 1,
      matingUuid: matingUuid ?? 'test-mating-uuid',
      matingTag: matingTag ?? 'M001',
      setUpDate: setUpDate ?? DateTime.now(),
      animals: List.generate(
        animalCount ?? 2,
        (index) => createAnimalSummaryDto(),
      ),
    );
  }

  /// Creates a list of mock MatingDto objects
  static List<MatingDto> createMatingDtoList(int count) {
    return List.generate(count, (index) {
      return createMatingDto(
        matingId: index + 1,
        matingUuid: 'test-mating-uuid-$index',
        matingTag: 'M${(index + 1).toString().padLeft(3, '0')}',
        animalCount: 2,
      );
    });
  }

  /// Creates a mock RackCageDto
  static RackCageDto createRackCageDto({
    String? cageTag,
    String? cageUuid,
    String? strainName,
    int? xPosition,
    int? yPosition,
    int? order,
  }) {
    return RackCageDto(
      cageTag: cageTag ?? 'C001',
      cageUuid: cageUuid ?? 'test-cage-uuid',
      strain: strainName != null
          ? RackCageStrainDto(strainName: strainName)
          : null,
      xPosition: xPosition,
      yPosition: yPosition,
      order: order,
    );
  }

  /// Creates a list of mock RackCageDto objects
  static List<RackCageDto> createRackCageDtoList(int count) {
    return List.generate(count, (index) {
      return createRackCageDto(
        cageTag: 'C${(index + 1).toString().padLeft(3, '0')}',
        cageUuid: 'test-cage-uuid-$index',
        strainName: 'Test Strain ${index + 1}',
      );
    });
  }

  /// Creates a list of mock RackCageDto objects with x,y positions
  static List<RackCageDto> createRackCageDtoListWithPositions(
    int count, {
    required int rackWidth,
  }) {
    return List.generate(count, (index) {
      final x = index % rackWidth;
      final y = index ~/ rackWidth;
      return createRackCageDto(
        cageTag: 'C${(index + 1).toString().padLeft(3, '0')}',
        cageUuid: 'test-cage-uuid-$index',
        strainName: 'Test Strain ${index + 1}',
        xPosition: x,
        yPosition: y,
        order: index,
      );
    });
  }

  /// Creates a mock RackDto
  static RackDto createRackDto({
    int? rackId,
    String? rackUuid,
    String? rackName,
    int? rackWidth,
    int? rackHeight,
    List<RackCageDto>? cages,
    List<RackSimpleDto>? racks,
  }) {
    return RackDto(
      rackId: rackId ?? 1,
      rackUuid: rackUuid ?? 'test-rack-uuid',
      rackName: rackName ?? 'Test Rack',
      rackWidth: rackWidth,
      rackHeight: rackHeight,
      cages: cages,
      racks: racks,
    );
  }

  /// Creates a mock RackStoreDto
  static RackStoreDto createRackStoreDto({
    RackDto? rackData,
    List<double>? transformationMatrix,
  }) {
    return RackStoreDto(
      rackData: rackData ?? createRackDto(),
      transformationMatrix: transformationMatrix,
    );
  }
}
