import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blog.dart';
import '../firebase/firebase_service.dart';
import '../controllers/multi_media_uploader.dart';
import '../components/media_gallery_3d.dart' as components;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BlogEditorScreen extends StatefulWidget {
  final String templeId;
  final String templeName;
  final Blog? blog; // Null for new blog, existing blog for editing
  final String? docId;

  const BlogEditorScreen({
    Key? key,
    required this.templeId,
    required this.templeName,
    this.blog,
    this.docId,
  }) : super(key: key);

  @override
  _BlogEditorScreenState createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  List<String> _mediaUrls = [];
  bool _isSubmitting = false;
  bool _isPreviewMode = false;

  // For animation between edit and preview modes
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog?.title ?? "");
    _descriptionController =
        TextEditingController(text: widget.blog?.description ?? "");
    _locationController =
        TextEditingController(text: widget.blog?.location ?? "");
    _mediaUrls = widget.blog?.mediaUrls ?? [];

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isPreviewMode = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";

        setState(() {
          _locationController.text =
              address.trim().replaceAll(RegExp(r'^\s*,\s*|\s*,\s*$'), '');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not determine location: $e')));
    }
  }

  Future<void> _saveBlog() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if we have at least one media
    if (_mediaUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please add at least one photo or video')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String date =
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';

      if (widget.blog == null || widget.docId == null) {
        // Create new blog
        String blogId = await FirebaseService().addTempleBlog(
            widget.templeId,
            Blog(
              blogId: "",
              templeName: widget.templeName,
              title: _titleController.text,
              description: _descriptionController.text,
              location: _locationController.text,
              mediaUrls: _mediaUrls,
              dateTime: date,
              like: 0,
            ));
        debugPrint('Created new blog with ID: $blogId');
      } else {
        // Update existing blog
        await FirebaseService().updateTempleBlog(
          widget.templeId,
          Blog(
            blogId: widget.blog!.blogId,
            templeName: widget.templeName,
            title: _titleController.text,
            description: _descriptionController.text,
            location: _locationController.text,
            mediaUrls: _mediaUrls,
            dateTime: date,
            like: widget.blog!.like,
          ),
          widget.docId!,
        );
      }

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving blog: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildPreview() {
    // Create a temporary blog object for preview
    final previewBlog = Blog(
      blogId: widget.blog?.blogId ?? "",
      templeName: widget.templeName,
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      mediaUrls: _mediaUrls,
      dateTime:
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
      like: widget.blog?.like ?? 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade800),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Preview Mode',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Media Gallery Preview
          if (_mediaUrls.isNotEmpty)
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: components.MediaGallery3D(
                  mediaUrls: _mediaUrls,
                  isInteractive: true,
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No media added',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Blog Title
          Text(
            _titleController.text.isEmpty
                ? 'Untitled Blog'
                : _titleController.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A2E02),
            ),
          ),

          const SizedBox(height: 8),

          // Date and Location
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _locationController.text.isEmpty
                      ? 'No location set'
                      : _locationController.text,
                  style: TextStyle(color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            _descriptionController.text.isEmpty
                ? 'No description provided'
                : _descriptionController.text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Media Uploader
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media Gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MultiMediaUploader(
                    mediaUrls: _mediaUrls,
                    onMediaChanged: (updatedUrls) {
                      setState(() {
                        _mediaUrls = updatedUrls;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Blog Details
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blog Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter a catchy title for your blog',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Location Field with Current Location Button
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'Where was this taken?',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location),
                        tooltip: 'Use current location',
                        onPressed: _getCurrentLocation,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Tell the story behind your blog...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.blog == null ? 'Create New Blog' : 'Edit Blog',
          style: GoogleFonts.poppins(
            color: const Color(0xFF5A2E02),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.grey.shade700,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
            label: Text(_isPreviewMode ? 'Edit' : 'Preview'),
            onPressed: () {
              _tabController.animateTo(_isPreviewMode ? 0 : 1);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'EDIT'),
            Tab(text: 'PREVIEW'),
          ],
          labelColor: const Color(0xFF5A2E02),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF5A2E02),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorForm(),
          _buildPreview(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomAppBar(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveBlog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A2E02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Saving...'),
                            ],
                          )
                        : Text(
                            widget.blog == null
                                ? 'Publish Blog'
                                : 'Update Blog',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
