import 'package:flutter/material.dart';

import '../../../../core/session/current_user_controller.dart';
import '../../../../injection/injection.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../saved/presentation/pages/saved_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_catalogue_page.dart';
import 'provider_applications_page.dart';
import 'provider_dashboard_page.dart';
import 'provider_listings_page.dart';

class RoleAwareHomePage extends StatelessWidget {
  const RoleAwareHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<CurrentUserController>(),
      builder: (context, _) {
        final session = sl<CurrentUserController>();
        if (session.isPlatformAdmin) {
          return const AdminDashboardPage();
        }
        if (session.isOpportunityProvider) {
          return const ProviderDashboardPage();
        }
        return const HomePage();
      },
    );
  }
}

class RoleAwareSearchPage extends StatelessWidget {
  const RoleAwareSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<CurrentUserController>(),
      builder: (context, _) {
        final session = sl<CurrentUserController>();
        if (session.isPlatformAdmin) {
          return const AdminCataloguePage();
        }
        if (session.isOpportunityProvider) {
          return const ProviderListingsPage();
        }
        return SearchPage(initialQuery: initialQuery);
      },
    );
  }
}

class RoleAwareSavedPage extends StatelessWidget {
  const RoleAwareSavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<CurrentUserController>(),
      builder: (context, _) {
        final session = sl<CurrentUserController>();
        if (session.isPlatformAdmin) {
          // Admins use Review tab; this slot shows full catalogue status board.
          return const AdminCataloguePage(showPendingOnly: false);
        }
        if (session.isOpportunityProvider) {
          return const ProviderApplicationsPage(embedded: true);
        }
        return const SavedPage();
      },
    );
  }
}
