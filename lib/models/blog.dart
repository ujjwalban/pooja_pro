import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String blogId;
  final String templeName;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final String imageUrl;
  final int like;

  Blog({
    required this.blogId,
    required this.templeName,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.imageUrl,
    required this.like,
  });

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      blogId: map['blog_id'],
      templeName: map['temple_name'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      dateTime: map['date_time'],
      imageUrl: map['image_url'],
      like: map['like'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blog_id': blogId,
      'temple_name': templeName,
      'title': title,
      'description': description,
      'location': location,
      'date_time': dateTime,
      'image_url': imageUrl,
      'like': like,
    };
  }

  factory Blog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Blog(
      blogId: data['blog_id'],
      templeName: data['temple_name'],
      title: data['title'],
      description: data['description'],
      location: data['location'],
      imageUrl: data['image_url'],
      dateTime: data['date_time'],
      like: data['like'],
    );
  }
}
