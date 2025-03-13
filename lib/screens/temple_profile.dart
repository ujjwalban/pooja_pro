import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/image_uploader.dart';
import '../firebase/firebase_service.dart';
import '../models/temple.dart';
import '../screens/home_screen.dart';
import '../components/media_thumbnail.dart';
import '../components/media_gallery_3d.dart' as gallery;
import 'temple_profile_editor_screen.dart';

FirebaseService firebaseService = FirebaseService();

Temple? temple_profile;

class TempleProfile extends StatefulWidget {
  final String templeId;
  final String userType;
  const TempleProfile(
      {super.key, required this.templeId, required this.userType});

  @override
  _TempleProfileState createState() => _TempleProfileState();
}

class _TempleProfileState extends State<TempleProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A2E02),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: Colors.black87,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancels the logout
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false, // Removes all previous routes
                  );
                }
              },
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<Temple> temple = firebaseService.templeProfile(widget.templeId);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: FutureBuilder<Temple>(
        future: temple,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5A2E02),
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading temple profile',
                    style: GoogleFonts.poppins(color: const Color(0xFF5A2E02)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            Temple templeData = snapshot.data!;
            temple_profile = templeData;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header with image and temple name overlay
                Stack(
                  children: [
                    // Header image
                    SizedBox(
                      height: 230,
                      width: double.infinity,
                      child: templeData.image.isNotEmpty
                          ? MediaThumbnail(
                              url: templeData.image,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.temple_hindu,
                                  size: 80, color: Colors.white70),
                            ),
                    ),

                    // Back button
                    Positioned(
                      top: 40,
                      left: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay for better text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
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

                    // Temple name
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              templeData.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Followers count section
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF5EF),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE0D2C3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Color(0xFF9E723C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Followers',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5A2E02),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
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
                        child: Text(
                          '${templeData.followersCount}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF5A2E02),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Color(0xFFE0D2C3),
                    thickness: 1.5,
                  ),
                ),

                // Location with icon
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF9E723C), size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          templeData.location,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF9E723C),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'About Temple',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF5A2E02),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Description content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Text(
                    templeData.description,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),

                // Combined Temple Media Gallery Section - Single gallery for all media
                if (templeData.images.isNotEmpty ||
                    templeData.videos.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.photo_library,
                                color: Color(0xFF9E723C), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Temple Gallery',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF5A2E02),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${templeData.images.length + templeData.videos.length} media items',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFE0D2C3), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 280,
                              child: gallery.MediaGallery3D(
                                // Combine both images and videos into one list
                                mediaUrls: [
                                  ...templeData.images,
                                  ...templeData.videos
                                ],
                                isInteractive: true,
                              ),
                            ),
                          ),
                        ),
                        // Gallery indicator below
                        if (templeData.images.length +
                                templeData.videos.length >
                            1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swipe,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Swipe to view more',
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

                // Contact Information
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5A2E02),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEE2D4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Color(0xFF9E723C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            templeData.contact,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Account Management Section
                if (widget.userType != 'customer')
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F3EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0D2C3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Management',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF5A2E02),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Logout Button - only show for temple users
                        InkWell(
                          onTap: _logout,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Edit profile button for temple user
                if (widget.userType == 'temple')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: templeProfileEdit(templeData),
                  ),

                const SizedBox(height: 24),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5A2E02)),
          );
        },
      ),
    );
  }

  Widget templeProfileEdit(Temple templeProfile) {
    return Builder(
      builder: (BuildContext context) {
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TempleProfileEditorScreen(temple: templeProfile)),
            ).then((result) {
              if (result == true) {
                // Refresh the temple profile data
                setState(() {});
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A2E02),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

Widget templeProfileEditForm(Temple templeProfile, BuildContext context) {
  TextEditingController templeNameController =
      TextEditingController(text: templeProfile.name);
  TextEditingController templeLocationController =
      TextEditingController(text: templeProfile.location);
  TextEditingController templeDescriptionController =
      TextEditingController(text: templeProfile.description);
  TextEditingController templeImageController =
      TextEditingController(text: templeProfile.image);
  TextEditingController templeContactController =
      TextEditingController(text: templeProfile.contact);

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
      iconTheme: const IconThemeData(
        color: Color(0xFF5A2E02),
      ),
    ),
    body: Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temple Information',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF5A2E02),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildEditField(
                controller: templeNameController,
                label: 'Temple Name',
                icon: Icons.temple_hindu,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: templeLocationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: templeDescriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: templeContactController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),

              // Temple Image Section Header
              Text(
                'Temple Image',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF5A2E02),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Image uploader
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F3EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0D2C3),
                    width: 1,
                  ),
                ),
                child: ImageUploader(mediaUrlController: templeImageController),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  firebaseService.updateTempleProfile(Temple(
                    id: templeProfile.id,
                    name: templeNameController.text,
                    location: templeLocationController.text,
                    description: templeDescriptionController.text,
                    image: templeImageController.text,
                    contact: templeContactController.text,
                  ));
                  Navigator.pop(context);
                  temple_profile = Temple(
                    id: templeProfile.id,
                    name: templeNameController.text,
                    location: templeLocationController.text,
                    description: templeDescriptionController.text,
                    image: templeImageController.text,
                    contact: templeContactController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A2E02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

Widget _buildEditField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: const Color(0xFFE0D2C3),
        width: 1,
      ),
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: const Color(0xFF9E723C),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9E723C)),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}
