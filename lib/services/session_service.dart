import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/clients/profile_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/allele_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/background_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/gene_store.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/stores/setting_store.dart';
import 'package:moustra/stores/strain_store.dart';

/// Fetches the user profile and initializes all data stores.
/// Called after authentication (both silent restore and explicit login).
/// Throws on failure — callers should handle by logging the user out.
Future<void> setupSession() async {
  final req = ProfileRequestDto(
    email: authService.user?.email ?? '',
    firstName: authService.user?.givenName ?? '',
    lastName: authService.user?.familyName ?? '',
  );
  final profile = await profileService.getProfile(req);
  profileState.value = profile;

  // Initialize stores in parallel (fire and forget)
  useAccountStore();
  useAnimalStore();
  useCageStore();
  useStrainStore();
  useGeneStore();
  useAlleleStore();
  useRackStore();
  useBackgroundStore();
  useSettingStore();
}
