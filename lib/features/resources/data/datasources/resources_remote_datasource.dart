import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/training_path.dart';
import '../../domain/entities/training_resource.dart';

abstract class ResourcesRemoteDataSource {
  Future<List<TrainingPath>> fetchPaths();
  Future<List<TrainingResource>> fetchResources({String? query});
  Future<TrainingResource?> fetchResource(String id);
}

/// Firestore-backed training resources datasource.
///
/// Layout:
///   training_paths/{pathId}
///   training_resources/{resourceId}
class ResourcesFirestoreDataSource implements ResourcesRemoteDataSource {
  ResourcesFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  bool _seedChecked = false;

  static const _pathsCollection = 'training_paths';
  static const _resourcesCollection = 'training_resources';

  CollectionReference<Map<String, dynamic>> get _paths =>
      _firestore.collection(_pathsCollection);

  CollectionReference<Map<String, dynamic>> get _resources =>
      _firestore.collection(_resourcesCollection);

  @override
  Future<List<TrainingPath>> fetchPaths() async {
    await _ensureSeeded();
    final snap = await _paths.get();
    final docs = snap.docs.toList()..sort(_bySortIndex);
    return docs.map(_pathFromDoc).toList();
  }

  @override
  Future<List<TrainingResource>> fetchResources({String? query}) async {
    await _ensureSeeded();
    final snap = await _resources.get();
    final docs = snap.docs.toList()..sort(_bySortIndex);
    var items = docs.map(_resourceFromDoc).toList();
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      items = items
          .where(
            (r) =>
                r.title.toLowerCase().contains(q) ||
                r.category.toLowerCase().contains(q) ||
                r.excerpt.toLowerCase().contains(q),
          )
          .toList();
    }
    return items;
  }

  @override
  Future<TrainingResource?> fetchResource(String id) async {
    final doc = await _resources.doc(id).get();
    if (!doc.exists) return null;
    return _resourceFromDoc(doc);
  }

  // --- mapping helpers -------------------------------------------------------

  int _bySortIndex(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    final ai = (a.data()['sortIndex'] as num?)?.toInt() ?? 0;
    final bi = (b.data()['sortIndex'] as num?)?.toInt() ?? 0;
    return ai.compareTo(bi);
  }

  TrainingPath _pathFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return TrainingPath(
      id: doc.id,
      badge: d['badge'] as String? ?? '',
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      lessons: (d['lessons'] as num?)?.toInt() ?? 0,
    );
  }

  TrainingResource _resourceFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return TrainingResource(
      id: doc.id,
      category: d['category'] as String? ?? '',
      title: d['title'] as String? ?? '',
      readTime: d['readTime'] as String? ?? '',
      excerpt: d['excerpt'] as String? ?? '',
      author: d['author'] as String? ?? '',
      authorRole: d['authorRole'] as String? ?? '',
      intro: d['intro'] as String? ?? '',
      sections: _sectionsFrom(d['sections']),
      quote: d['quote'] as String? ?? '',
    );
  }

  List<ResourceSection> _sectionsFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      return ResourceSection(
        heading: m['heading'] as String? ?? '',
        body: m['body'] as String? ?? '',
      );
    }).toList();
  }

  // --- seeding ---------------------------------------------------------------

  Future<void> _ensureSeeded() async {
    if (_seedChecked) return;
    final existing = await _paths.limit(1).get();
    _seedChecked = true;
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final p in _seedPaths) {
      batch.set(_paths.doc(), p);
    }
    for (final r in _seedResources) {
      batch.set(_resources.doc(), r);
    }
    await batch.commit();
  }

  static final List<Map<String, dynamic>> _seedPaths = [
    {
      'sortIndex': 0,
      'badge': 'FOUNDATION',
      'title': 'Pitch Basics',
      'body':
          'Master the art of storytelling and slide deck creation for investors.',
      'lessons': 8,
    },
    {
      'sortIndex': 1,
      'badge': 'FUNDING',
      'title': 'Grant Writing',
      'body': 'Learn how to structure proposals that win funding committees.',
      'lessons': 6,
    },
  ];

  static final List<Map<String, dynamic>> _seedResources = [
    {
      'sortIndex': 0,
      'category': 'LEGAL',
      'readTime': '5 min read',
      'title': 'Choosing the Right Business Entity in Nigeria',
      'excerpt': 'Explore LLC, PLC, and Sole Proprietorship options…',
      'author': 'Sarah Mensah',
      'authorRole': 'Strategic Funding Advisor',
      'intro':
          'The structure you register shapes your taxes, liability, and ability to raise money. Choose deliberately before you grow.',
      'sections': [
        {
          'heading': 'Match Structure to Ambition',
          'body':
              'Sole proprietorships are simple but expose personal assets. If you plan to raise capital, a limited company is usually the better base.',
        },
        {
          'heading': 'Plan for Investors Early',
          'body':
              'Cap tables are far easier to manage from day one. Register in a form that lets you issue shares cleanly.',
        },
      ],
      'quote':
          'The right entity is the one that fits where you are going, not just where you are today.',
    },
    {
      'sortIndex': 1,
      'category': 'FINANCE',
      'readTime': '8 min read',
      'title': 'Building a Simple Cash-Flow Forecast',
      'excerpt': 'A practical template for early-stage founders…',
      'author': 'Sarah Mensah',
      'authorRole': 'Strategic Funding Advisor',
      'intro':
          'Cash-flow, not profit, is what keeps the lights on. A simple 12-month forecast is one of the highest-leverage tools you can build.',
      'sections': [
        {
          'heading': 'Start With Real Numbers',
          'body':
              'Anchor the forecast in actual bank data for the last three months before projecting forward.',
        },
        {
          'heading': 'Model a Bad Month',
          'body':
              'Always keep a pessimistic scenario. Knowing your runway under stress tells you when to raise or cut.',
        },
      ],
      'quote': 'Revenue is vanity, profit is sanity, but cash is king.',
    },
    {
      'sortIndex': 2,
      'category': 'STRATEGY',
      'readTime': '6 min read',
      'title': 'Finding Product-Market Fit in Africa',
      'excerpt': 'Signals to watch before you scale too early…',
      'author': 'Sarah Mensah',
      'authorRole': 'Strategic Funding Advisor',
      'intro':
          'Scaling before fit multiplies your problems. Learn to read the signals that tell you the market is pulling your product.',
      'sections': [
        {
          'heading': 'Watch Retention, Not Signups',
          'body':
              'Downloads are cheap. Repeat usage after week four is the real signal that you solved a genuine problem.',
        },
        {
          'heading': 'Localise Distribution',
          'body':
              'Channels that work in one market rarely transfer directly. Test distribution as rigorously as the product.',
        },
      ],
      'quote':
          'Product-market fit is when the market pulls the product out of your hands.',
    },
    {
      'sortIndex': 3,
      'category': 'MARKETING',
      'readTime': '4 min read',
      'title': 'Low-Budget Customer Acquisition',
      'excerpt': 'Community-led growth tactics that actually work…',
      'author': 'Sarah Mensah',
      'authorRole': 'Strategic Funding Advisor',
      'intro':
          'You do not need a large budget to grow. Community-led tactics compound over time and build defensibility.',
      'sections': [
        {
          'heading': 'Serve a Community First',
          'body':
              'Show up consistently in the places your customers already gather before asking for anything in return.',
        },
        {
          'heading': 'Turn Users Into Advocates',
          'body':
              'A referral loop built on genuine delight is cheaper and more durable than paid acquisition.',
        },
      ],
      'quote':
          'The cheapest customer is the one your happy customers bring you.',
    },
  ];
}
