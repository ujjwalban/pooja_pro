import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../firebase/firebase_service.dart';
import '../models/service.dart';
import '../components/media_gallery_3d.dart';
import '../screens/service_editor_screen.dart';

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

Card serviceSection(String templeId, BuildContext context, String userType) {
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
                        'Temple Services',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () async {
                          // Navigate to the ServiceEditorScreen for adding a new service
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceEditorScreen(
                                templeId: templeId,
                              ),
                            ),
                          );

                          // Show success message if service was created
                          if (result == true) {
                            // Force refresh by adding a unique timestamp to invalidate cache
                            FirebaseFirestore.instance
                                .collection('temples')
                                .doc(templeId)
                                .collection('services')
                                .get(const GetOptions(source: Source.server));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Service published successfully!')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('temples')
                        .doc(templeId)
                        .collection('services')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> stream) {
                      if (stream.hasError) {
                        return const Center(
                          child: Text(
                            'Error services found',
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
                            'No services found',
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
                            final service =
                                Service.fromFirestore(stream.data!.docs[index]);
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
                                  // Header with service title, timestamp and options
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Service type icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5A2E02)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.category,
                                            color: Color(0xFF5A2E02),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Service title and date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                service.dateTime,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // More options button
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              // Navigate to the ServiceEditorScreen for editing
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ServiceEditorScreen(
                                                    templeId: templeId,
                                                    service: service,
                                                    docId: stream
                                                        .data!.docs[index].id,
                                                  ),
                                                ),
                                              );

                                              // Show success message if service was updated
                                              if (result == true) {
                                                // Force refresh by adding a unique timestamp to invalidate cache
                                                FirebaseFirestore.instance
                                                    .collection('temples')
                                                    .doc(templeId)
                                                    .collection('services')
                                                    .doc(stream
                                                        .data!.docs[index].id)
                                                    .get(const GetOptions(
                                                        source: Source.server));

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Service updated successfully!')),
                                                );
                                              }
                                            } else if (value == 'delete') {
                                              // Show delete confirmation
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Service'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this service?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await FirebaseService()
                                                            .deleteTempleService(
                                                          templeId,
                                                          stream.data!
                                                              .docs[index].id,
                                                        );

                                                        // Show feedback to the user
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Service deleted successfully')),
                                                        );

                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
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
                                                  Text('Edit'),
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
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price tag - if available
                                  if (service.price.isNotEmpty &&
                                      service.price != '0')
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '₹${service.price}',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Media container - for images and videos
                                  if (service.mediaUrls.isNotEmpty)
                                    SizedBox(
                                      height: 250,
                                      child: MediaGallery3D(
                                        mediaUrls: service.mediaUrls,
                                        isInteractive: true,
                                      ),
                                    ),

                                  // Service description
                                  if (service.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        service.description,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Location
                                  if (service.location.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              service.location,
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

                                  // Action buttons bar for temple user view
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Like button
                                        _ServiceLikes(
                                            service: service,
                                            templeId: templeId),
                                        // View booking schedule button
                                        TextButton.icon(
                                          onPressed: () {
                                            _showServiceScheduleSheet(
                                                context, service, templeId);
                                          },
                                          icon: const Icon(Icons.calendar_month,
                                              color: Colors.purple, size: 18),
                                          label: const Text('Schedule',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontSize: 12)),
                                        ),
                                        // Manage bookings button
                                        TextButton.icon(
                                          onPressed: () {
                                            _showBookingRequestsSheet(
                                                context, service, templeId);
                                          },
                                          icon: const Icon(Icons.book_online,
                                              color: Colors.green, size: 18),
                                          label: const Text('Bookings',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12)),
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
                        'Temple Services',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('temples')
                        .doc(templeId)
                        .collection('services')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> stream) {
                      if (stream.hasError) {
                        return const Center(
                          child: Text(
                            'Error services found',
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
                            'No services found',
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
                            final service =
                                Service.fromFirestore(stream.data!.docs[index]);
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
                                  // Header with service title, timestamp and options
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Service type icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5A2E02)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.category,
                                            color: Color(0xFF5A2E02),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Service title and date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                service.dateTime,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // More options button
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              // Navigate to the ServiceEditorScreen for editing
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ServiceEditorScreen(
                                                    templeId: templeId,
                                                    service: service,
                                                    docId: stream
                                                        .data!.docs[index].id,
                                                  ),
                                                ),
                                              );

                                              // Show success message if service was updated
                                              if (result == true) {
                                                // Force refresh by adding a unique timestamp to invalidate cache
                                                FirebaseFirestore.instance
                                                    .collection('temples')
                                                    .doc(templeId)
                                                    .collection('services')
                                                    .doc(stream
                                                        .data!.docs[index].id)
                                                    .get(const GetOptions(
                                                        source: Source.server));

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Service updated successfully!')),
                                                );
                                              }
                                            } else if (value == 'delete') {
                                              // Show delete confirmation
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Service'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this service?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await FirebaseService()
                                                            .deleteTempleService(
                                                          templeId,
                                                          stream.data!
                                                              .docs[index].id,
                                                        );

                                                        // Show feedback to the user
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Service deleted successfully')),
                                                        );

                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
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
                                                  Text('Edit'),
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
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price tag - if available
                                  if (service.price.isNotEmpty &&
                                      service.price != '0')
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          '₹${service.price}',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Media container - for images and videos
                                  if (service.mediaUrls.isNotEmpty)
                                    SizedBox(
                                      height: 250,
                                      child: MediaGallery3D(
                                        mediaUrls: service.mediaUrls,
                                        isInteractive: true,
                                      ),
                                    ),

                                  // Service description
                                  if (service.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        service.description,
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // Location
                                  if (service.location.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              service.location,
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

                                  // Action buttons bar for temple user view
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Like button
                                        _ServiceLikes(
                                            service: service,
                                            templeId: templeId),
                                        // View booking schedule button
                                        TextButton.icon(
                                          onPressed: () {
                                            _showServiceScheduleSheet(
                                                context, service, templeId);
                                          },
                                          icon: const Icon(Icons.calendar_month,
                                              color: Colors.purple, size: 18),
                                          label: const Text('Schedule',
                                              style: TextStyle(
                                                  color: Colors.purple,
                                                  fontSize: 12)),
                                        ),
                                        // Manage bookings button
                                        TextButton.icon(
                                          onPressed: () {
                                            _showBookingRequestsSheet(
                                                context, service, templeId);
                                          },
                                          icon: const Icon(Icons.book_online,
                                              color: Colors.green, size: 18),
                                          label: const Text('Bookings',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12)),
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

// Fix _showServiceScheduleSheet function with correct syntax
void _showServiceScheduleSheet(
    BuildContext context, Service service, String templeId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${service.title} - Schedule',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Calendar or schedule view
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('temples')
                        .doc(templeId)
                        .collection('services')
                        .doc(service.serviceId)
                        .collection('schedule')
                        .orderBy('date')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading schedule'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_busy,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No scheduled events',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Time Slot'),
                                onPressed: () {
                                  _addNewTimeSlot(context, service, templeId);
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      // Display the schedule as a list
                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Time Slot'),
                              onPressed: () {
                                _addNewTimeSlot(context, service, templeId);
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final scheduleData = snapshot.data!.docs[index]
                                    .data() as Map<String, dynamic>;
                                final String date = scheduleData['date'] ?? '';
                                final String time = scheduleData['time'] ?? '';
                                final int capacity =
                                    scheduleData['capacity'] ?? 0;
                                final int booked = scheduleData['booked'] ?? 0;
                                final String scheduleId =
                                    snapshot.data!.docs[index].id;

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text('$date at $time'),
                                    subtitle: Text(
                                        'Available: ${capacity - booked}/$capacity'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            _editTimeSlot(
                                                context,
                                                service,
                                                templeId,
                                                scheduleId,
                                                date,
                                                time,
                                                capacity);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _deleteTimeSlot(context, templeId,
                                                service.serviceId, scheduleId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Fix _showBookingRequestsSheet function with correct syntax
void _showBookingRequestsSheet(
    BuildContext context, Service service, String templeId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Booking Requests - ${service.title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Tabs for Pending/Approved/Rejected
                DefaultTabController(
                  length: 3,
                  child: Expanded(
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Pending'),
                            Tab(text: 'Approved'),
                            Tab(text: 'Rejected'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Pending Bookings
                              _buildBookingsList(
                                  context,
                                  templeId,
                                  service.serviceId,
                                  'pending',
                                  scrollController),

                              // Approved Bookings
                              _buildBookingsList(
                                  context,
                                  templeId,
                                  service.serviceId,
                                  'approved',
                                  scrollController),

                              // Rejected Bookings
                              _buildBookingsList(
                                  context,
                                  templeId,
                                  service.serviceId,
                                  'rejected',
                                  scrollController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper method to build the bookings list
Widget _buildBookingsList(BuildContext context, String templeId,
    String serviceId, String status, ScrollController scrollController) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(serviceId)
        .collection('bookings')
        .where('status', isEqualTo: status)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No $status bookings',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: scrollController,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final bookingData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
          final String bookingId = snapshot.data!.docs[index].id;
          final String userName = bookingData['userName'] ?? 'User';
          final String date = bookingData['date'] ?? '';
          final String time = bookingData['time'] ?? '';
          final int attendees = bookingData['attendees'] ?? 1;
          final String contact = bookingData['contact'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Contact: $contact',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Date: $date'),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Time: $time'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Number of Attendees: $attendees'),
                  const SizedBox(height: 12),

                  // Action buttons for pending bookings
                  if (status == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _updateBookingStatus(
                                templeId, serviceId, bookingId, 'rejected');
                          },
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _updateBookingStatus(
                                templeId, serviceId, bookingId, 'approved');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Method to add a new time slot
void _addNewTimeSlot(BuildContext context, Service service, String templeId) {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final capacityController = TextEditingController(text: '20');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Time Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker field
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (MM/DD/YYYY)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // Show date picker
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                  }
                },
              ),

              // Time picker field
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  // Show time picker
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    timeController.text = pickedTime.format(context);
                  }
                },
              ),

              // Capacity field
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (dateController.text.isEmpty ||
                  timeController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              // Save the time slot
              FirebaseFirestore.instance
                  .collection('temples')
                  .doc(templeId)
                  .collection('services')
                  .doc(service.serviceId)
                  .collection('schedule')
                  .add({
                'date': dateController.text,
                'time': timeController.text,
                'capacity': int.parse(capacityController.text),
                'booked': 0,
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

// Method to edit existing time slot
void _editTimeSlot(
    BuildContext context,
    Service service,
    String templeId,
    String scheduleId,
    String currentDate,
    String currentTime,
    int currentCapacity) {
  final dateController = TextEditingController(text: currentDate);
  final timeController = TextEditingController(text: currentTime);
  final capacityController =
      TextEditingController(text: currentCapacity.toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Time Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker field
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (MM/DD/YYYY)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // Show date picker
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                  }
                },
              ),

              // Time picker field
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  // Show time picker
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    timeController.text = pickedTime.format(context);
                  }
                },
              ),

              // Capacity field
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (dateController.text.isEmpty ||
                  timeController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              // Update the time slot
              FirebaseFirestore.instance
                  .collection('temples')
                  .doc(templeId)
                  .collection('services')
                  .doc(service.serviceId)
                  .collection('schedule')
                  .doc(scheduleId)
                  .update({
                'date': dateController.text,
                'time': timeController.text,
                'capacity': int.parse(capacityController.text),
              });

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}

// Method to delete time slot
void _deleteTimeSlot(BuildContext context, String templeId, String serviceId,
    String scheduleId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Time Slot'),
        content: const Text(
            'Are you sure you want to delete this time slot? Existing bookings may be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete the time slot
              FirebaseFirestore.instance
                  .collection('temples')
                  .doc(templeId)
                  .collection('services')
                  .doc(serviceId)
                  .collection('schedule')
                  .doc(scheduleId)
                  .delete();

              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

// Method to update booking status
void _updateBookingStatus(
    String templeId, String serviceId, String bookingId, String newStatus) {
  FirebaseFirestore.instance
      .collection('temples')
      .doc(templeId)
      .collection('services')
      .doc(serviceId)
      .collection('bookings')
      .doc(bookingId)
      .update({
    'status': newStatus,
    'updatedAt': DateTime.now().toString(),
  });
}

// Update _ServiceLikes widget to display heart icon and count horizontally
class _ServiceLikes extends StatefulWidget {
  final Service service;
  final String templeId;

  const _ServiceLikes({required this.service, required this.templeId});

  @override
  State<_ServiceLikes> createState() => _ServiceLikesState();
}

class _ServiceLikesState extends State<_ServiceLikes> {
  late int likes;
  bool _isLiked = false;
  bool _showReactions = false;

  @override
  void initState() {
    super.initState();
    likes = widget.service.like;
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
      FirebaseService()
          .updateServiceLike(widget.service.serviceId, widget.templeId);
    } else {
      FirebaseService()
          .removeServiceLike(widget.service.serviceId, widget.templeId);
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
