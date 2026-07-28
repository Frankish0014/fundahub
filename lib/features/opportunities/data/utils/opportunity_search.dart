import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/opportunity.dart';

abstract final class OpportunitySearch {
  static bool matches(Opportunity opportunity, String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final categoryType = typeForCategory(query);
    if (categoryType != null && opportunity.type == categoryType) {
      return true;
    }

    final terms = <String>{
      query,
      ...query.split(RegExp(r'\s+')).where((t) => t.length > 1),
      ...searchTermsForType(opportunity.type),
    };

    final fields = <String>[
      opportunity.title,
      opportunity.organization,
      opportunity.typeLabel,
      opportunity.type.name,
      ...opportunity.tags,
    ];

    final haystack = fields.join(' ').toLowerCase();
    return terms.any(haystack.contains);
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
