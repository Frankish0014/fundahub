import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/tailor_experience_page.dart';
import '../../features/community/presentation/pages/community_home_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../../core/session/app_session.dart';
import '../../core/session/current_user_controller.dart';
import '../../core/widgets/connection_lost_page.dart';
import '../../core/widgets/generic_error_page.dart';
import '../../features/government/domain/entities/gov_programme.dart';
import '../../features/government/presentation/pages/gov_detail_page.dart';
import '../../features/government/presentation/pages/gov_programmes_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resources/domain/entities/training_resource.dart';
import '../../features/resources/presentation/pages/resource_detail_page.dart';
import '../../features/resources/presentation/pages/training_hub_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../injection/injection.dart';
import '../../features/opportunities/presentation/pages/opportunity_detail_page.dart';
import '../../features/opportunities/presentation/pages/provider_hub_page.dart';
import '../../features/opportunities/presentation/pages/create_opportunity_page.dart';
import '../../features/opportunities/presentation/pages/create_announcement_page.dart';
import '../../features/opportunities/presentation/pages/apply_opportunity_page.dart';
import '../../features/opportunities/presentation/pages/provider_applications_page.dart';
import '../../features/opportunities/presentation/pages/application_review_page.dart';
import '../../features/opportunities/presentation/pages/role_aware_shell_pages.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    // Sync redirect — never await network here or every tab switch stalls.
    redirect: (context, state) {
      final session = sl<AppSession>();
      final loc = state.matchedLocation;
      final hasOnboarded = session.hasCompletedOnboarding;
      final signedIn = session.isSignedIn;

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
          loc.startsWith('/opportunities') ||
          loc.startsWith('/provider') ||
          loc.startsWith('/announcements') ||
          loc.startsWith('/applications') ||
          loc == '/connection-lost' ||
          loc == '/offline' ||
          loc == '/error';

      if (!hasOnboarded &&
          !signedIn &&
          !isWelcome &&
          !isOnboarding &&
          !isAuthFlow) {
        return '/';
      }
      if (hasOnboarded && !signedIn && isAppFlow) {
        return '/login';
      }
      if (signedIn && (isWelcome || isOnboarding || loc == '/login')) {
        return '/home';
      }
      // Providers / admins use their own workspace — hide entrepreneur-only hubs.
      final user = sl<CurrentUserController>().user;
      if (signedIn &&
          user != null &&
          (user.isOpportunityProvider || user.isPlatformAdmin) &&
          (loc.startsWith('/resources') || loc.startsWith('/government'))) {
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
        path: '/opportunities/create',
        builder: (context, state) => const CreateOpportunityPage(),
      ),
      GoRoute(
        path: '/opportunities/:id/apply',
        builder: (context, state) =>
            ApplyOpportunityPage(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/opportunities/:id/applications',
        builder: (context, state) =>
            ProviderApplicationsPage(opportunityId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/opportunities/:id',
        builder: (context, state) =>
            OpportunityDetailPage(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/provider-hub',
        builder: (context, state) => const ProviderHubPage(),
      ),
      GoRoute(
        path: '/provider/applications',
        builder: (context, state) => const ProviderApplicationsPage(),
      ),
      GoRoute(
        path: '/applications/:id',
        builder: (context, state) =>
            ApplicationReviewPage(applicationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/announcements/create',
        builder: (context, state) => const CreateAnnouncementPage(),
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
                builder: (context, state) => const RoleAwareHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/search',
                builder: (context, state) => RoleAwareSearchPage(
                  initialQuery: state.extra is String
                      ? state.extra as String
                      : null,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/saved',
                builder: (context, state) => const RoleAwareSavedPage(),
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
