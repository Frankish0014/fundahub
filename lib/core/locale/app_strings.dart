import 'package:flutter/material.dart';

/// In-app UI strings for English, French, and Kinyarwanda.
class AppStrings {
  AppStrings(this.languageCode);

  final String languageCode;

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(
      scope != null,
      'AppStringsScope not found. Wrap the app with AppStringsScope.',
    );
    return scope!.strings;
  }

  String _t(String en, String fr, String rw) {
    switch (languageCode) {
      case 'fr':
        return fr;
      case 'rw':
        return rw;
      case 'en':
      default:
        return en;
    }
  }

  // —— Brand / common ——
  String get appName => 'FundaHub';
  String get getStarted => _t('Get Started', 'Commencer', 'Tangira');
  String get logIn => _t('Log In', 'Connexion', 'Injira');
  String get logout => _t('Logout', 'Déconnexion', 'Sohoka');
  String get save => _t('Save', 'Enregistrer', 'Bika');
  String get cancel => _t('Cancel', 'Annuler', 'Hagarika');
  String get retry => _t('Try Again', 'Réessayer', 'Ongera ugerageze');
  String get seeAll => _t('See all', 'Voir tout', 'Reba byose');
  String get orDivider => _t('OR', 'OU', 'CYANGWA');
  String get loading => _t('Please wait...', 'Veuillez patienter...', 'Tegereza...');

  // —— Navigation ——
  String get navHome => _t('Home', 'Accueil', 'Ahabanza');
  String get navSearch => _t('Search', 'Recherche', 'Shakisha');
  String get navSaved => _t('Saved', 'Enregistrés', 'Byabitswe');
  String get navAlerts =>
      _t('Notifications', 'Notifications', 'Amatangazo');
  String get navProfile => _t('Profile', 'Profil', 'Umwirondoro');
  String get navDashboard => _t('Dashboard', 'Tableau de bord', 'Ikibaho');
  String get navListings => _t('Listings', 'Annonces', 'Amahirwe');
  String get navInbox => _t('Inbox', 'Boîte', 'Ubusabe');
  String get navReview => _t('Review', 'Examen', 'Suzuma');
  String get navCatalogue => _t('Catalogue', 'Catalogue', 'Urutonde');
  String get navStatus => _t('Status', 'Statut', 'Imiterere');

  // —— Auth ——
  String get welcomeBack =>
      _t('Welcome back to FundaHub.', 'Bon retour sur FundaHub.', 'Murakaza neza kuri FundaHub.');
  String get emailAddress =>
      _t('Email Address', 'Adresse e-mail', 'Imeyili');
  String get password => _t('Password', 'Mot de passe', 'Ijambo ry\'ibanga');
  String get forgotPassword =>
      _t('Forgot password?', 'Mot de passe oublié ?', 'Wibagiwe ijambo ry\'ibanga?');
  String get continueWithGoogle =>
      _t('Continue with Google', 'Continuer avec Google', 'Komeza na Google');
  String get noAccount =>
      _t("Don't have an account? Create one", "Pas de compte ? Créer un compte", 'Nta konti? Kora imwe');
  String get createAccount =>
      _t('Create Account', 'Créer un compte', 'Kora konti');

  // —— Home ——
  String welcomeBackName(String name) =>
      _t('Welcome back,', 'Bon retour,', 'Murakaza neza,');
  String get searchHint =>
      _t('Search grants, accelerators...', 'Rechercher subventions, accélérateurs...', 'Shakisha inkunga, accelerators...');
  String get recommendedForYou =>
      _t('Recommended for you', 'Recommandé pour vous', 'Byasabwa kuri wowe');
  String get categories => _t('Categories', 'Catégories', 'Ibyiciro');
  String get grants => _t('Grants', 'Subventions', 'Inkunga');
  String get accelerators =>
      _t('Accelerators', 'Accélérateurs', 'Accelerators');
  String get scholarships =>
      _t('Scholarships', 'Bourses', 'Amafaranga y\'ishuri');
  String get competitions =>
      _t('Competitions', 'Concours', 'Amarushanwa');

  String categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'grants':
        return grants;
      case 'accelerators':
        return accelerators;
      case 'scholarships':
        return scholarships;
      case 'competitions':
        return competitions;
      default:
        return category;
    }
  }

  // —— Search / saved / alerts ——
  String get searchOpportunities =>
      _t('Search opportunities...', 'Rechercher des opportunités...', 'Shakisha amahirwe...');
  String get notifications =>
      _t('Notifications', 'Notifications', 'Amatangazo');
  String get noNotifications =>
      _t('No alerts yet', 'Aucune alertes pour le moment', 'Nta matangazo');

  // —— Profile / settings ——
  String get profile => _t('Profile', 'Profil', 'Umwirondoro');
  String get settings => _t('Settings', 'Paramètres', 'Igenamiterere');
  String get editProfile =>
      _t('Edit Profile', 'Modifier le profil', 'Hindura umwirondoro');
  String get accountSecurity =>
      _t('ACCOUNT & SECURITY', 'COMPTE & SÉCURITÉ', 'KONTI & UMUTEKANO');
  String get preferences =>
      _t('PREFERENCES', 'PRÉFÉRENCES', 'IBYIFUZO');
  String get support => _t('SUPPORT', 'ASSISTANCE', 'UBUFASHA');
  String get account => _t('Account', 'Compte', 'Konti');
  String get notificationSettings =>
      _t('Notification Settings', 'Paramètres de notification', 'Igenamiterere ry\'amatangazo');
  String get privacy => _t('Privacy', 'Confidentialité', 'Ibanga');
  String get language => _t('Language', 'Langue', 'Ururimi');
  String get theme => _t('Theme', 'Thème', 'Insanganyamatsiko');
  String get textSize => _t('Text size', 'Taille du texte', 'Ingano y\'inyandiko');
  String get compactMode =>
      _t('Compact mode', 'Mode compact', 'Uburyo bwa compact');
  String get compactModeSubtitle =>
      _t('Tighter spacing across the app', 'Espacement réduit dans l\'application', 'Umwanya muto mu porogaramu');
  String get helpCenter => _t('Help Center', 'Centre d\'aide', 'Ikigo cy\'ubufasha');
  String get termsOfService =>
      _t('Terms of Service', 'Conditions d\'utilisation', 'Amategeko yo gukoresha');
  String get myInterests =>
      _t('My Interests', 'Mes centres d\'intérêt', 'Ibyanjye nkunda');
  String get changePhoto =>
      _t('Change Photo', 'Changer la photo', 'Hindura ifoto');
  String get fullName => _t('Full Name', 'Nom complet', 'Amazina yuzuye');
  String get role => _t('Role', 'Rôle', 'Uruhare');
  String get bio => _t('Bio', 'Bio', 'Ibyerekeye');
  String get saveChanges =>
      _t('Save Changes', 'Enregistrer', 'Bika impinduka');
  String get loggingOut =>
      _t('Logging out...', 'Déconnexion...', 'Urimo gusohoka...');

  String get themeSystem => _t('System', 'Système', 'Sisitemu');
  String get themeLight => _t('Light', 'Clair', 'Urumuri');
  String get themeDark => _t('Dark', 'Sombre', 'Umwijima');
  String get textSmall => _t('Small', 'Petit', 'Gito');
  String get textDefault => _t('Default', 'Par défaut', 'Bisanzwe');
  String get textLarge => _t('Large', 'Grand', 'Kinini');

  String languageSetTo(String name) => _t(
        'Language set to $name',
        'Langue définie : $name',
        'Ururimi rushyizwe kuri $name',
      );

  // —— Opportunities ——
  String get opportunity =>
      _t('Opportunity', 'Opportunité', 'Amahirwe');
  String get applyForOpportunity =>
      _t('Apply for this opportunity', 'Postuler à cette opportunité', 'Saba aya mahirwe');
  String get saveForLater =>
      _t('Save for later', 'Enregistrer pour plus tard', 'Bika nyuma');
  String get unsave => _t('Unsave', 'Retirer', 'Kuraho');
  String get amount => _t('Amount', 'Montant', 'Amafaranga');
  String get verified => _t('VERIFIED', 'VÉRIFIÉ', 'BYEMEJWE');
  String daysLeft(int n) => _t(
        '$n days left',
        '$n jours restants',
        'Iminsi $n isigaye',
      );
  String get providerHub =>
      _t('Provider Hub', 'Espace partenaire', 'Ikigo cy\'abatanga');
  String get createOpportunity =>
      _t('Create Opportunity', 'Créer une opportunité', 'Kora amahirwe');
  String get applicationsInbox =>
      _t('Applications inbox', 'Boîte de candidatures', 'Ubusabe');
  String get madeForRwanda =>
      _t("Made for Rwanda's Entrepreneurs", 'Pour les entrepreneurs du Rwanda', 'Byakorewe abacuruzi b\'u Rwanda');
  String get trainingResources =>
      _t('Training & Resources', 'Formation & Ressources', 'Amahugurwa & Ibikoresho');
  String get community => _t('Community', 'Communauté', 'Umuryango');
  String get governmentProgrammes =>
      _t('Government Programmes', 'Programmes gouvernementaux', 'Gahunda za Leta');
  String get reviewApplications =>
      _t('Review applications', 'Examiner les candidatures', 'Suzuma ubusabe');
  String get signInToApply =>
      _t('Sign in to apply', 'Connectez-vous pour postuler', 'Injira kugira ngo usabe');
  String get saveLabel => _t('Save', 'Enregistrer', 'Bika');
}

/// Provides [AppStrings] down the tree and rebuilds when the language changes.
class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      oldWidget.strings.languageCode != strings.languageCode;
}
