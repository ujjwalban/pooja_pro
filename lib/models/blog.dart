import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String blogId;
  final String templeName;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final List<String> mediaUrls;
  final int like;

  Blog({
    required this.blogId,
    required this.templeName,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.mediaUrls,
    required this.like,
  });

  String get imageUrl => mediaUrls.isNotEmpty ? mediaUrls.first : '';

  factory Blog.fromMap(Map<String, dynamic> map) {
    List<String> media = [];
    if (map['media_urls'] != null) {
      media = List<String>.from(map['media_urls']);
    } else if (map['image_url'] != null && map['image_url'].isNotEmpty) {
      media = [map['image_url']];
    }

    return Blog(
      blogId: map['blog_id'],
      templeName: map['temple_name'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      dateTime: map['date_time'],
      mediaUrls: media,
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
      'media_urls': mediaUrls,
      'image_url': mediaUrls.isNotEmpty ? mediaUrls.first : '',
      'like': like,
    };
  }

  factory Blog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    List<String> media = [];
    if (data['media_urls'] != null) {
      media = List<String>.from(data['media_urls']);
    } else if (data['image_url'] != null && data['image_url'].isNotEmpty) {
      media = [data['image_url']];
    }

    return Blog(
      blogId: data['blog_id'],
      templeName: data['temple_name'],
      title: data['title'],
      description: data['description'],
      location: data['location'],
      mediaUrls: media,
      dateTime: data['date_time'],
      like: data['like'],
    );
  }
}
