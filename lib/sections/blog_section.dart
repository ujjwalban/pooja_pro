import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../firebase/firebase_service.dart';
import '../models/blog.dart';
import '../screens/blog_editor_screen.dart';
import '../components/media_gallery_3d.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

FirebaseService firebaseService = FirebaseService();

// Create a mandala decoration widget
Widget _buildBackgroundMandala(
    {required double size, bool counterClockwise = false}) {
  return AnimatedBuilder(
    animation: const AlwaysStoppedAnimation(0),
    builder: (context, child) {
      return Transform.rotate(
        angle: counterClockwise ? -math.pi / 6 : math.pi / 6,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.deepOrange.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.05),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(size * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Card blogSection(
    String templeId, String templeName, BuildContext context, String userType) {
  if (userType == 'temple') {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Apply a subtle gradient background
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background mandala top right
            Positioned(
              right: -40,
              top: -40,
              child: _buildBackgroundMandala(size: 120),
            ),

            // Decorative background mandala bottom left
            Positioned(
              left: -30,
              bottom: -30,
              child: _buildBackgroundMandala(size: 100, counterClockwise: true),
            ),

            // Main content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Temple Blogs',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Blog',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to the new BlogEditorScreen instead of showing a dialog
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlogEditorScreen(
                                templeId: templeId,
                                templeName: templeName,
                              ),
                            ),
                          );

                          // If result is true, the blog was saved successfully
                          if (result == true) {
                            // Force refresh by adding a unique timestamp to invalidate cache
                            FirebaseFirestore.instance
                                .collection('temples')
                                .doc(templeId)
                                .collection('blogs')
                                .get(const GetOptions(source: Source.server));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Blog published successfully!')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Blog>>(
                    stream: FirebaseService().templeBlogs(templeId),
                    builder: (context, stream) {
                      if (stream.hasError) {
                        return const Center(
                          child: Text(
                            'Error blogs found',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      if (stream.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (stream.hasData == false) {
                        return const Center(
                          child: Text(
                            'No blogs found',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        return ListView.separated(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: stream.data!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final blog = stream.data![index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: Colors.orange.shade200, width: 1.5),
                              ),
                              color: Colors.white,
                              shadowColor: Colors.deepOrange.withOpacity(0.3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with temple name, timestamp and more options
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Profile circle avatar
                                        CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFF5A2E02),
                                          child: Text(
                                            blog.templeName.isNotEmpty
                                                ? blog.templeName[0]
                                                    .toUpperCase()
                                                : "T",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Temple name and post time
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blog.templeName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                blog.dateTime,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // More options button
                                        if (userType == 'temple')
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                // Navigate to edit screen
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlogEditorScreen(
                                                      templeId: templeId,
                                                      templeName: templeName,
                                                      blog: blog,
                                                      docId: stream
                                                          .data![index].blogId,
                                                    ),
                                                  ),
                                                );

                                                if (result == true) {
                                                  // Force refresh by adding a unique timestamp to invalidate cache
                                                  FirebaseFirestore.instance
                                                      .collection('temples')
                                                      .doc(templeId)
                                                      .collection('blogs')
                                                      .doc(stream
                                                          .data![index].blogId)
                                                      .get(const GetOptions(
                                                          source:
                                                              Source.server));

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Blog updated successfully!')),
                                                  );
                                                }
                                              } else if (value == 'delete') {
                                                // Show delete confirmation
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Blog'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this blog post?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          // Get the Firestore document ID directly from the stream
                                                          String documentId =
                                                              stream
                                                                  .data![index]
                                                                  .blogId;

                                                          developer.log(
                                                              "Deleting blog with document ID: $documentId");

                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'temples')
                                                                .doc(templeId)
                                                                .collection(
                                                                    'blogs')
                                                                .doc(documentId)
                                                                .delete();

                                                            // Show feedback to the user
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Blog deleted successfully')),
                                                            );
                                                          } catch (e) {
                                                            developer.log(
                                                                "Error deleting blog: $e");
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Error deleting blog: $e')),
                                                            );
                                                          }

                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    SizedBox(width: 8),
                                                    Text('Edit Blog',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Delete Blog',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Blog title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: Text(
                                      blog.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Blog description (if available)
                                  if (blog.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(
                                        blog.description,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Media container - for images and videos
                                  if (blog.mediaUrls.isNotEmpty)
                                    SizedBox(
                                      height: 250,
                                      child: MediaGallery3D(
                                        mediaUrls: blog.mediaUrls,
                                        isInteractive: true,
                                      ),
                                    ),

                                  // Location
                                  if (blog.location.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              blog.location,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Action buttons bar
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Like button
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _BlogLikes(
                                                blog: blog, templeId: templeId),
                                          ),
                                        ),
                                        // Share button
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                // Share functionality
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Sharing content...'),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.share_outlined,
                                                  color: Colors.teal,
                                                  size: 18),
                                              label: const Text('Share',
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontSize: 12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } else {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Apply a subtle gradient background
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background mandala top right
            Positioned(
              right: -40,
              top: -40,
              child: _buildBackgroundMandala(size: 120),
            ),

            // Decorative background mandala bottom left
            Positioned(
              left: -30,
              bottom: -30,
              child: _buildBackgroundMandala(size: 100, counterClockwise: true),
            ),

            // Main content
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Temple Blogs',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('temples')
                        .doc(templeId)
                        .collection('blogs')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> stream) {
                      if (stream.hasError) {
                        return const Center(
                          child: Text(
                            'Error blogs found',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      if (stream.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (stream.hasData == false) {
                        return const Center(
                          child: Text(
                            'No blogs found',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      {
                        return ListView.separated(
                          padding: const EdgeInsets.all(12.0),
                          itemCount: stream.data!.docs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final blog =
                                Blog.fromFirestore(stream.data!.docs[index]);
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: Colors.orange.shade200, width: 1.5),
                              ),
                              color: Colors.white,
                              shadowColor: Colors.deepOrange.withOpacity(0.3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with temple name, timestamp and more options
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Profile circle avatar
                                        CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFF5A2E02),
                                          child: Text(
                                            blog.templeName.isNotEmpty
                                                ? blog.templeName[0]
                                                    .toUpperCase()
                                                : "T",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Temple name and post time
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blog.templeName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                blog.dateTime,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Blog title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: Text(
                                      blog.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Blog description (if available)
                                  if (blog.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(
                                        blog.description,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Media container - for images and videos
                                  if (blog.mediaUrls.isNotEmpty)
                                    SizedBox(
                                      height: 250,
                                      child: MediaGallery3D(
                                        mediaUrls: blog.mediaUrls,
                                        isInteractive: true,
                                      ),
                                    ),

                                  // Location
                                  if (blog.location.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              blog.location,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Action buttons bar
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Like button
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _BlogLikes(
                                                blog: blog, templeId: templeId),
                                          ),
                                        ),
                                        // Share button
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                // Share functionality
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Sharing content...'),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.share_outlined,
                                                  color: Colors.teal,
                                                  size: 18),
                                              label: const Text('Share',
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontSize: 12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlogLikes extends StatefulWidget {
  final Blog blog;
  final String templeId;

  const _BlogLikes({required this.blog, required this.templeId});

  @override
  State<_BlogLikes> createState() => _BlogLikesState();
}

class _BlogLikesState extends State<_BlogLikes> {
  late int likes;
  bool _isLiked = false;
  bool _showReactions = false;

  @override
  void initState() {
    super.initState();
    likes = widget.blog.like;
  }

  void _handleLike() {
    // Toggle like state
    setState(() {
      if (_isLiked) {
        // If already liked, unlike it
        likes -= 1;
        _isLiked = false;
      } else {
        // If not liked, like it
        likes += 1;
        _isLiked = true;
      }
      _showReactions = false;
    });

    // Update in Firebase - call different methods based on current state
    if (_isLiked) {
      firebaseService.updateBlogLike(widget.blog.blogId, widget.templeId);
    } else {
      firebaseService.removeBlogLike(widget.blog.blogId, widget.templeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color heartColor = _isLiked ? Colors.red : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showReactions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReactionIcon(Icons.favorite, Colors.red),
                _buildReactionIcon(Icons.thumb_up, Colors.blue),
                _buildReactionIcon(Icons.celebration, Colors.orange),
                _buildReactionIcon(Icons.star, Colors.amber),
              ],
            ),
          ),
        // Display heart icon and count horizontally
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onLongPress: () {
                setState(() {
                  _showReactions = !_showReactions;
                });
              },
              child: IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: heartColor,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _handleLike,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              likes.toString(),
              style: TextStyle(
                color: heartColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: _handleLike,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// Replace the entire _showBlogDetailsBottomSheet function with the BlogDetailScreen
class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  const BlogDetailScreen({
    Key? key,
    required this.blog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  blog.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image or first media item
                    if (blog.mediaUrls.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: blog.mediaUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFE0D2C3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF5A2E02),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFE0D2C3),
                          child: const Icon(Icons.error_outline, size: 50),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFE0D2C3),
                        child: const Icon(
                          Icons.article,
                          size: 80,
                          color: Color(0xFF9E723C),
                        ),
                      ),
                    // Gradient overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF5A2E02),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temple and date info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5EF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0D2C3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF5A2E02),
                            child: Text(
                              blog.templeName.isNotEmpty
                                  ? blog.templeName[0].toUpperCase()
                                  : "T",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blog.templeName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF5A2E02),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Color(0xFF9E723C),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      blog.dateTime,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF9E723C),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A2E02).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF9E723C).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.thumb_up,
                                  size: 16,
                                  color: Color(0xFF5A2E02),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${blog.like}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF5A2E02),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location
                    if (blog.location.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Color(0xFF9E723C),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              blog.location,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF9E723C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5A2E02),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blog.description,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Media gallery
                    if (blog.mediaUrls.length > 1) ...[
                      Text(
                        'Gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5A2E02),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: MediaGallery3D(
                            mediaUrls: blog.mediaUrls,
                            isInteractive: true,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up),
                label: const Text('Like'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A2E02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Like functionality
                  FirebaseService()
                      .updateBlogLike(blog.blogId, blog.templeName);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5A2E02),
                  side: const BorderSide(color: Color(0xFF5A2E02)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Share functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
