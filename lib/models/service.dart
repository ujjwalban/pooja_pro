import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final List<String>
      mediaUrls; // Changed from single imageUrl to list of media URLs
  final String price; // Nullable field for date
  final int like; // Added like field

  Service({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.mediaUrls, // Updated parameter
    required this.dateTime,
    this.like = 0, // Default to 0 likes
  });

  // Factory method to create Service from JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json["serviceId"],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: json['price'],
      mediaUrls:
          List<String>.from(json['media_urls'] ?? []), // Updated to parse list
      dateTime: json['date_time'],
      like: json['like'] ?? 0, // Added like field
    );
  }

  // Convert Service instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'title': title,
      'location': location,
      'price': price,
      'media_urls': mediaUrls, // Updated field name
      'date_time': dateTime,
      'like': like, // Added like field
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['service_id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      price: map['price'],
      mediaUrls:
          List<String>.from(map['media_urls'] ?? []), // Updated to parse list
      dateTime: map['date_time'],
      like: map['like'] ?? 0, // Added like field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'media_urls': mediaUrls, // Updated field name
      'date_time': dateTime,
      'like': like, // Added like field
    };
  }

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Handle backward compatibility - if there's an image_url, add it to mediaUrls
    List<String> urls = [];
    if (data['media_urls'] != null) {
      urls = List<String>.from(data['media_urls']);
    } else if (data['image_url'] != null && data['image_url'].isNotEmpty) {
      // If we only have the old image_url field, convert it to a list
      urls = [data['image_url']];
    }

    return Service(
      serviceId: data['service_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      mediaUrls: urls,
      dateTime: data['date_time'] ?? '',
      price: data['price']?.toString() ?? '0',
      like: data['like'] ?? 0, // Added like field
    );
  }
}
