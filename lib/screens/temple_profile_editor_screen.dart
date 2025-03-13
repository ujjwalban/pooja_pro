import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/temple.dart';
import '../firebase/firebase_service.dart';
import '../controllers/multi_media_uploader.dart';
import '../controllers/single_media_uploader.dart';
import '../components/media_thumbnail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TempleProfileEditorScreen extends StatefulWidget {
  final Temple temple;

  const TempleProfileEditorScreen({
    Key? key,
    required this.temple,
  }) : super(key: key);

  @override
  _TempleProfileEditorScreenState createState() =>
      _TempleProfileEditorScreenState();
}

class _TempleProfileEditorScreenState extends State<TempleProfileEditorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;

  // Lists to hold media URLs
  String _mainImageUrl = "";
  List<String> _imageUrls = [];
  List<String> _videoUrls = [];

  bool _isSubmitting = false;
  bool _isPreviewMode = false;

  // For animation between edit and preview modes
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.temple.name);
    _locationController = TextEditingController(text: widget.temple.location);
    _descriptionController =
        TextEditingController(text: widget.temple.description);
    _contactController = TextEditingController(text: widget.temple.contact);

    // Initialize media URLs
    _mainImageUrl = widget.temple.image;
    _imageUrls = List.from(widget.temple.images);
    _videoUrls = List.from(widget.temple.videos);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isPreviewMode = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
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

  // Handle main image URL update
  void _onMainImageChanged(String url) {
    setState(() {
      _mainImageUrl = url;
    });
  }

  // Handle image URLs update
  void _onImagesChanged(List<String> urls) {
    setState(() {
      _imageUrls = urls;
    });
  }

  // Handle video URLs update
  void _onVideosChanged(List<String> urls) {
    setState(() {
      _videoUrls = urls;
    });
  }

  Future<void> _saveTemple() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Make sure we have at least a main image
      if (_mainImageUrl.isEmpty && _imageUrls.isNotEmpty) {
        _mainImageUrl = _imageUrls[0];
      } else if (_mainImageUrl.isEmpty) {
        // If no image was selected at all, use default image
        _mainImageUrl =
            "https://as2.ftcdn.net/v2/jpg/10/57/88/03/1000_F_1057880355_SkadoritQwzkQZ24imNZAKCtIitSUgMq.jpg";
      }

      // Ensure lists are initialized
      final imagesList = _imageUrls.isNotEmpty ? _imageUrls : <String>[];
      final videosList = _videoUrls.isNotEmpty ? _videoUrls : <String>[];

      // Update the temple profile
      FirebaseService().updateTempleProfile(Temple(
        id: widget.temple.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        latitude: widget.temple.latitude ?? 0.0,
        longitude: widget.temple.longitude ?? 0.0,
        description: _descriptionController.text.trim(),
        image: _mainImageUrl,
        images: imagesList,
        videos: videosList,
        contact: _contactController.text.trim(),
      ));

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving temple profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildPreview() {
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

          // Main Temple Image
          if (_mainImageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
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
                child: MediaThumbnail(
                  url: _mainImageUrl,
                  borderRadius: BorderRadius.circular(16),
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
                    Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No main image added',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Temple Name
          Text(
            _nameController.text.isEmpty
                ? 'Untitled Temple'
                : _nameController.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A2E02),
            ),
          ),

          const SizedBox(height: 8),

          // Location and Contact
          Row(
            children: [
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
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                _contactController.text.isEmpty
                    ? 'No contact number'
                    : _contactController.text,
                style: TextStyle(color: Colors.grey.shade600),
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

          const SizedBox(height: 24),

          // Combined Temple Media Gallery Card
          if (_imageUrls.isNotEmpty || _videoUrls.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temple Media Gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: MediaGallery3D(
                      // Combine both images and videos into one gallery for preview
                      mediaUrls: [..._imageUrls, ..._videoUrls],
                      isInteractive: true,
                      showPaginationDots: true,
                    ),
                  ),
                  // Swipe indicator
                  if (_imageUrls.length + _videoUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Swipe to view all media',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
          // Temple Main Photo Card
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
                    'Main Temple Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Single Media Uploader for Main Photo
                  SingleMediaUploader(
                    initialMediaUrl: _mainImageUrl,
                    onMediaChanged: _onMainImageChanged,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Temple Information Card
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
                    'Temple Information',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Temple Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Temple Name',
                      hintText: 'Enter temple name',
                      prefixIcon: const Icon(Icons.temple_hindu),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a temple name';
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
                      hintText: 'Where is this temple located?',
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

                  // Contact Number Field
                  TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      hintText: 'Enter contact number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe this temple in detail...',
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

          const SizedBox(height: 24),

          // Combined Temple Media Gallery Card
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
                    'Temple Media Gallery',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload both images and videos for your temple',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Images Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image,
                              size: 18, color: Color(0xFF9E723C)),
                          const SizedBox(width: 8),
                          Text(
                            'Images',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9E723C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MultiMediaUploader(
                        mediaUrls: _imageUrls,
                        onMediaChanged: _onImagesChanged,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Videos Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.videocam,
                              size: 18, color: Color(0xFF9E723C)),
                          const SizedBox(width: 8),
                          Text(
                            'Videos',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9E723C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MultiMediaUploader(
                        mediaUrls: _videoUrls,
                        onMediaChanged: _onVideosChanged,
                      ),
                    ],
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Temple Profile',
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
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveTemple,
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
                          'Save Temple Profile',
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
    );
  }
}
