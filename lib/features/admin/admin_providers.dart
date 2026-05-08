/// Providers cho Admin Portal: phân quyền, CRUD tours, upload ảnh, quản lý SEO, quản lý user.
library;

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_providers.dart';
import '../../core/seo/seo_config.dart';
import '../tour/tour_provider.dart';

// ============================================================================
// USER MANAGEMENT — Model, Repository, Providers
// ============================================================================

enum UserStatus { active, banned, reviewBanned }

extension UserStatusX on UserStatus {
  String get firestoreValue {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.banned:
        return 'banned';
      case UserStatus.reviewBanned:
        return 'review_banned';
    }
  }

  static UserStatus fromString(String? s) {
    switch (s) {
      case 'banned':
        return UserStatus.banned;
      case 'review_banned':
        return UserStatus.reviewBanned;
      default:
        return UserStatus.active;
    }
  }
}

class AdminUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final UserStatus status;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String lastIp;
  final String userAgent;
  final String platform;
  final String? banReason;
  final DateTime? bannedAt;
  final int reviewCount;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.phoneNumber = '',
    this.status = UserStatus.active,
    this.createdAt,
    this.lastLoginAt,
    this.lastIp = '',
    this.userAgent = '',
    this.platform = '',
    this.banReason,
    this.bannedAt,
    this.reviewCount = 0,
  });

  factory AdminUserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime? _ts(String key) {
      final v = d[key];
      if (v is Timestamp) return v.toDate();
      return null;
    }

    return AdminUserModel(
      uid: doc.id,
      email: (d['email'] ?? '') as String,
      displayName: (d['displayName'] ?? '') as String,
      photoUrl: (d['photoUrl'] ?? '') as String,
      phoneNumber: (d['phoneNumber'] ?? '') as String,
      status: UserStatusX.fromString(d['status'] as String?),
      createdAt: _ts('createdAt'),
      lastLoginAt: _ts('lastLoginAt'),
      lastIp: (d['lastIp'] ?? '') as String,
      userAgent: (d['userAgent'] ?? '') as String,
      platform: (d['platform'] ?? '') as String,
      banReason: d['banReason'] as String?,
      bannedAt: _ts('bannedAt'),
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Trả về chuỗi mô tả ngắn trình duyệt/thiết bị từ userAgent.
  String get deviceSummary {
    if (userAgent.isEmpty) return platform.isNotEmpty ? platform : '—';
    final ua = userAgent;
    String browser = 'Browser';
    String os = '';

    if (ua.contains('Chrome') && !ua.contains('Edg') && !ua.contains('OPR')) {
      browser = 'Chrome';
    } else if (ua.contains('Firefox')) {
      browser = 'Firefox';
    } else if (ua.contains('Safari') && !ua.contains('Chrome')) {
      browser = 'Safari';
    } else if (ua.contains('Edg')) {
      browser = 'Edge';
    } else if (ua.contains('OPR') || ua.contains('Opera')) {
      browser = 'Opera';
    }

    if (ua.contains('Windows')) {
      os = 'Windows';
    } else if (ua.contains('Macintosh') || ua.contains('Mac OS')) {
      os = 'macOS';
    } else if (ua.contains('Linux')) {
      os = 'Linux';
    } else if (ua.contains('Android')) {
      os = 'Android';
    } else if (ua.contains('iPhone') || ua.contains('iPad')) {
      os = 'iOS';
    }

    return os.isNotEmpty ? '$browser / $os' : browser;
  }
}

class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users');

  /// Stream tất cả users, sort theo lastLoginAt desc.
  Stream<List<AdminUserModel>> watchAll() {
    return _col
        .orderBy('lastLoginAt', descending: true)
        .limit(500)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AdminUserModel.fromDoc(d))
            .toList());
  }

  /// Cập nhật trạng thái user.
  Future<void> updateStatus(
    String uid,
    UserStatus newStatus, {
    String? reason,
    String? adminUid,
  }) async {
    final data = <String, dynamic>{
      'status': newStatus.firestoreValue,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    };
    if (newStatus == UserStatus.banned) {
      data['banReason'] = reason ?? '';
      data['bannedAt'] = FieldValue.serverTimestamp();
      if (adminUid != null) data['bannedBy'] = adminUid;
    } else if (newStatus == UserStatus.active) {
      data['banReason'] = null;
      data['bannedAt'] = null;
      data['bannedBy'] = null;
    }
    await _col.doc(uid).set(data, SetOptions(merge: true));
  }

  /// Xóa tất cả review của 1 user (duyệt qua tất cả tours).
  Future<int> deleteAllReviewsOfUser(String uid) async {
    int deleted = 0;
    final tours = await _db.collection('tours').get();
    for (final tour in tours.docs) {
      final reviews = await tour.reference
          .collection('reviews')
          .where('userId', isEqualTo: uid)
          .get();
      for (final r in reviews.docs) {
        await r.reference.delete();
        deleted++;
      }
    }
    // Cập nhật reviewCount
    await _col.doc(uid).set(
      {'reviewCount': 0, 'lastReviewDeletedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    return deleted;
  }

  /// Lưu thông tin phiên đăng nhập (IP, device).
  Future<void> upsertSession({
    required String uid,
    required String email,
    required String displayName,
    required String photoUrl,
    required String ip,
    required String userAgent,
    required String platform,
  }) async {
    await _col.doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'lastIp': ip,
      'userAgent': userAgent,
      'platform': platform,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Đặt createdAt nếu chưa có
    final doc = await _col.doc(uid).get();
    if (doc.data()?['createdAt'] == null) {
      await _col.doc(uid).set(
        {'createdAt': FieldValue.serverTimestamp(), 'status': 'active'},
        SetOptions(merge: true),
      );
    }
  }

  /// Kiểm tra status của user (dùng trong review submit).
  Future<UserStatus> getUserStatus(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return UserStatus.active;
    return UserStatusX.fromString(doc.data()?['status'] as String?);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

final adminUsersStreamProvider = StreamProvider<List<AdminUserModel>>((ref) {
  return ref.watch(userRepositoryProvider).watchAll();
});

// ============================================================================
// 1) AUTHZ — admin role detection (custom claims)
// ============================================================================

final adminRoleProvider = StreamProvider<bool>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.idTokenChanges().asyncMap((user) async {
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    final claims = token.claims ?? <String, dynamic>{};

    final role = claims['role'];
    final roles = claims['roles'];
    final adminFlag = claims['admin'] == true;

    final roleIsAdmin = role is String && role.toLowerCase() == 'admin';
    final rolesContainAdmin =
        roles is List && roles.any((r) => '$r'.toLowerCase() == 'admin');

    return adminFlag || roleIsAdmin || rolesContainAdmin;
  });
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(adminRoleProvider).maybeWhen(
        data: (isAdmin) => isAdmin,
        orElse: () => false,
      );
});

// ============================================================================
// 2) TOUR REPOSITORY — CRUD trên collection `tours`
// ============================================================================

class TourRepository {
  TourRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('tours');

  Stream<List<TourModel>> watchAll() {
    return _col.orderBy('updatedAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(TourModel.fromFirestore).toList(),
        );
  }

  Future<TourModel?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return TourModel.fromFirestore(doc);
  }

  /// Tạo tour mới. Trả về `id` của doc đã tạo.
  /// Nếu `id` được cung cấp -> dùng làm doc id (để slug đẹp / SEO).
  /// Nếu trùng id sẽ throw [StateError].
  Future<String> createTour({
    String? id,
    required String title,
    String description = '',
    String itinerary = '',
    String guide = '',
    String places = '',
    List<String> highlights = const [],
    List<String> imageUrls = const [],
    String emoji = '📍',
    String price = '',
    String rating = '5.0',
  }) async {
    final docRef = (id == null || id.isEmpty) ? _col.doc() : _col.doc(id);
    if (id != null && id.isNotEmpty) {
      final existing = await docRef.get();
      if (existing.exists) {
        throw StateError('Tour id "$id" already exists');
      }
    }
    await docRef.set({
      'title': title,
      'description': description,
      'itinerary': itinerary,
      'guide': guide,
      'places': places,
      'highlights': highlights,
      'imageUrls': imageUrls,
      'emoji': emoji,
      'price': price,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateTour(String id, Map<String, dynamic> patch) async {
    final data = Map<String, dynamic>.from(patch)
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(id).set(data, SetOptions(merge: true));
  }

  /// Xóa tour cùng toàn bộ ảnh trong Storage `tours/{id}/`.
  Future<void> deleteTour(String id) async {
    try {
      final folder = _storage.ref().child('tours/$id');
      final list = await folder.listAll();
      for (final item in list.items) {
        await item.delete();
      }
    } catch (_) {
      // bỏ qua — folder có thể không tồn tại
    }
    await _col.doc(id).delete();
  }

  /// Upload 1 ảnh vào `tours/{tourId}/{fileName}` và append URL vào doc.
  Future<String> uploadTourImage({
    required String tourId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final fileName =
        'img_${DateTime.now().millisecondsSinceEpoch}.${_extFromContentType(contentType)}';
    final ref = _storage.ref().child('tours/$tourId/$fileName');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    await _col.doc(tourId).set({
      'imageUrls': FieldValue.arrayUnion([url]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return url;
  }

  Future<void> removeTourImage({
    required String tourId,
    required String url,
  }) async {
    await _col.doc(tourId).set({
      'imageUrls': FieldValue.arrayRemove([url]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Storage có thể đã xóa — bỏ qua.
    }
  }

  String _extFromContentType(String ct) {
    switch (ct) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }
}

final tourRepositoryProvider = Provider<TourRepository>((ref) {
  return TourRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

/// Stream danh sách tours dành riêng cho admin (sort theo updatedAt desc).
final adminToursStreamProvider = StreamProvider<List<TourModel>>((ref) {
  return ref.watch(tourRepositoryProvider).watchAll();
});

// ============================================================================
// 3) IMAGE UPLOAD — AsyncNotifier dùng chung cho admin (đa file, tracking %)
// ============================================================================

class ImageUploadState {
  const ImageUploadState({
    this.isUploading = false,
    this.completed = 0,
    this.total = 0,
    this.uploadedUrls = const [],
    this.error,
  });

  final bool isUploading;
  final int completed;
  final int total;
  final List<String> uploadedUrls;
  final String? error;

  double get progress => total == 0 ? 0 : completed / total;

  ImageUploadState copyWith({
    bool? isUploading,
    int? completed,
    int? total,
    List<String>? uploadedUrls,
    String? error,
    bool clearError = false,
  }) =>
      ImageUploadState(
        isUploading: isUploading ?? this.isUploading,
        completed: completed ?? this.completed,
        total: total ?? this.total,
        uploadedUrls: uploadedUrls ?? this.uploadedUrls,
        error: clearError ? null : (error ?? this.error),
      );
}

class ImageUploadNotifier extends Notifier<ImageUploadState> {
  @override
  ImageUploadState build() => const ImageUploadState();

  /// Upload nhiều ảnh. Nếu `tourId` != null → lưu vào `tours/{tourId}/...`
  /// và auto-append vào doc tour. Ngược lại lưu vào `tours/images/...` (legacy).
  Future<List<String>> upload({
    required List<Uint8List> images,
    String? tourId,
    String contentType = 'image/jpeg',
  }) async {
    if (images.isEmpty) return const [];
    state = ImageUploadState(
      isUploading: true,
      total: images.length,
    );

    final urls = <String>[];
    try {
      if (tourId != null && tourId.isNotEmpty) {
        final repo = ref.read(tourRepositoryProvider);
        for (var i = 0; i < images.length; i++) {
          final url = await repo.uploadTourImage(
            tourId: tourId,
            bytes: images[i],
            contentType: contentType,
          );
          urls.add(url);
          state = state.copyWith(completed: i + 1, uploadedUrls: [...urls]);
        }
      } else {
        final storage = ref.read(firebaseStorageProvider);
        for (var i = 0; i < images.length; i++) {
          final fileName =
              'admin_upload_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final ref0 = storage.ref().child('tours/images/$fileName');
          await ref0.putData(
            images[i],
            SettableMetadata(contentType: contentType),
          );
          final url = await ref0.getDownloadURL();
          urls.add(url);
          state = state.copyWith(completed: i + 1, uploadedUrls: [...urls]);
        }
      }

      state = state.copyWith(isUploading: false, clearError: true);
      return urls;
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() => state = const ImageUploadState();
}

final imageUploadProvider =
    NotifierProvider<ImageUploadNotifier, ImageUploadState>(
  ImageUploadNotifier.new,
);

// ============================================================================
// 4) SEO REPOSITORY — persist metadata SEO vào Firestore `seo/{routeKey}`
// ============================================================================

class SeoRepository {
  SeoRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // Firestore không cho phép '/' trong doc id → encode.
  String _encode(String routeKey) {
    if (routeKey == '/' || routeKey.isEmpty) return '__root__';
    return routeKey.replaceAll('/', '__');
  }

  DocumentReference<Map<String, dynamic>> _doc(String routeKey) =>
      _firestore.collection('seo').doc(_encode(routeKey));

  Future<SeoMetadata?> load(String routeKey) async {
    final snap = await _doc(routeKey).get();
    final data = snap.data();
    if (data == null) return null;
    return _fromMap(data);
  }

  Stream<SeoMetadata?> watch(String routeKey) {
    return _doc(routeKey).snapshots().map((s) {
      final data = s.data();
      return data == null ? null : _fromMap(data);
    });
  }

  Future<void> save(String routeKey, SeoMetadata meta) async {
    await _doc(routeKey).set({
      ..._toMap(meta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _toMap(SeoMetadata m) => {
        'title': m.title,
        'description': m.description,
        'keywords': m.keywords,
        'h1': m.h1,
        'h2List': m.h2List,
        'canonicalUrl': m.canonicalUrl,
        'ogImage': m.ogImage,
        'ogType': m.ogType,
        'schemaJson': m.schemaJson,
        'noindex': m.noindex,
      };

  SeoMetadata _fromMap(Map<String, dynamic> d) => SeoMetadata(
        title: (d['title'] ?? '') as String,
        description: (d['description'] ?? '') as String,
        keywords: (d['keywords'] ?? '') as String,
        h1: (d['h1'] ?? '') as String,
        h2List: List<String>.from(d['h2List'] ?? const <String>[]),
        canonicalUrl: (d['canonicalUrl'] ?? '') as String,
        ogImage: (d['ogImage'] ?? '') as String,
        ogType: (d['ogType'] ?? 'website') as String,
        schemaJson: (d['schemaJson'] ?? '') as String,
        noindex: (d['noindex'] ?? false) as bool,
      );
}

final seoRepositoryProvider = Provider<SeoRepository>((ref) {
  return SeoRepository(ref.watch(firestoreProvider));
});

/// Đọc SEO của 1 route từ Firestore; fallback về default in-memory nếu chưa có.
final seoForRouteProvider =
    FutureProvider.family<SeoMetadata, String>((ref, routeKey) async {
  final repo = ref.watch(seoRepositoryProvider);
  final loaded = await repo.load(routeKey);
  if (loaded != null) return loaded;
  return ref.read(seoControllerProvider.notifier).getPageSeo(routeKey) ??
      const SeoMetadata();
});

/// Danh sách các route có thể quản lý SEO (dùng cho dropdown).
const adminSeoManagedRoutes = <String>[
  '/',
  '/discover',
  '/search',
  '/tour',
  '/booking',
  '/legal',
  '/admin',
];
