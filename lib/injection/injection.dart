import 'dart:async';

// Import only FirebaseFirestore: cloud_firestore also exports a `Type` class
// (Pipeline API) that would otherwise shadow dart:core's Type used by the
// service locator's `Map<Type, Object>`.
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/locale/app_locale_controller.dart';
import '../core/session/app_session.dart';
import '../core/session/current_user_controller.dart';
import '../core/session/pending_moderation_controller.dart';
import '../core/session/platform_super_admin_seed.dart';
import '../core/theme/app_appearance_controller.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/get_notifications.dart';
import '../features/community/data/datasources/community_remote_datasource.dart';
import '../features/community/data/repositories/community_repository_impl.dart';
import '../features/community/domain/repositories/community_repository.dart';
import '../features/community/domain/usecases/community_usecases.dart';
import '../features/government/data/datasources/government_remote_datasource.dart';
import '../features/government/data/repositories/government_repository_impl.dart';
import '../features/government/domain/repositories/government_repository.dart';
import '../features/government/domain/usecases/government_usecases.dart';
import '../features/resources/data/datasources/resources_remote_datasource.dart';
import '../features/resources/data/repositories/resources_repository_impl.dart';
import '../features/resources/domain/repositories/resources_repository.dart';
import '../features/resources/domain/usecases/resources_usecases.dart';
import '../features/opportunities/data/datasources/application_firestore_datasource.dart';
import '../features/opportunities/data/datasources/opportunity_firestore_datasource.dart';
import '../features/opportunities/data/repositories/application_repository_impl.dart';
import '../features/opportunities/data/repositories/opportunity_repository_impl.dart';
import '../features/opportunities/domain/repositories/application_repository.dart';
import '../features/opportunities/domain/repositories/opportunity_repository.dart';
import '../features/opportunities/domain/usecases/application_usecases.dart';
import '../features/opportunities/domain/usecases/opportunity_usecases.dart';

final sl = ServiceLocator();

class ServiceLocator {
  final Map<Type, Object> _services = {};

  T call<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError(
        'Service $T is not registered. Did you call initDependencies()?',
      );
    }
    return service as T;
  }

  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  AuthBloc createAuthBloc() {
    return AuthBloc(
      registerUser: call(),
      loginUser: call(),
      signInWithGoogle: call(),
      sendPasswordResetEmail: call(),
      updateUserInterests: call(),
      getCurrentUser: call(),
    );
  }
}

Future<void> initDependencies({
  AuthRepository? authRepositoryOverride,
  FirebaseFirestore? firestoreOverride,
}) async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<AppSession>(AppSession(prefs));
  final currentUserController = CurrentUserController();
  sl.registerSingleton<CurrentUserController>(currentUserController);

  late final AuthRepository authRepository;
  if (authRepositoryOverride != null) {
    authRepository = authRepositoryOverride;
  } else {
    final googleSignIn = GoogleSignIn.instance;
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    // Web requires a client ID; skip init so email/password still works in Chrome.
    if (!kIsWeb || webClientId.isNotEmpty) {
      try {
        await googleSignIn
            .initialize(
              clientId: kIsWeb ? webClientId : null,
              serverClientId: webClientId.isEmpty ? null : webClientId,
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Google Sign-In CDN may be blocked; email/password auth still works.
      }
    }

    final authLocal = AuthLocalDataSource(prefs);
    final authRemote = FirebaseAuthRemoteDataSource(
      FirebaseAuth.instance,
      googleSignIn,
    );

    authRepository = AuthRepositoryImpl(
      authRemote,
      authLocal,
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      currentUser: currentUserController,
    );
  }
  sl.registerSingleton<AuthRepository>(authRepository);

  // Ensure the official Platform Super Admin account exists in Firebase.
  unawaited(ensurePlatformSuperAdmin());

  final cachedUser = await authRepository.getCurrentUser();
  if (cachedUser != null) {
    currentUserController.apply(cachedUser);
  }
  sl.registerSingleton<AppLocaleController>(
    AppLocaleController(prefs, cachedUser?.language),
  );
  sl.registerSingleton<AppAppearanceController>(AppAppearanceController(prefs));
  sl.registerSingleton<RegisterUser>(RegisterUser(authRepository));
  sl.registerSingleton<LoginUser>(LoginUser(authRepository));
  sl.registerSingleton<SignInWithGoogle>(SignInWithGoogle(authRepository));
  sl.registerSingleton<SendPasswordResetEmail>(
    SendPasswordResetEmail(authRepository),
  );
  sl.registerSingleton<UpdateUserInterests>(
    UpdateUserInterests(authRepository),
  );
  sl.registerSingleton<GetCurrentUser>(GetCurrentUser(authRepository));
  sl.registerSingleton<CompleteOnboarding>(CompleteOnboarding(authRepository));
  sl.registerSingleton<HasCompletedOnboarding>(
    HasCompletedOnboarding(authRepository),
  );

  final FirebaseFirestore firestore =
      firestoreOverride ?? FirebaseFirestore.instance;
  final opportunityDataSource = OpportunityFirestoreDataSource(firestore);
  final opportunityRepository = OpportunityRepositoryImpl(
    opportunityDataSource,
  );
  sl.registerSingleton<OpportunityRepository>(opportunityRepository);
  sl.registerSingleton<GetOpportunities>(
    GetOpportunities(opportunityRepository),
  );
  sl.registerSingleton<GetRecommendedOpportunities>(
    GetRecommendedOpportunities(opportunityRepository),
  );
  sl.registerSingleton<GetSavedOpportunities>(
    GetSavedOpportunities(opportunityRepository),
  );
  sl.registerSingleton<GetMyOpportunities>(
    GetMyOpportunities(opportunityRepository),
  );
  sl.registerSingleton<ToggleSavedOpportunity>(
    ToggleSavedOpportunity(opportunityRepository),
  );
  sl.registerSingleton<GetOpportunityById>(
    GetOpportunityById(opportunityRepository),
  );
  sl.registerSingleton<CreateOpportunity>(
    CreateOpportunity(opportunityRepository),
  );
  sl.registerSingleton<UpdateOpportunity>(
    UpdateOpportunity(opportunityRepository),
  );
  sl.registerSingleton<DeleteOpportunity>(
    DeleteOpportunity(opportunityRepository),
  );
  sl.registerSingleton<GetPendingOpportunities>(
    GetPendingOpportunities(opportunityRepository),
  );
  sl.registerSingleton<GetAllOpportunitiesForAdmin>(
    GetAllOpportunitiesForAdmin(opportunityRepository),
  );
  sl.registerSingleton<ReviewOpportunity>(
    ReviewOpportunity(opportunityRepository),
  );

  final applicationDataSource = ApplicationFirestoreDataSource(firestore);
  final applicationRepository = ApplicationRepositoryImpl(
    applicationDataSource,
  );
  sl.registerSingleton<ApplicationRepository>(applicationRepository);
  sl.registerSingleton<SubmitApplication>(
    SubmitApplication(applicationRepository),
  );
  sl.registerSingleton<GetMyApplicationForOpportunity>(
    GetMyApplicationForOpportunity(applicationRepository),
  );
  sl.registerSingleton<GetProviderApplications>(
    GetProviderApplications(applicationRepository),
  );
  sl.registerSingleton<GetOpportunityApplications>(
    GetOpportunityApplications(applicationRepository),
  );
  sl.registerSingleton<GetApplicationById>(
    GetApplicationById(applicationRepository),
  );
  sl.registerSingleton<ReviewApplication>(
    ReviewApplication(applicationRepository),
  );

  final notificationDataSource = NotificationFirestoreDataSource(firestore);
  final notificationRepository = NotificationRepositoryImpl(
    notificationDataSource,
  );
  sl.registerSingleton<NotificationRepository>(notificationRepository);
  sl.registerSingleton<GetNotifications>(
    GetNotifications(notificationRepository),
  );
  sl.registerSingleton<CreateAnnouncement>(
    CreateAnnouncement(notificationRepository),
  );
  sl.registerSingleton<GetPendingAnnouncements>(
    GetPendingAnnouncements(notificationRepository),
  );
  sl.registerSingleton<ReviewAnnouncement>(
    ReviewAnnouncement(notificationRepository),
  );

  final pendingModeration = PendingModerationController(
    currentUser: currentUserController,
    getPendingOpportunities: sl(),
    getPendingAnnouncements: sl(),
  );
  sl.registerSingleton<PendingModerationController>(pendingModeration);
  pendingModeration.start();

  _registerFirestoreContent();
}

/// Registers the Firestore-backed content features (Community / Government /
/// Resources). [FirebaseFirestore.instance] requires an initialized Firebase
/// app; widget/unit tests that don't initialize Firebase simply skip these
/// registrations (and provide their own mocks where needed).
void _registerFirestoreContent() {
  final FirebaseFirestore firestore;
  try {
    firestore = FirebaseFirestore.instance;
  } catch (_) {
    return;
  }

  final communityRepository = CommunityRepositoryImpl(
    CommunityFirestoreDataSource(firestore),
  );
  sl.registerSingleton<CommunityRepository>(communityRepository);
  sl.registerSingleton<GetCommunityPosts>(
    GetCommunityPosts(communityRepository),
  );
  sl.registerSingleton<GetCommunityPost>(GetCommunityPost(communityRepository));
  sl.registerSingleton<GetPostComments>(GetPostComments(communityRepository));
  sl.registerSingleton<AddPostComment>(AddPostComment(communityRepository));
  sl.registerSingleton<CreateCommunityPost>(
    CreateCommunityPost(communityRepository),
  );

  final governmentRepository = GovernmentRepositoryImpl(
    GovernmentFirestoreDataSource(firestore),
  );
  sl.registerSingleton<GovernmentRepository>(governmentRepository);
  sl.registerSingleton<GetGovProgrammes>(
    GetGovProgrammes(governmentRepository),
  );
  sl.registerSingleton<GetGovProgramme>(GetGovProgramme(governmentRepository));

  final resourcesRepository = ResourcesRepositoryImpl(
    ResourcesFirestoreDataSource(firestore),
  );
  sl.registerSingleton<ResourcesRepository>(resourcesRepository);
  sl.registerSingleton<GetTrainingPaths>(GetTrainingPaths(resourcesRepository));
  sl.registerSingleton<GetTrainingResources>(
    GetTrainingResources(resourcesRepository),
  );
  sl.registerSingleton<GetTrainingResource>(
    GetTrainingResource(resourcesRepository),
  );
}
