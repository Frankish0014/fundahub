import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationRemoteDataSource {
  Future<List<AppNotification>> fetchForUser(String? userId);
  Future<List<AppNotification>> fetchPendingAnnouncements();
  Future<void> reviewAnnouncement({
    required String id,
    required String moderationStatus,
  });
  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String createdBy,
    required String organization,
    String? targetUserId,
    String moderationStatus = 'approved',
  });
}

class NotificationFirestoreDataSource implements NotificationRemoteDataSource {
  NotificationFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('announcements');

  @override
  Future<List<AppNotification>> fetchForUser(String? userId) async {
    await _ensureSeeded();
    final snap = await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map(_fromDoc)
        .where((n) {
          final target = n.targetUserId;
          if (target != null && target.isNotEmpty) {
            return userId != null && target == userId;
          }
          return n.moderationStatus == 'approved';
        })
        .toList();
  }

  @override
  Future<List<AppNotification>> fetchPendingAnnouncements() async {
    await _ensureSeeded();
    final snap = await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map(_fromDoc)
        .where(
          (n) =>
              n.targetUserId == null &&
              n.moderationStatus == 'pending' &&
              n.type == AppNotificationType.announcement,
        )
        .toList();
  }

  @override
  Future<void> reviewAnnouncement({
    required String id,
    required String moderationStatus,
  }) async {
    await _collection.doc(id).update({'moderationStatus': moderationStatus});
  }

  @override
  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String createdBy,
    required String organization,
    String? targetUserId,
    String moderationStatus = 'approved',
  }) async {
    await _collection.add({
      'title': title,
      'body': body,
      'createdBy': createdBy,
      'organization': organization,
      'type': targetUserId == null
          ? AppNotificationType.announcement.name
          : AppNotificationType.moderation.name,
      if (targetUserId != null) 'targetUserId': targetUserId,
      'moderationStatus': moderationStatus,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  AppNotification _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final createdAt = (d['createdAt'] as Timestamp?)?.toDate();
    final typeName = d['type'] as String? ?? 'announcement';
    return AppNotification(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      timeAgo: _timeAgo(createdAt),
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => AppNotificationType.announcement,
      ),
      createdAt: createdAt,
      targetUserId: d['targetUserId'] as String?,
      moderationStatus: d['moderationStatus'] as String? ?? 'approved',
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) return;
    final existing = await _collection.limit(1).get();
    _seedChecked = true;
    if (existing.docs.isNotEmpty) return;
    final batch = _firestore.batch();
    final now = DateTime.now();
    batch.set(_collection.doc(), {
      'title': 'New Match: Tony Elumelu Foundation',
      'body': '98% match based on your tags — Seed Funding & Mentorship.',
      'type': AppNotificationType.match.name,
      'organization': 'FundaHub',
      'createdBy': 'system',
      'moderationStatus': 'approved',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
    });
    batch.set(_collection.doc(), {
      'title': 'Deadline Approaching',
      'body': 'Google for Startups Accelerator closes in 45 days.',
      'type': AppNotificationType.deadline.name,
      'organization': 'FundaHub',
      'createdBy': 'system',
      'moderationStatus': 'approved',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
    });
    await batch.commit();
  }
}
