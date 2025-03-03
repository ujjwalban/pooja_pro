import 'package:flutter/material.dart';
import '../firebase/firebase_service.dart';
import '../models/blog.dart';

class CustomerHomeScreen extends StatelessWidget {
  final String userId;

  const CustomerHomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    return StreamBuilder<List<String>>(
      stream: firebaseService.getBookmarkedTemples(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No temples bookmarked'));
        }

        return StreamBuilder<List<Blog>>(
          stream: firebaseService.getLatestBlogs(snapshot.data!),
          builder: (context, blogSnapshot) {
            if (!blogSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Blog> blogs = blogSnapshot.data!;
            debugPrint('Blogs: ${blogs.length}');

            return ListView.builder(
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                Blog blog = blogs[index];
                debugPrint('Blog: ${blog.title}');
                return BlogCard(blog: blog);
              },
            );
          },
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(blog.templeName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Image.network(blog.imageUrl, width: 200, height: 200),
            const SizedBox(height: 5),
            Text(blog.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(blog.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(blog.dateTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
