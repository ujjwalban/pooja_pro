import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final String imageUrl; // Nullable field for image
  final String price; // Nullable field for date

  Service({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.dateTime,
  });

  // Factory method to create Service from JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json["serviceId"],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      dateTime: json['date_time'],
    );
  }

  // Convert Service instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'title': title,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'date_time': dateTime,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['service_id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      price: map['price'].toDouble(),
      imageUrl: map['image_url'],
      dateTime: map['date_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'date_time': dateTime,
    };
  }

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Service(
      serviceId: data['service_id'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['image_url'] ?? '',
      dateTime: data['date_time'],
      price: data['price'].toDouble(),
    );
  }
}
