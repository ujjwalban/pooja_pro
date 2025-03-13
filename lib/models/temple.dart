import 'package:cloud_firestore/cloud_firestore.dart';

class Temple {
  final String id;
  final String name;
  final String location;
  final double latitude; // New field for location coordinates
  final double longitude; // New field for location coordinates
  final String description;
  final String image; // Main image (kept for backward compatibility)
  final List<String> images; // New field for multiple images
  final List<String> videos; // New field for videos
  final String contact;
  final int followersCount; // New field for followers count

  Temple({
    required this.id,
    required this.name,
    required this.location,
    this.latitude = 0.0, // Default value
    this.longitude = 0.0, // Default value
    required this.description,
    required this.image,
    this.images = const [],
    this.videos = const [],
    required this.contact,
    this.followersCount = 0, // Default value
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'image': image,
      'images': images,
      'videos': videos,
      'contact': contact,
      'followers_count': followersCount,
    };
  }

  factory Temple.fromMap(Map<String, dynamic> map) {
    return Temple(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      location: map['location'] ?? "",
      latitude: map['latitude'] != null
          ? (map['latitude'] is int
              ? (map['latitude'] as int).toDouble()
              : map['latitude'] as double)
          : 0.0,
      longitude: map['longitude'] != null
          ? (map['longitude'] is int
              ? (map['longitude'] as int).toDouble()
              : map['longitude'] as double)
          : 0.0,
      description: map['description'] ?? "",
      image: map['image'] ?? "",
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      contact: map['contact'] ?? "",
      followersCount: map['followers_count'] ?? 0,
    );
  }

  factory Temple.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Temple(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      location: data['location'],
      latitude: data['latitude'] != null
          ? (data['latitude'] is int
              ? (data['latitude'] as int).toDouble()
              : data['latitude'] as double)
          : 0.0,
      longitude: data['longitude'] != null
          ? (data['longitude'] is int
              ? (data['longitude'] as int).toDouble()
              : data['longitude'] as double)
          : 0.0,
      image: data['image'],
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      contact: data['contact'],
      followersCount: data['followers_count'] ?? 0,
    );
  }
}
