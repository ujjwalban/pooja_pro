import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/service.dart';
import '../firebase/firebase_service.dart';
import '../controllers/multi_media_uploader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pooja_pro/components/app_bar_component.dart';

class ServiceEditorScreen extends StatefulWidget {
  final String templeId;
  final Service? service; // Null for new service, existing service for editing
  final String? docId;

  const ServiceEditorScreen({
    Key? key,
    required this.templeId,
    this.service,
    this.docId,
  }) : super(key: key);

  @override
  _ServiceEditorScreenState createState() => _ServiceEditorScreenState();
}

class _ServiceEditorScreenState extends State<ServiceEditorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  List<String> _mediaUrls = [];
  bool _isSubmitting = false;
  bool _isPreviewMode = false;
  final bool _isUploading = false;

  // For animation between edit and preview modes
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?.title ?? "");
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? "");
    _locationController =
        TextEditingController(text: widget.service?.location ?? "");
    _priceController = TextEditingController(text: widget.service?.price ?? "");
    _mediaUrls = widget.service?.mediaUrls ?? [];

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
    _priceController.dispose();
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

  // Handle media URLs update from the uploader
  void _onMediaUrlsChanged(List<String> urls) {
    setState(() {
      _mediaUrls = urls;
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String date =
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';

      // If no media was uploaded, use default image
      if (_mediaUrls.isEmpty) {
        _mediaUrls = [
          "https://as2.ftcdn.net/v2/jpg/10/57/88/03/1000_F_1057880355_SkadoritQwzkQZ24imNZAKCtIitSUgMq.jpg"
        ];
      }

      if (widget.service == null || widget.docId == null) {
        // Create new service
        String serviceId = await FirebaseService().addTempleService(
            widget.templeId,
            Service(
              serviceId: "",
              title: _titleController.text,
              description: _descriptionController.text,
              location: _locationController.text,
              mediaUrls: _mediaUrls,
              price: _priceController.text,
              dateTime: date,
            ));
        debugPrint('Created new service with ID: $serviceId');
      } else {
        // Update existing service
        await FirebaseService().updateTempleService(
          widget.templeId,
          Service(
            serviceId: widget.service?.serviceId ?? "",
            title: _titleController.text,
            description: _descriptionController.text,
            location: _locationController.text,
            mediaUrls: _mediaUrls,
            price: _priceController.text,
            dateTime: date,
          ),
          widget.docId,
        );
      }

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving service: $e')));
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

          // Media Preview Gallery
          if (_mediaUrls.isNotEmpty)
            SizedBox(
              height: 300,
              child: MediaGallery3D(
                mediaUrls: _mediaUrls,
                isInteractive: true,
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
                      'No media added',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Service Title
          Text(
            _titleController.text.isEmpty
                ? 'Untitled Service'
                : _titleController.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A2E02),
            ),
          ),

          const SizedBox(height: 8),

          // Price and Location
          Row(
            children: [
              Icon(Icons.monetization_on,
                  size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                _priceController.text.isEmpty
                    ? 'Price not set'
                    : '₹${_priceController.text}',
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
          // Media Upload Card
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
                    'Service Media',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A2E02),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Multi Media Uploader
                  MultiMediaUploader(
                    mediaUrls: _mediaUrls,
                    onMediaChanged: _onMediaUrlsChanged,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Service Details Card
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
                    'Service Details',
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
                      hintText: 'Enter service title',
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

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'Enter service price',
                      prefixIcon: const Icon(Icons.monetization_on),
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      // Check if value is a valid number
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
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
                      hintText: 'Where is this service available?',
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
                      hintText: 'Describe this service in detail...',
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
          widget.service == null ? 'Create New Service' : 'Edit Service',
          style: GoogleFonts.poppins(
            color: const Color(0xFF5A2E02),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.grey.shade700,
          onPressed: () => Navigator.pop(context),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16.0),
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
                    onPressed: _isSubmitting ? null : _saveService,
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
                            widget.service == null
                                ? 'Publish Service'
                                : 'Update Service',
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
