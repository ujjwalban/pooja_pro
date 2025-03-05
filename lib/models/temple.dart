import 'package:cloud_firestore/cloud_firestore.dart';

class Temple {
  final String id;
  final String name;
  final String location;
  final String description;
  final String image;

  Temple({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image': image,
    };
  }

  factory Temple.fromMap(Map<String, dynamic> map) {
    return Temple(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      location: map['location'] ?? "",
      description: map['description'] ?? "",
      image: map['image'] ?? "",
    );
  }

  factory Temple.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Temple(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      location: data['location'],
      image: data['image'],
    );
  }
}
