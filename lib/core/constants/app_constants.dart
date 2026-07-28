abstract final class AppConstants {
  static const String appName = 'FundaHub';
  static const String tagline =
      'One trusted place to discover, verify, and never miss funding.';

  /// End-user entrepreneur roles (seek opportunities).
  static const List<String> entrepreneurRoles = [
    'Student Entrepreneur',
    'Aspiring Founder',
    'SME Owner',
  ];

  /// Organisations that publish opportunities (need admin approval).
  static const List<String> providerRoles = [
    'NGO / Organisation',
    'Government Partner',
  ];

  /// Platform Super Admin — sole role that verifies provider content.
  static const String platformAdminRole = 'Platform Admin';

  /// Official FundaHub Super Admin (seeded into Firebase Auth + Firestore).
  /// Use this for admin testing, marking, and production ops access.
  static const String superAdminEmail = 'admin@fundahub.app';
  static const String superAdminPassword = 'FundaHub@Admin2026!';
  static const String superAdminName = 'FundaHub Super Admin';

  /// Older provisional passwords — migrated automatically on seed if found.
  static const List<String> superAdminLegacyPasswords = ['Admin123!'];

  /// Roles offered on Create Account (Super Admin is seeded, not self-served).
  static const List<String> selectableAccountRoles = [
    ...entrepreneurRoles,
    ...providerRoles,
  ];

  static const List<String> allAccountRoles = [
    ...selectableAccountRoles,
    platformAdminRole,
  ];

  static bool isOpportunityProvider(String role) =>
      providerRoles.contains(role);

  static bool isPlatformAdmin(String role) => role == platformAdminRole;

  static const List<String> interestTags = [
    'Seed Funding',
    'Grants',
    'Tech',
    'Agriculture',
    'Women-led',
    'Social Impact',
    'Under 25',
    'Scale-up',
  ];

  static const List<String> categories = [
    'Grants',
    'Accelerators',
    'Scholarships',
    'Competitions',
  ];

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'Français',
    'rw': 'Kinyarwanda',
  };
}
