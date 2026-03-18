import 'package:moustra_api/moustra_api.dart';
import 'package:moustra/services/clients/dio_client.dart';
import 'package:moustra/stores/profile_store.dart';

/// Thin wrapper around the generated MoustraApi client.
/// Provides access to all generated API classes with a pre-configured Dio
/// instance (auth, connectivity, timeouts).
class GeneratedApi {
  late final MoustraApi _api;

  GeneratedApi() {
    _api = MoustraApi(
      dio: createDio(),
      interceptors: [], // We handle auth in our own Dio interceptors
    );
  }

  /// The current account UUID from the profile store.
  /// Pass this to generated API methods that require `accountUuid`.
  String get accountUuid => profileState.value?.accountUuid ?? '';

  // --- API accessors ---
  AccountApi get account => _api.getAccountApi();
  AccountInviteApi get accountInvite => _api.getAccountInviteApi();
  AIApi get ai => _api.getAIApi();
  AlleleApi get alleles => _api.getAlleleApi();
  AnimalApi get animals => _api.getAnimalApi();
  AnimalAttachmentApi get attachments => _api.getAnimalAttachmentApi();
  AuthApi get auth => _api.getAuthApi();
  BackgroundApi get background => _api.getBackgroundApi();
  CageApi get cages => _api.getCageApi();
  DashboardApi get dashboard => _api.getDashboardApi();
  EarMarkApi get earMarks => _api.getEarMarkApi();
  EndReasonApi get endReasons => _api.getEndReasonApi();
  EndTypeApi get endTypes => _api.getEndTypeApi();
  EventApi get events => _api.getEventApi();
  GeneApi get genes => _api.getGeneApi();
  IntegrationsApi get integrations => _api.getIntegrationsApi();
  LabApi get lab => _api.getLabApi();
  LabUserApi get labUsers => _api.getLabUserApi();
  LitterApi get litters => _api.getLitterApi();
  MatingApi get matings => _api.getMatingApi();
  NoteApi get notes => _api.getNoteApi();
  RackApi get racks => _api.getRackApi();
  ReportApi get reports => _api.getReportApi();
  StoreApi get store => _api.getStoreApi();
  StrainApi get strains => _api.getStrainApi();
  SubscriptionApi get subscriptions => _api.getSubscriptionApi();
  TableSettingApi get tableSettings => _api.getTableSettingApi();
  TemplateApi get templates => _api.getTemplateApi();
  TransnetyxApi get transnetyx => _api.getTransnetyxApi();
}

final generatedApi = GeneratedApi();
