import 'package:go_router/go_router.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/tailor_experience_page.dart';
import '../../features/community/presentation/pages/community_home_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../../core/widgets/connection_lost_page.dart';
import '../../core/widgets/generic_error_page.dart';
import '../../features/government/domain/entities/gov_programme.dart';
import '../../features/government/presentation/pages/gov_detail_page.dart';
import '../../features/government/presentation/pages/gov_programmes_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resources/domain/entities/training_resource.dart';
import '../../features/resources/presentation/pages/resource_detail_page.dart';
import '../../features/resources/presentation/pages/training_hub_page.dart';
import '../../features/saved/presentation/pages/saved_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../injection/injection.dart';
import '../../features/opportunities/presentation/pages/opportunity_detail_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final hasOnboarded = await sl<HasCompletedOnboarding>()();
      final user = await sl<GetCurrentUser>()();

      final isWelcome = loc == '/';
      final isOnboarding = loc == '/onboarding';
      final isAuthFlow =
          loc == '/create-account' || loc == '/login' || loc == '/tailor';
      final isAppFlow =
          loc.startsWith('/home') ||
          loc.startsWith('/resources') ||
          loc.startsWith('/community') ||
          loc.startsWith('/government') ||
          loc.startsWith('/settings') ||
          loc.startsWith('/edit-profile') ||
          loc.startsWith('/notification-settings') ||
          loc == '/connection-lost' ||
          loc == '/offline' ||
          loc == '/error';

      if (!hasOnboarded &&
          user == null &&
          !isWelcome &&
          !isOnboarding &&
          !isAuthFlow) {
        return '/';
      }
      if (hasOnboarded && user == null && isAppFlow) {
        return '/login';
      }
      if (user != null && (isWelcome || isOnboarding || loc == '/login')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/tailor',
        builder: (context, state) => const TailorExperiencePage(),
      ),
      GoRoute(
        path: '/resources',
        builder: (context, state) => const TrainingHubPage(),
      ),
      GoRoute(
        path: '/resources/detail',
        builder: (context, state) =>
            ResourceDetailPage(resource: state.extra as TrainingResource?),
      ),
      GoRoute(
        path: '/opportunities/:id',
        builder: (context, state) => OpportunityDetailPage(
          opportunityId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityHomePage(),
      ),
      GoRoute(
        path: '/community/post',
        builder: (context, state) =>
            PostDetailPage(postId: state.extra as String?),
      ),
      GoRoute(
        path: '/government',
        builder: (context, state) => const GovProgrammesPage(),
      ),
      GoRoute(
        path: '/government/detail',
        builder: (context, state) =>
            GovDetailPage(programme: state.extra as GovProgramme?),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/connection-lost',
        builder: (context, state) => const ConnectionLostPage(),
      ),
      GoRoute(
        path: '/offline',
        builder: (context, state) => const ConnectionLostPage(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const GenericErrorPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/saved',
                builder: (context, state) => const SavedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/alerts',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
