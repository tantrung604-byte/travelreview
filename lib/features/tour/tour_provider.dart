import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firebase/firebase_providers.dart';

class TourModel {
  final String id;
  final String title;
  final String description;
  final String itinerary;
  final String guide;
  final String places;
  final List<String> highlights;
  final String emoji;
  final String price;
  final String rating;
  final List<SubDestination>? subDestinations; // Thêm danh mục con

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.itinerary,
    required this.guide,
    required this.places,
    required this.highlights,
    required this.emoji,
    required this.price,
    required this.rating,
    this.subDestinations,
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
      highlights: List<String>.from(data['highlights'] ?? []),
      emoji: data['emoji'] ?? '📍',
      price: data['price'] ?? '',
      rating: data['rating'] ?? '5.0',
      subDestinations: (data['subDestinations'] as List?)
          ?.map((e) => SubDestination.fromMap(e))
          .toList(),
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
      'emoji': emoji,
      'price': price,
      'rating': rating,
      'subDestinations': subDestinations?.map((e) => e.toMap()).toList(),
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
