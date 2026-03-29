import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/clients/strain_api.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/end_animals_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/post_mating_dto.dart';
import 'package:moustra/services/dtos/post_plug_event_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';
import 'package:moustra/stores/profile_store.dart';

import '../helpers/integration_test_helpers.dart';

int _ts() => DateTime.now().millisecondsSinceEpoch;

Future<AccountStoreDto> _labOwner() async {
  final profile = profileState.value!;
  final accounts =
      await StoreApi<AccountStoreDto>().getStore(StoreKeys.account);
  return accounts.firstWhere(
    (a) => a.accountUuid == profile.accountUuid,
    orElse: () => accounts.first,
  );
}

CageStoreDto _cageStore(CageDto c) {
  return CageStoreDto(
    cageId: c.cageId,
    cageUuid: c.cageUuid,
    cageTag: c.cageTag,
    strain: c.strain == null
        ? null
        : CageStoreStrainDto(
            strainId: c.strain!.strainId,
            strainUuid: c.strain!.strainUuid,
            strainName: c.strain!.strainName,
            color: c.strain!.color,
          ),
    animals: const [],
  );
}

StrainStoreDto _strainStore(StrainSummaryDto s) {
  return StrainStoreDto(
    strainId: s.strainId,
    strainUuid: s.strainUuid,
    strainName: s.strainName,
    weanAge: s.weanAge,
    genotypes: const [],
  );
}

StrainStoreDto? _strainStoreFromMatingStrain(StrainSummaryDto? s) {
  if (s == null) return null;
  return _strainStore(s);
}

PutStrainDto _putStrainDto(StrainDto s, {String? comment}) {
  return PutStrainDto(
    strainId: s.strainId,
    strainUuid: s.strainUuid,
    isActive: s.isActive,
    backgrounds: s.backgrounds.map((b) => b.toBackgroundStoreDto()).toList(),
    color: s.color ?? '#808080',
    comment: comment ?? s.comment,
    owner: s.owner.toAccountStoreDto(),
    strainName: s.strainName,
    genotypes: s.genotypes,
  );
}

AnimalDto _animalWithComment(AnimalDto a, String comment) {
  return AnimalDto(
    eid: a.eid,
    animalId: a.animalId,
    animalUuid: a.animalUuid,
    physicalTag: a.physicalTag,
    dateOfBirth: a.dateOfBirth,
    sex: a.sex,
    genotypes: a.genotypes ?? const [],
    weanDate: a.weanDate,
    endDate: a.endDate,
    endType: a.endType,
    endReason: a.endReason,
    endComment: a.endComment,
    owner: a.owner,
    cage: a.cage,
    strain: a.strain,
    comment: comment,
    createdDate: a.createdDate,
    updatedDate: a.updatedDate,
    sire: a.sire,
    dam: a.dam ?? const [],
    notes: a.notes,
    matings: a.matings,
    plugEvents: a.plugEvents,
  );
}

PutMatingDto _putMatingDto(
  MatingDto m,
  AccountStoreDto owner, {
  String? comment,
  DateTime? disbandedDate,
  AccountStoreDto? disbandedBy,
}) {
  return PutMatingDto(
    matingId: m.matingId,
    matingUuid: m.matingUuid,
    matingTag: m.matingTag ?? 'it-mating',
    litterStrain: _strainStoreFromMatingStrain(m.litterStrain),
    setUpDate: m.setUpDate ?? DateTime.utc(2020, 1, 1),
    owner: owner,
    comment: comment ?? m.comment,
    disbandedDate: disbandedDate,
    disbandedBy: disbandedBy,
  );
}

Future<EndAnimalFormDto> _endFormFor(String animalUuid) async {
  final data = await animalService.getEndAnimalsData([animalUuid]);
  return EndAnimalFormDto(
    endDate: DateTime.now().toIso8601String().split('T').first,
    endType: data.endTypes.isNotEmpty ? data.endTypes.first.endTypeUuid : null,
    endReason:
        data.endReasons.isNotEmpty ? data.endReasons.first.endReasonUuid : null,
    endComment: 'integration test end',
    endCage: false,
  );
}

/// API-level CRUD (or domain delete: end / disband / delete) for each
/// first-class list entity after real login. Requires [.env.test] lab data
/// where plug events can be created for an active female.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadIntegrationTestEnv();
  });

  group('Regression: entity CRUD (API)', () {
    testWidgets('Strain: create, read, update, delete', (tester) async {
      await pumpAppAndSignIn(tester);
      final owner = await _labOwner();
      final name = 'IT_Strain_${_ts()}';

      final created = await strainService.createStrain(
        PostStrainDto(
          strainName: name,
          owner: owner,
          color: '#808080',
          backgrounds: const [],
        ),
      );
      expect(created.strainName, name);

      final fetched = await strainService.getStrain(created.strainUuid);
      expect(fetched.strainUuid, created.strainUuid);

      final updated = await strainService.putStrain(
        created.strainUuid,
        _putStrainDto(fetched, comment: 'it-updated'),
      );
      expect(updated.comment, 'it-updated');

      await strainService.deleteStrain(updated.strainUuid);
    });

    testWidgets('Cage: create, read, update, end', (tester) async {
      await pumpAppAndSignIn(tester);
      final owner = await _labOwner();
      final tag = 'IT_Cage_${_ts()}';

      final created = await cageApi.createCage(
        PostCageDto(cageTag: tag, owner: owner),
      );
      expect(created.cageTag, tag);

      final fetched = await cageApi.getCage(created.cageUuid);
      expect(fetched.cageUuid, created.cageUuid);

      final updated = await cageApi.putCage(
        fetched.cageUuid,
        PutCageDto(
          cageId: fetched.cageId,
          cageUuid: fetched.cageUuid,
          cageTag: fetched.cageTag,
          owner: fetched.owner.toAccountStoreDto(),
          strain: fetched.strain,
          setUpDate: fetched.createdDate,
          comment: 'it-cage-comment',
          barcode: fetched.barcode,
        ),
      );
      expect(updated.comment, 'it-cage-comment');

      await cageApi.endCage(updated.cageUuid);
    });

    testWidgets('Animal: create, read, update, end', (tester) async {
      await pumpAppAndSignIn(tester);
      final owner = await _labOwner();
      final t = _ts();

      final strain = await strainService.createStrain(
        PostStrainDto(
          strainName: 'IT_AnimalStrain_$t',
          owner: owner,
          color: '#808080',
          backgrounds: const [],
        ),
      );
      final strainSummary = StrainSummaryDto(
        strainId: strain.strainId,
        strainUuid: strain.strainUuid,
        strainName: strain.strainName,
      );

      final cage = await cageApi.createCage(
        PostCageDto(
          cageTag: 'IT_AnimalCage_$t',
          owner: owner,
          strain: strainSummary,
        ),
      );

      final createdList = await animalService.postAnimal(
        PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: '1',
              dateOfBirth: DateTime.utc(2024, 2, 1),
              genotypes: const [],
              physicalTag: 'IT_A_$t',
              sex: 'Male',
              strain: _strainStore(strainSummary),
              cage: _cageStore(cage),
            ),
          ],
        ),
      );
      expect(createdList, isNotEmpty);
      final uuid = createdList.first.animalUuid;

      final fetched = await animalService.getAnimal(uuid);
      expect(fetched.physicalTag, 'IT_A_$t');

      final putPayload = _animalWithComment(fetched, 'it-animal-note');
      final afterPut = await animalService.putAnimal(uuid, putPayload);
      expect(afterPut.comment, 'it-animal-note');

      await animalService.endAnimals([uuid], await _endFormFor(uuid));

      await cageApi.endCage(cage.cageUuid);
      await strainService.deleteStrain(strain.strainUuid);
    });

    testWidgets('Mating: create, read, update, disband', (tester) async {
      await pumpAppAndSignIn(tester);
      final owner = await _labOwner();
      final t = _ts();

      final strain = await strainService.createStrain(
        PostStrainDto(
          strainName: 'IT_MatingStrain_$t',
          owner: owner,
          color: '#808080',
          backgrounds: const [],
        ),
      );
      final strainSummary = StrainSummaryDto(
        strainId: strain.strainId,
        strainUuid: strain.strainUuid,
        strainName: strain.strainName,
      );

      final cage = await cageApi.createCage(
        PostCageDto(
          cageTag: 'IT_MatingCage_$t',
          owner: owner,
          strain: strainSummary,
        ),
      );
      final cageStore = _cageStore(cage);
      final sStore = _strainStore(strainSummary);

      final males = await animalService.postAnimal(
        PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: 'm',
              dateOfBirth: DateTime.utc(2024, 3, 1),
              genotypes: const [],
              physicalTag: 'IT_M_M_$t',
              sex: 'Male',
              strain: sStore,
              cage: cageStore,
            ),
          ],
        ),
      );
      final females = await animalService.postAnimal(
        PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: 'f',
              dateOfBirth: DateTime.utc(2024, 3, 2),
              genotypes: const [],
              physicalTag: 'IT_M_F_$t',
              sex: 'Female',
              strain: sStore,
              cage: cageStore,
            ),
          ],
        ),
      );

      final maleUuid = males.first.animalUuid;
      final femaleUuid = females.first.animalUuid;

      final created = await matingService.createMating(
        PostMatingDto(
          matingTag: 'IT_M_$t',
          maleAnimal: maleUuid,
          femaleAnimals: [femaleUuid],
          cage: cageStore,
          setUpDate: DateTime.utc(2024, 3, 10),
          owner: owner,
        ),
      );

      final fetched = await matingService.getMating(created.matingUuid);
      expect(fetched.matingTag, 'IT_M_$t');

      await matingService.putMating(
        fetched.matingUuid,
        _putMatingDto(fetched, owner, comment: 'it-mating-updated'),
      );
      final afterComment = await matingService.getMating(fetched.matingUuid);
      expect(afterComment.comment, 'it-mating-updated');

      await matingService.putMating(
        fetched.matingUuid,
        _putMatingDto(
          afterComment,
          owner,
          disbandedDate: DateTime.now(),
          disbandedBy: owner,
        ),
      );

      await animalService.endAnimals([maleUuid], await _endFormFor(maleUuid));
      await animalService
          .endAnimals([femaleUuid], await _endFormFor(femaleUuid));
      await cageApi.endCage(cage.cageUuid);
      await strainService.deleteStrain(strain.strainUuid);
    });

    testWidgets('Litter: create, read, update, end', (tester) async {
      await pumpAppAndSignIn(tester);
      final owner = await _labOwner();
      final t = _ts();

      final strain = await strainService.createStrain(
        PostStrainDto(
          strainName: 'IT_LitterStrain_$t',
          owner: owner,
          color: '#808080',
          backgrounds: const [],
        ),
      );
      final strainSummary = StrainSummaryDto(
        strainId: strain.strainId,
        strainUuid: strain.strainUuid,
        strainName: strain.strainName,
      );

      final cage = await cageApi.createCage(
        PostCageDto(
          cageTag: 'IT_LitterCage_$t',
          owner: owner,
          strain: strainSummary,
        ),
      );
      final cageStore = _cageStore(cage);
      final sStore = _strainStore(strainSummary);

      final males = await animalService.postAnimal(
        PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: 'm',
              dateOfBirth: DateTime.utc(2024, 4, 1),
              genotypes: const [],
              physicalTag: 'IT_L_M_$t',
              sex: 'Male',
              strain: sStore,
              cage: cageStore,
            ),
          ],
        ),
      );
      final females = await animalService.postAnimal(
        PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: 'f',
              dateOfBirth: DateTime.utc(2024, 4, 2),
              genotypes: const [],
              physicalTag: 'IT_L_F_$t',
              sex: 'Female',
              strain: sStore,
              cage: cageStore,
            ),
          ],
        ),
      );

      final mating = await matingService.createMating(
        PostMatingDto(
          matingTag: 'IT_LMat_$t',
          maleAnimal: males.first.animalUuid,
          femaleAnimals: [females.first.animalUuid],
          cage: cageStore,
          setUpDate: DateTime.utc(2024, 4, 10),
          owner: owner,
        ),
      );

      final litterTag = 'IT_L_$t';
      await litterService.createLitter(
        PostLitterDto(
          mating: mating.matingUuid,
          numberOfMale: 0,
          numberOfFemale: 0,
          numberOfUnknown: 0,
          litterTag: litterTag,
          dateOfBirth: DateTime.utc(2024, 5, 1),
          owner: owner,
        ),
      );

      final matingAfter = await matingService.getMating(mating.matingUuid);
      LitterDto? litter;
      for (final l in matingAfter.litters ?? const <LitterDto>[]) {
        if (l.litterTag == litterTag) {
          litter = l;
          break;
        }
      }
      expect(litter, isNotNull, reason: 'Litter should appear on mating');
      final litterUuid = litter!.litterUuid;

      final litterFetched = await litterService.getLitter(litterUuid);
      expect(litterFetched.litterTag, litterTag);

      await litterService.putLitter(
        litterUuid,
        PutLitterDto(comment: 'it-litter-updated'),
      );
      final afterPut = await litterService.getLitter(litterUuid);
      expect(afterPut.comment, 'it-litter-updated');

      await litterService.endLitters(
        [litterUuid],
        DateTime.now(),
      );

      await matingService.putMating(
        mating.matingUuid,
        _putMatingDto(
          await matingService.getMating(mating.matingUuid),
          owner,
          disbandedDate: DateTime.now(),
          disbandedBy: owner,
        ),
      );

      await animalService.endAnimals(
        [males.first.animalUuid],
        await _endFormFor(males.first.animalUuid),
      );
      await animalService.endAnimals(
        [females.first.animalUuid],
        await _endFormFor(females.first.animalUuid),
      );
      await cageApi.endCage(cage.cageUuid);
      await strainService.deleteStrain(strain.strainUuid);
    });

    testWidgets('Plug event: create, read, update, delete', (tester) async {
      await pumpAppAndSignIn(tester);

      final page = await animalService.getAnimalsPage(pageSize: 100);
      String? femaleUuid;
      for (final a in page.results) {
        if (a.sex == 'Female' && a.endDate == null) {
          femaleUuid = a.animalUuid;
          break;
        }
      }
      expect(
        femaleUuid,
        isNotNull,
        reason: 'Need an active female animal in the lab for plug CRUD',
      );

      final plugDate = DateTime.now().toIso8601String().split('T').first;
      final created = await plugService.createPlugEvent(
        PostPlugEventDto(
          female: femaleUuid!,
          plugDate: plugDate,
          comment: 'it-plug-create',
        ),
      );

      final fetched = await plugService.getPlugEvent(created.plugEventUuid);
      expect(fetched.plugEventUuid, created.plugEventUuid);

      await plugService.updatePlugEvent(
        fetched.plugEventUuid,
        PutPlugEventDto(comment: 'it-plug-updated'),
      );
      final afterPut = await plugService.getPlugEvent(fetched.plugEventUuid);
      expect(afterPut.comment, 'it-plug-updated');

      await plugService.deletePlugEvent(fetched.plugEventUuid);
    });

    testWidgets('Lab user: list, read, update (no delete API)', (
      tester,
    ) async {
      await pumpAppAndSignIn(tester);
      final api = UsersApi(dioApiClient);

      final list = await api.getUsers();
      expect(list, isNotEmpty);

      final selfUuid = profileState.value!.accountUuid;
      final detail = await api.getUser(selfUuid);
      expect(detail.accountUuid, selfUuid);

      final original = detail.position;
      final probe = original == null ? 'it-position' : '${original}_it';

      PutUserDetailDto payload({
        required String? position,
      }) {
        return PutUserDetailDto(
          accountUuid: selfUuid,
          email: detail.user.email,
          firstName: detail.user.firstName,
          lastName: detail.user.lastName,
          role: detail.role,
          isActive: detail.isActive,
          position: position,
          accountSetting: detail.accountSetting,
        );
      }

      await api.updateUser(selfUuid, payload(position: probe));
      final after = await api.getUser(selfUuid);
      expect(after.position, probe);

      await api.updateUser(selfUuid, payload(position: original));
    });
  });
}
