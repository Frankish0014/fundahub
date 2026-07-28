import 'package:flutter/foundation.dart';

import '../../features/auth/domain/entities/user_profile.dart';

/// Live signed-in profile shared across tabs (Home, Profile, shell nav).
class CurrentUserController extends ChangeNotifier {
  UserProfile? _user;

  UserProfile? get user => _user;

  bool get isSignedIn => _user != null;

  bool get isOpportunityProvider => _user?.isOpportunityProvider ?? false;

  bool get isPlatformAdmin => _user?.isPlatformAdmin ?? false;

  void apply(UserProfile? user) {
    if (_user == user) return;
    _user = user;
    notifyListeners();
  }

  void clear() => apply(null);
}
