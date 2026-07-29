import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/opportunity_application.dart';

class ApplicationFirestoreDataSource {
  ApplicationFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('applications');

  Future<void> create(OpportunityApplication application) async {
    await _collection.doc(application.id).set(_toMap(application));
  }

  Future<OpportunityApplication?> fetchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<OpportunityApplication?> fetchForApplicant({
    required String opportunityId,
    required String applicantId,
  }) async {
    final snap = await _collection
        .where('opportunityId', isEqualTo: opportunityId)
        .where('applicantId', isEqualTo: applicantId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromDoc(snap.docs.first);
  }

  Future<List<OpportunityApplication>> fetchForApplicantAll(
    String applicantId,
  ) async {
    final snap = await _collection
        .where('applicantId', isEqualTo: applicantId)
        .get();
    final items = snap.docs.map(_fromDoc).toList();
    items.sort(_bySubmittedDesc);
    return items;
  }

  Future<List<OpportunityApplication>> fetchForProvider(
    String providerId,
  ) async {
    final snap = await _collection
        .where('providerId', isEqualTo: providerId)
        .get();
    final items = snap.docs.map(_fromDoc).toList();
    items.sort(_bySubmittedDesc);
    return items;
  }

  Future<List<OpportunityApplication>> fetchForOpportunity(
    String opportunityId,
  ) async {
    final snap = await _collection
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    final items = snap.docs.map(_fromDoc).toList();
    items.sort(_bySubmittedDesc);
    return items;
  }

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
    required String reviewerId,
    String reviewerNote = '',
  }) async {
    await _collection.doc(applicationId).update({
      'status': status.name,
      'reviewerNote': reviewerNote,
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  int _bySubmittedDesc(OpportunityApplication a, OpportunityApplication b) {
    final aTime = a.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  }

  OpportunityApplication _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    DateTime? submittedAt;
    DateTime? reviewedAt;
    final submittedRaw = data['submittedAt'];
    final reviewedRaw = data['reviewedAt'];
    if (submittedRaw is Timestamp) submittedAt = submittedRaw.toDate();
    if (reviewedRaw is Timestamp) reviewedAt = reviewedRaw.toDate();

    return OpportunityApplication(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      applicantId: data['applicantId'] as String? ?? '',
      applicantName: data['applicantName'] as String? ?? '',
      applicantEmail: data['applicantEmail'] as String? ?? '',
      applicantPhone: data['applicantPhone'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      businessDescription: data['businessDescription'] as String? ?? '',
      location: data['location'] as String? ?? '',
      fundingRequested: data['fundingRequested'] as String? ?? '',
      howFundsWillBeUsed: data['howFundsWillBeUsed'] as String? ?? '',
      teamSize: (data['teamSize'] as num?)?.toInt() ?? 0,
      yearsInOperation: (data['yearsInOperation'] as num?)?.toInt() ?? 0,
      impactStatement: data['impactStatement'] as String? ?? '',
      eligibilityConfirmed: data['eligibilityConfirmed'] as bool? ?? false,
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      reviewerNote: data['reviewerNote'] as String? ?? '',
      reviewedAt: reviewedAt,
      reviewedBy: data['reviewedBy'] as String?,
      submittedAt: submittedAt,
    );
  }

  Map<String, dynamic> _toMap(OpportunityApplication a) {
    return {
      'opportunityId': a.opportunityId,
      'opportunityTitle': a.opportunityTitle,
      'providerId': a.providerId,
      'applicantId': a.applicantId,
      'applicantName': a.applicantName,
      'applicantEmail': a.applicantEmail,
      'applicantPhone': a.applicantPhone,
      'businessName': a.businessName,
      'businessDescription': a.businessDescription,
      'location': a.location,
      'fundingRequested': a.fundingRequested,
      'howFundsWillBeUsed': a.howFundsWillBeUsed,
      'teamSize': a.teamSize,
      'yearsInOperation': a.yearsInOperation,
      'impactStatement': a.impactStatement,
      'eligibilityConfirmed': a.eligibilityConfirmed,
      'status': a.status.name,
      'reviewerNote': a.reviewerNote,
      if (a.reviewedBy != null) 'reviewedBy': a.reviewedBy,
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }
}
