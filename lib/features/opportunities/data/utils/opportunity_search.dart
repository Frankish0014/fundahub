import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/opportunity.dart';

abstract final class OpportunitySearch {
  /// Returns true when [opportunity] matches [rawQuery] (title, org, type, tags).
  static bool matches(Opportunity opportunity, String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    // Exact category label from home tiles (e.g. "Grants").
    final categoryType = typeForCategory(query);
    if (categoryType != null && opportunity.type == categoryType) {
      return true;
    }

    // Type synonym typed as the whole query (e.g. "grant", "scholarships").
    for (final type in OpportunityType.values) {
      if (searchTermsForType(type).contains(query) &&
          opportunity.type == type) {
        return true;
      }
    }

    final terms = <String>{
      query,
      ...query.split(RegExp(r'\s+')).where((t) => t.length > 1),
    };

    final fields = <String>[
      opportunity.title,
      opportunity.organization,
      opportunity.typeLabel,
      opportunity.type.name,
      opportunity.location,
      opportunity.description,
      ...opportunity.tags,
    ];

    final haystack = fields.join(' ').toLowerCase();
    return terms.any(haystack.contains);
  }

  /// Applies text query plus optional type / open-only filters.
  static List<Opportunity> filter({
    required List<Opportunity> opportunities,
    String query = '',
    Set<OpportunityType> types = const {},
    bool openOnly = false,
  }) {
    return opportunities.where((o) {
      if (types.isNotEmpty && !types.contains(o.type)) return false;
      if (openOnly && !o.isOpen) return false;
      return matches(o, query);
    }).toList();
  }

  static OpportunityType? typeForCategory(String raw) {
    final value = raw.trim().toLowerCase();
    for (final category in AppConstants.categories) {
      if (category.toLowerCase() == value) {
        return typeForCategoryLabel(category);
      }
    }
    return null;
  }

  static OpportunityType? typeForCategoryLabel(String category) {
    switch (category) {
      case 'Grants':
        return OpportunityType.grant;
      case 'Accelerators':
        return OpportunityType.accelerator;
      case 'Scholarships':
        return OpportunityType.scholarship;
      case 'Competitions':
        return OpportunityType.competition;
      default:
        return null;
    }
  }

  static String categoryLabelForType(OpportunityType type) {
    switch (type) {
      case OpportunityType.grant:
        return 'Grants';
      case OpportunityType.accelerator:
        return 'Accelerators';
      case OpportunityType.scholarship:
        return 'Scholarships';
      case OpportunityType.competition:
        return 'Competitions';
    }
  }

  static List<String> searchTermsForType(OpportunityType type) {
    switch (type) {
      case OpportunityType.grant:
        return const ['grant', 'grants'];
      case OpportunityType.accelerator:
        return const ['accelerator', 'accelerators'];
      case OpportunityType.scholarship:
        return const ['scholarship', 'scholarships'];
      case OpportunityType.competition:
        return const ['competition', 'competitions'];
    }
  }

  static List<String> defaultTagsForType(OpportunityType type) {
    return [categoryLabelForType(type), ...searchTermsForType(type)];
  }
}
