// Import only FirebaseFirestore: cloud_firestore also exports a `Type` class
// (Pipeline API) that would otherwise shadow dart:core's Type used by the
// service locator's `Map<Type, Object>`.
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../features/opportunities/data/datasources/opportunity_remote_datasource.dart';
import '../features/opportunities/data/repositories/opportunity_repository_impl.dart';
import '../features/opportunities/domain/repositories/opportunity_repository.dart';
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

Future<void> initDependencies({AuthRepository? authRepositoryOverride}) async {
  final prefs = await SharedPreferences.getInstance();

  late final AuthRepository authRepository;
  if (authRepositoryOverride != null) {
    authRepository = authRepositoryOverride;
  } else {
    final googleSignIn = GoogleSignIn.instance;
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    await googleSignIn.initialize(
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );

    final authLocal = AuthLocalDataSource(prefs);
    final authRemote = FirebaseAuthRemoteDataSource(
      FirebaseAuth.instance,
      googleSignIn,
    );

    authRepository = AuthRepositoryImpl(authRemote, authLocal);
  }
  sl.registerSingleton<AuthRepository>(authRepository);
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

  final opportunityDataSource = OpportunityMockDataSource();
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
  sl.registerSingleton<ToggleSavedOpportunity>(
    ToggleSavedOpportunity(opportunityRepository),
  );

  final notificationDataSource = NotificationMockDataSource();
  final notificationRepository = NotificationRepositoryImpl(
    notificationDataSource,
  );
  sl.registerSingleton<NotificationRepository>(notificationRepository);
  sl.registerSingleton<GetNotifications>(
    GetNotifications(notificationRepository),
  );

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
