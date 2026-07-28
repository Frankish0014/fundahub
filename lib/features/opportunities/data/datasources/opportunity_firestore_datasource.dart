import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/opportunity.dart';

class OpportunityFirestoreDataSource {
  OpportunityFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('opportunities');

  Future<List<Opportunity>> fetchAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Future<Opportunity?> fetchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Future<void> create(Opportunity opportunity) async {
    await _collection.doc(opportunity.id).set(_toMap(opportunity));
  }

  Future<void> update(Opportunity opportunity) async {
    await _collection.doc(opportunity.id).update(_toMap(opportunity));
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Opportunity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Opportunity(
      id: doc.id,
      title: data['title'] as String,
      organization: data['organization'] as String,
      type: OpportunityType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => OpportunityType.grant,
      ),
      amountLabel: data['amountLabel'] as String,
      tags: List<String>.from(data['tags'] as List? ?? []),
      daysLeft: data['daysLeft'] as int? ?? 0,
      isVerified: data['isVerified'] as bool? ?? true,
      isSaved: data['isSaved'] as bool? ?? false,
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
      'isSaved': o.isSaved,
    };
  }
}
