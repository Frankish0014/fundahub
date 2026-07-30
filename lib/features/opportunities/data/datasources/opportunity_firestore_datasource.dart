import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/opportunity.dart';

class OpportunityFirestoreDataSource {
  OpportunityFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('opportunities');

  CollectionReference<Map<String, dynamic>> _saved(String userId) =>
      _firestore.collection('users').doc(userId).collection('saved');

  Future<List<Opportunity>> fetchAll() async {
    await _ensureSeeded();
    final snapshot = await _collection.get();
    final items = snapshot.docs.map(_fromDoc).toList();
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  }

  Future<List<Opportunity>> fetchByCreator(String userId) async {
    await _ensureSeeded();
    final query = _firestore
        .collection('opportunities')
        .where('createdBy', isEqualTo: userId);
    final snapshot = await query.get();
    final items = snapshot.docs.map(_fromDoc).toList();
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  }

  Future<Opportunity?> fetchById(String id) async {
    await _ensureSeeded();
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<Set<String>> fetchSavedIds(String userId) async {
    final snap = await _saved(userId).get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> setSaved({
    required String userId,
    required String opportunityId,
    required bool saved,
  }) async {
    final ref = _saved(userId).doc(opportunityId);
    if (saved) {
      await ref.set({
        'opportunityId': opportunityId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  Future<void> create(Opportunity opportunity) async {
    await _collection.doc(opportunity.id).set(_toMap(opportunity));
  }

  Future<void> update(Opportunity opportunity) async {
    final map = _toMap(opportunity)..remove('createdAt');
    // Merge so approval status always sticks even if some fields are omitted.
    await _collection.doc(opportunity.id).set(map, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) return;
    final existing = await _collection.limit(1).get();
    _seedChecked = true;
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final item in _seedData) {
      final id = item['id'] as String;
      final map = Map<String, dynamic>.from(item)..remove('id');
      batch.set(_collection.doc(id), map);
    }
    await batch.commit();
  }

  Opportunity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    }
    final reviewedAtRaw = data['reviewedAt'];
    DateTime? reviewedAt;
    if (reviewedAtRaw is Timestamp) {
      reviewedAt = reviewedAtRaw.toDate();
    }

    final statusName = data['moderationStatus'] as String?;
    final legacyVerified = data['isVerified'] as bool? ?? false;
    final moderationStatus = statusName == null
        ? (legacyVerified
              ? ModerationStatus.approved
              : ModerationStatus.pending)
        : ModerationStatus.values.firstWhere(
            (s) => s.name == statusName,
            orElse: () => ModerationStatus.pending,
          );
    final isVerified =
        moderationStatus == ModerationStatus.approved &&
        (data['isVerified'] as bool? ??
            moderationStatus == ModerationStatus.approved);

    return Opportunity(
      id: doc.id,
      title: data['title'] as String? ?? '',
      organization: data['organization'] as String? ?? '',
      type: OpportunityType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => OpportunityType.grant,
      ),
      amountLabel: data['amountLabel'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? const []),
      daysLeft: (data['daysLeft'] as num?)?.toInt() ?? 0,
      isVerified: isVerified || moderationStatus == ModerationStatus.approved,
      moderationStatus: moderationStatus,
      moderationNote: data['moderationNote'] as String? ?? '',
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: reviewedAt,
      isSaved: false,
      createdBy: data['createdBy'] as String?,
      createdAt: createdAt,
      description: data['description'] as String? ?? '',
      eligibilityCriteria: data['eligibilityCriteria'] as String? ?? '',
      requiredDocuments: List<String>.from(
        data['requiredDocuments'] as List? ?? const [],
      ),
      location: data['location'] as String? ?? '',
      contactEmail: data['contactEmail'] as String? ?? '',
      applicationInstructions: data['applicationInstructions'] as String? ?? '',
      targetBeneficiaries: data['targetBeneficiaries'] as String? ?? '',
    );
  }

  Map<String, dynamic> _toMap(Opportunity o) {
    return {
      'title': o.title,
      'organization': o.organization,
      'type': o.type.name,
      'amountLabel': o.amountLabel,
      'tags': o.tags,
      'daysLeft': o.daysLeft,
      'isVerified': o.isVerified,
      'moderationStatus': o.moderationStatus.name,
      'moderationNote': o.moderationNote,
      if (o.reviewedBy != null) 'reviewedBy': o.reviewedBy,
      if (o.reviewedAt != null) 'reviewedAt': Timestamp.fromDate(o.reviewedAt!),
      if (o.createdBy != null) 'createdBy': o.createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'description': o.description,
      'eligibilityCriteria': o.eligibilityCriteria,
      'requiredDocuments': o.requiredDocuments,
      'location': o.location,
      'contactEmail': o.contactEmail,
      'applicationInstructions': o.applicationInstructions,
      'targetBeneficiaries': o.targetBeneficiaries,
    };
  }

  static final List<Map<String, dynamic>> _seedData = [
    {
      'id': 'tef-seed',
      'title': 'Tony Elumelu Foundation Entrepreneurship Programme',
      'organization': 'Tony Elumelu Foundation',
      'type': OpportunityType.grant.name,
      'amountLabel': 'Up to \$5,000',
      'tags': ['Seed Funding', 'Grants', 'Under 25', 'Africa'],
      'daysLeft': 21,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Seed funding, mentoring, and networking for African entrepreneurs launching or scaling early-stage businesses.',
      'eligibilityCriteria':
          'African citizen or legal resident; business idea or early-stage venture; aged 18–35 preferred; able to commit to training.',
      'requiredDocuments': [
        'National ID / passport',
        'Business pitch deck',
        'Bank details',
      ],
      'location': 'Africa (pan-African)',
      'contactEmail': 'applications@tonyelumelufoundation.org',
      'applicationInstructions':
          'Complete the in-app application. Shortlisted founders attend virtual interviews.',
      'targetBeneficiaries': 'Early-stage African entrepreneurs',
    },
    {
      'id': 'google-startup',
      'title': 'Google for Startups Black Founders Fund',
      'organization': 'Google for Startups',
      'type': OpportunityType.accelerator.name,
      'amountLabel': 'Equity-free funding',
      'tags': ['Tech', 'Accelerators', 'Scale-up'],
      'daysLeft': 34,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Equity-free capital and Google mentorship for Black-founded tech startups.',
      'eligibilityCriteria':
          'At least one Black founder with significant ownership; tech product in market or MVP; registered company.',
      'requiredDocuments': [
        'Company registration',
        'Cap table summary',
        'Product demo link',
      ],
      'location': 'Selected African markets',
      'contactEmail': 'startups@google.com',
      'applicationInstructions':
          'Apply via FundaHub. Provide traction metrics and founder bios.',
      'targetBeneficiaries': 'Black-founded tech startups',
    },
    {
      'id': 'anzisha',
      'title': 'Anzisha Prize',
      'organization': 'African Leadership Academy',
      'type': OpportunityType.competition.name,
      'amountLabel': 'Up to \$25,000',
      'tags': ['Under 25', 'Student Entrepreneur', 'Competitions'],
      'daysLeft': 45,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Prize and recognition for young African entrepreneurs creating jobs and impact.',
      'eligibilityCriteria':
          'Aged 15–22; running a venture that creates jobs or community impact in Africa.',
      'requiredDocuments': [
        'Birth certificate / ID',
        'Venture overview',
        'Impact evidence',
      ],
      'location': 'Africa',
      'contactEmail': 'info@anzishaprize.org',
      'applicationInstructions':
          'Submit venture story and impact numbers through FundaHub.',
      'targetBeneficiaries': 'Young entrepreneurs under 25',
    },
    {
      'id': 'mastercard-scholars',
      'title': 'Mastercard Foundation Scholars Program',
      'organization': 'Mastercard Foundation',
      'type': OpportunityType.scholarship.name,
      'amountLabel': 'Full scholarship',
      'tags': ['Scholarships', 'Education', 'Under 25'],
      'daysLeft': 60,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Scholarships for academically talented young people from economically disadvantaged backgrounds.',
      'eligibilityCriteria':
          'Strong academic record; demonstrated financial need; leadership and community service.',
      'requiredDocuments': [
        'Academic transcripts',
        'Recommendation letters',
        'Personal statement',
      ],
      'location': 'Partner universities (Africa)',
      'contactEmail': 'scholars@mastercardfdn.org',
      'applicationInstructions': 'Apply with academic and leadership evidence.',
      'targetBeneficiaries': 'Students seeking tertiary education support',
    },
    {
      'id': 'rdb-sme',
      'title': 'RDB SME Growth Facility',
      'organization': 'Rwanda Development Board',
      'type': OpportunityType.grant.name,
      'amountLabel': 'Up to RWF 50M',
      'tags': ['SME Owner', 'Scale-up', 'Grants', 'Agriculture'],
      'daysLeft': 18,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Growth facility supporting Rwandan SMEs expanding production, markets, and jobs.',
      'eligibilityCriteria':
          'Registered Rwandan SME; minimum 1 year in operation; clear growth plan; tax compliant.',
      'requiredDocuments': [
        'RDB / RDBA registration',
        'Tax clearance',
        'Financial statements',
        'Growth plan',
      ],
      'location': 'Rwanda',
      'contactEmail': 'sme@rdb.rw',
      'applicationInstructions':
          'Submit business and funding request via FundaHub for RDB review.',
      'targetBeneficiaries': 'Registered SMEs in Rwanda',
    },
    {
      'id': 'women-impact',
      'title': 'Women in Business Impact Accelerator',
      'organization': 'UN Women / Partner Network',
      'type': OpportunityType.accelerator.name,
      'amountLabel': 'Mentorship + seed support',
      'tags': ['Women-led', 'Social Impact', 'Seed Funding'],
      'daysLeft': 27,
      'isVerified': true,
      'moderationStatus': 'approved',
      'description':
          'Accelerator for women-led ventures with social or climate impact.',
      'eligibilityCriteria':
          'Women-led (majority ownership or leadership); early-stage venture; social/climate impact focus.',
      'requiredDocuments': ['Founder ID', 'Venture brief', 'Impact metrics'],
      'location': 'East Africa',
      'contactEmail': 'impact@unwomen.org',
      'applicationInstructions': 'Apply with venture and impact narrative.',
      'targetBeneficiaries': 'Women-led social enterprises',
    },
  ];
}
