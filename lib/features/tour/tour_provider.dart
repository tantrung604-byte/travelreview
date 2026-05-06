import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firebase/firebase_providers.dart';

// ── Lịch trình theo ngày – do admin cập nhật trên CMS ──────────────────────
class DayScheduleItem {
  final int day;
  final String label;       // "Ngày 1", "Day 1"
  final String title;       // Tiêu đề ngắn
  final List<String> activities; // Các hoạt động trong ngày
  final String note;        // Lưu ý cho ngày đó

  const DayScheduleItem({
    required this.day,
    required this.label,
    required this.title,
    required this.activities,
    this.note = '',
  });

  factory DayScheduleItem.fromMap(Map<String, dynamic> map) {
    return DayScheduleItem(
      day: (map['day'] as num?)?.toInt() ?? 0,
      label: map['label'] as String? ?? '',
      title: map['title'] as String? ?? '',
      activities: List<String>.from(map['activities'] ?? const []),
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'day': day,
        'label': label,
        'title': title,
        'activities': activities,
        'note': note,
      };
}

class TourModel {
  final String id;
  final String title;
  final String description;
  final String itinerary;
  final String guide;
  final String places;
  final List<String> highlights;
  final List<String> imageUrls;
  final String emoji;
  final String price;
  final String rating;
  final List<SubDestination>? subDestinations;
  final List<DayScheduleItem> scheduleItems; // Lịch trình theo ngày

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.itinerary,
    required this.guide,
    required this.places,
    required this.highlights,
    this.imageUrls = const [],
    required this.emoji,
    required this.price,
    required this.rating,
    this.subDestinations,
    this.scheduleItems = const [],
  });

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      itinerary: data['itinerary'] ?? '',
      guide: data['guide'] ?? '',
      places: data['places'] ?? '',
      highlights: List<String>.from(data['highlights'] ?? const []),
      imageUrls: List<String>.from(data['imageUrls'] ?? const []),
      emoji: data['emoji'] ?? '📍',
      price: data['price'] ?? '',
      rating: data['rating'] ?? '5.0',
      subDestinations: (data['subDestinations'] as List?)
          ?.map((e) => SubDestination.fromMap(e as Map<String, dynamic>))
          .toList(),
      scheduleItems: (data['scheduleItems'] as List?)
          ?.map((e) => DayScheduleItem.fromMap(e as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'subDestinations': subDestinations?.map((e) => e.toMap()).toList(),
      'scheduleItems': scheduleItems.map((e) => e.toMap()).toList(),
    };
  }
}

class SubDestination {
  final String name;
  final String details;

  SubDestination({required this.name, required this.details});

  factory SubDestination.fromMap(Map<String, dynamic> map) {
    return SubDestination(
      name: map['name'] ?? '',
      details: map['details'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'details': details,
    };
  }
}

final toursStreamProvider = StreamProvider<List<TourModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('tours').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
  });
});

final tourDetailProvider = FutureProvider.family<TourModel?, String>((ref, tourId) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore.collection('tours').doc(tourId).get();
  if (!doc.exists) return null;
  return TourModel.fromFirestore(doc);
});
