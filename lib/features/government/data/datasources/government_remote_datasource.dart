import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/gov_programme.dart';

abstract class GovernmentRemoteDataSource {
  Future<List<GovProgramme>> fetchProgrammes({String? category});
  Future<GovProgramme?> fetchProgramme(String id);
}

/// Firestore-backed government programmes datasource.
///
/// Layout: government_programmes/{programmeId}
class GovernmentFirestoreDataSource implements GovernmentRemoteDataSource {
  GovernmentFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  static const _collection = 'government_programmes';

  CollectionReference<Map<String, dynamic>> get _programmes =>
      _firestore.collection(_collection);

  @override
  Future<List<GovProgramme>> fetchProgrammes({String? category}) async {
    await _ensureSeeded();

    final snap =
        category == null ||
            category.trim().isEmpty ||
            category == 'All Programs'
        ? await _programmes.get()
        : await _programmes.where('category', isEqualTo: category).get();

    // Preserve seed ordering without requiring a composite index.
    final docs = snap.docs.toList()
      ..sort((a, b) {
        final ai = (a.data()['sortIndex'] as num?)?.toInt() ?? 0;
        final bi = (b.data()['sortIndex'] as num?)?.toInt() ?? 0;
        return ai.compareTo(bi);
      });
    return docs.map(_fromDoc).toList();
  }

  @override
  Future<GovProgramme?> fetchProgramme(String id) async {
    final doc = await _programmes.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  GovProgramme _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return GovProgramme(
      id: doc.id,
      title: d['title'] as String? ?? '',
      issuer: d['issuer'] as String? ?? '',
      category: d['category'] as String? ?? 'All Programs',
      amountCaption: d['amountCaption'] as String? ?? 'GRANT AMOUNT',
      amount: d['amount'] as String? ?? '',
      deadlineLabel: d['deadlineLabel'] as String? ?? '',
      closed: d['closed'] as bool? ?? false,
      verified: d['verified'] as bool? ?? true,
      tags: (d['tags'] as List?)?.cast<String>() ?? const [],
      deadlineDate: d['deadlineDate'] as String? ?? '',
      organizedBy: d['organizedBy'] as String? ?? '',
      eligibility: (d['eligibility'] as List?)?.cast<String>() ?? const [],
      steps: _stepsFrom(d['steps']),
      links: (d['links'] as List?)?.cast<String>() ?? const [],
      statusLabel: d['statusLabel'] as String? ?? '',
      daysLeftLabel: d['daysLeftLabel'] as String? ?? '',
      quote: d['quote'] as String? ?? '',
    );
  }

  List<GovStep> _stepsFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      return GovStep(
        number: (m['number'] as num?)?.toInt() ?? 0,
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        active: m['active'] as bool? ?? false,
      );
    }).toList();
  }

  // --- seeding ---------------------------------------------------------------

  Future<void> _ensureSeeded() async {
    if (_seedChecked) return;
    final existing = await _programmes.limit(1).get();
    _seedChecked = true;
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final p in _seedData) {
      batch.set(_programmes.doc(), p);
    }
    await batch.commit();
  }

  static final List<Map<String, dynamic>> _seedData = [
    {
      'sortIndex': 0,
      'title': 'National Youth Entrepreneurship Fund',
      'issuer': 'Ministry of Trade and Industrialization',
      'category': 'Tech Startups',
      'amountCaption': 'GRANT AMOUNT',
      'amount': '₦5,000,000',
      'deadlineLabel': '14 Days Left',
      'closed': false,
      'verified': true,
      'tags': ['Grant', 'Tech', 'SME'],
      'deadlineDate': 'Deadline: Oct 24, 2024',
      'organizedBy': 'Ministry of Trade and Industrialization',
      'eligibility': [
        'Registered SMEs with at least 3 years of audited financials.',
        'Minimum 70% local ownership and local raw material sourcing.',
        'Clear track record of an export-ready product or service.',
        'Valid business registration certificate.',
      ],
      'steps': [
        {
          'number': 1,
          'title': 'Online Registration',
          'body':
              'Create an account on the federal portal and upload CAC documents.',
          'active': true,
        },
        {
          'number': 2,
          'title': 'Proposal Submission',
          'body':
              'Submit a detailed business plan including value-chain impact analysis.',
          'active': true,
        },
        {
          'number': 3,
          'title': 'Technical Review',
          'body':
              'Evaluation by the inter-ministerial grant committee (4-6 weeks).',
          'active': false,
        },
      ],
      'links': ['Official Portal', 'Guidelines PDF', 'FAQ & Support'],
      'statusLabel': 'Open',
      'daysLeftLabel': '14 DAYS LEFT',
      'quote': 'Empowering the next generation of African entrepreneurs.',
    },
    {
      'sortIndex': 1,
      'title': 'Agribusiness Productivity Enhancement Scheme',
      'issuer': 'Ministry of Agriculture',
      'category': 'Agriculture',
      'amountCaption': 'FUNDING CAP',
      'amount': '₦2,500,000',
      'deadlineLabel': 'Closed',
      'closed': true,
      'verified': true,
      'tags': ['Loan', 'Agri'],
      'deadlineDate': 'Deadline: Passed',
      'organizedBy': 'Federal Ministry of Agriculture & Rural Development',
      'eligibility': [
        'Registered agribusinesses with a valid operating licence.',
        'Demonstrated capacity for smallholder outgrower schemes.',
        'Evidence of local raw material sourcing.',
      ],
      'steps': [
        {
          'number': 1,
          'title': 'Eligibility Check',
          'body': 'Confirm registration and sector alignment.',
          'active': false,
        },
        {
          'number': 2,
          'title': 'Application',
          'body': 'Submit financials and a productivity improvement plan.',
          'active': false,
        },
      ],
      'links': ['Official Portal', 'Guidelines PDF'],
      'statusLabel': 'Closed',
      'daysLeftLabel': 'CLOSED',
      'quote': 'Strengthening food security through productive agribusiness.',
    },
    {
      'sortIndex': 2,
      'title': 'Digital Innovation Support Window',
      'issuer': 'Rwanda Development Board',
      'category': 'Tech Startups',
      'amountCaption': 'FUNDING UP TO',
      'amount': '₦8,000,000',
      'deadlineLabel': '27 Days Left',
      'closed': false,
      'verified': true,
      'tags': ['Grant', 'Tech'],
      'deadlineDate': 'Deadline: Nov 06, 2024',
      'organizedBy': 'Rwanda Development Board',
      'eligibility': [
        'Early-stage digital startups incorporated in the region.',
        'A working prototype or minimum viable product.',
        'A team of at least two full-time founders.',
      ],
      'steps': [
        {
          'number': 1,
          'title': 'Online Registration',
          'body': 'Create a profile and submit company details.',
          'active': true,
        },
        {
          'number': 2,
          'title': 'Pitch Submission',
          'body': 'Upload a pitch deck and a short product demo.',
          'active': true,
        },
        {
          'number': 3,
          'title': 'Selection',
          'body': 'Shortlisted teams are invited to a panel review.',
          'active': false,
        },
      ],
      'links': ['Official Portal', 'Guidelines PDF', 'FAQ & Support'],
      'statusLabel': 'Open',
      'daysLeftLabel': '27 DAYS LEFT',
      'quote': 'Backing the builders of Africa\'s digital economy.',
    },
  ];
}
