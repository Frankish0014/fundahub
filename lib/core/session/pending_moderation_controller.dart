import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/opportunities/domain/usecases/opportunity_usecases.dart';
import 'current_user_controller.dart';

/// Tracks pending opportunity + announcement reviews for the Super Admin.
/// Drives notification dots on Status and Alerts in the bottom nav.
class PendingModerationController extends ChangeNotifier {
  PendingModerationController({
    required CurrentUserController currentUser,
    required GetPendingOpportunities getPendingOpportunities,
    required GetPendingAnnouncements getPendingAnnouncements,
  }) : _currentUser = currentUser,
       _getPendingOpportunities = getPendingOpportunities,
       _getPendingAnnouncements = getPendingAnnouncements {
    _currentUser.addListener(_onUserChanged);
  }

  final CurrentUserController _currentUser;
  final GetPendingOpportunities _getPendingOpportunities;
  final GetPendingAnnouncements _getPendingAnnouncements;
  Timer? _pollTimer;

  int pendingOpportunities = 0;
  int pendingAnnouncements = 0;
  bool _started = false;
  bool _refreshing = false;

  int get totalPending => pendingOpportunities + pendingAnnouncements;

  bool get hasPendingReviews => totalPending > 0;

  /// Dot on Status (pending listings queue).
  bool get showStatusBadge => pendingOpportunities > 0;

  /// Dot on Alerts (pending announcements, or any review work waiting).
  bool get showAlertsBadge =>
      pendingAnnouncements > 0 || pendingOpportunities > 0;

  /// Call after DI is fully wired.
  void start() {
    if (_started) return;
    _started = true;
    _onUserChanged();
  }

  void _onUserChanged() {
    if (!_started) return;
    if (_currentUser.isPlatformAdmin) {
      unawaited(refresh());
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 25),
        (_) => unawaited(refresh()),
      );
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
      if (pendingOpportunities != 0 || pendingAnnouncements != 0) {
        pendingOpportunities = 0;
        pendingAnnouncements = 0;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    if (!_currentUser.isPlatformAdmin || _refreshing) return;
    _refreshing = true;
    try {
      final opportunities = await _getPendingOpportunities();
      final announcements = await _getPendingAnnouncements();
      pendingOpportunities = opportunities.length;
      pendingAnnouncements = announcements.length;
      // Always notify so Catalogue / Status / Notifications refresh after reviews.
      notifyListeners();
    } catch (error) {
      debugPrint('Pending moderation refresh failed: $error');
    } finally {
      _refreshing = false;
    }
  }

  /// Force UI listeners to reload (e.g. right after Approve / Reject).
  void bump() => notifyListeners();

  @override
  void dispose() {
    _pollTimer?.cancel();
    _currentUser.removeListener(_onUserChanged);
    super.dispose();
  }
}
