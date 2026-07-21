import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/get_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../features/opportunities/data/datasources/opportunity_firestore_datasource.dart';
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
      updateUserInterests: call(),
      getCurrentUser: call(),
    );
  }
}

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  final authLocal = AuthLocalDataSource(prefs);
  final authRepository = AuthRepositoryImpl(authLocal);
  sl.registerSingleton<AuthRepository>(authRepository);
  sl.registerSingleton<RegisterUser>(RegisterUser(authRepository));
  sl.registerSingleton<LoginUser>(LoginUser(authRepository));
  sl.registerSingleton<UpdateUserInterests>(
    UpdateUserInterests(authRepository),
  );
  sl.registerSingleton<GetCurrentUser>(GetCurrentUser(authRepository));
  sl.registerSingleton<CompleteOnboarding>(CompleteOnboarding(authRepository));
  sl.registerSingleton<HasCompletedOnboarding>(
    HasCompletedOnboarding(authRepository),
  );

  final FirebaseFirestore firestore = FakeFirebaseFirestore();
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
}
