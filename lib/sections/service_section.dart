import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_image.dart';
import '../firebase/firebase_service.dart';
import '../models/service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Card serviceSection(String templeId, BuildContext context, String userType) {
  if (userType == 'temple') {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Temple Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () async {
                      _showServiceDialogForAddingService(
                          context, templeId, null, null);
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
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final service =
                            Service.fromFirestore(stream.data!.docs[index]);
                        return ListTile(
                          visualDensity: VisualDensity.comfortable,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: () {
                            if (service.imageUrl.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: service.imageUrl.startsWith('https://')
                                    ? Image.network(
                                        service.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        service.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            } else {
                              return const Icon(Icons.article,
                                  size: 50, color: Colors.grey);
                            }
                          }(),
                          title: Text(
                            service.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              // Convert the DateTime to a string; you might want to format this properly.
                              service.dateTime,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            // When the ListTile is tapped, create the Service object and display the details
                            _showServiceDetailsBottomSheet(context, service);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // You might want to pass the entire Service object for editing
                                  _showServiceDialogForAddingService(
                                      context,
                                      templeId,
                                      service,
                                      stream.data!.docs[index].id);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseService().deleteTempleService(
                                    templeId,
                                    stream.data!.docs[index].id,
                                  );
                                },
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
      ),
    );
  } else {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Temple Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final service =
                            Service.fromFirestore(stream.data!.docs[index]);
                        return ListTile(
                          visualDensity: VisualDensity.comfortable,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: () {
                            if (service.imageUrl.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: service.imageUrl.startsWith('https://')
                                    ? Image.network(
                                        service.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        service.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            } else {
                              return const Icon(Icons.article,
                                  size: 50, color: Colors.grey);
                            }
                          }(),
                          title: Text(
                            service.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              // Convert the DateTime to a string; you might want to format this properly.
                              service.dateTime,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            // When the ListTile is tapped, create the Service object and display the details
                            _showServiceDetailsBottomSheet(context, service);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showServiceDetailsBottomSheet(BuildContext context, Service blog) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true, // Allow the modal to take more height
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service title
                  Text(
                    blog.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  // Display image if available
                  if (blog.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: blog.imageUrl.startsWith('https://')
                          ? Image.network(
                              blog.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              blog.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  const SizedBox(height: 8),
                  // Display date
                  Text(
                    'Date: ${blog.dateTime}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Display full blog content
                  Text(
                    blog.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Display location
                  Text(
                    blog.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Close button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
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

// Import your FirebaseUploader and FirebaseService classes here.

void _showServiceDialogForAddingService(
  BuildContext context,
  String templeId,
  Service? service,
  String? docId,
) {
  final titleController = TextEditingController(text: service?.title ?? "");
  final descriptionController =
      TextEditingController(text: service?.description ?? "");
  final locationController =
      TextEditingController(text: service?.location ?? "");
  final mediaUrlController =
      TextEditingController(text: service?.imageUrl ?? "");
  final priceController = TextEditingController(text: service?.imageUrl ?? "");
  final FirebaseUploader uploader = FirebaseUploader();

  // Manage uploading state outside the builder so it persists.
  bool isUploading = false;

  // Function to get the current location.
  Future<void> getCurrentLocation() async {
    try {
      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use the latitude and longitude to get the address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Get the first placemark (most relevant one)
      Placemark place = placemarks[0];

      // You can extract other details like city, street, etc. from the Placemark
      String address = "${place.name}, ${place.locality}, ${place.country}";

      // Set the locationController text to the address
      locationController.text = address;
    } catch (e) {
      // Optionally, show an error message to the user.
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        // Function to show media selection dialog.
        void chooseMedia() {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Select Media Type"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text("Image"),
                      onTap: () async {
                        Navigator.pop(context); // Close media selection dialog
                        setState(() {
                          isUploading = true;
                        });
                        String? base64String =
                            await uploader.pickAndUploadMedia(isImage: true);
                        setState(() {
                          isUploading = false;
                          if (base64String != null && base64String.isNotEmpty) {
                            mediaUrlController.text = base64String;
                          }
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.videocam),
                      title: const Text("Video"),
                      onTap: () async {
                        Navigator.pop(context);
                        setState(() {
                          isUploading = true;
                        });
                        String? url =
                            await uploader.pickAndUploadMedia(isImage: false);
                        setState(() {
                          isUploading = false;
                          if (url != null && url.isNotEmpty) {
                            mediaUrlController.text = url;
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }

        String url =
            "https://as2.ftcdn.net/v2/jpg/10/57/88/03/1000_F_1057880355_SkadoritQwzkQZ24imNZAKCtIitSUgMq.jpg";

        // Widget to display a media preview.
        Widget mediaPreview() {
          // If nothing is selected, show the default mandir icon.
          if (mediaUrlController.text.isEmpty) {
            return Image.network(
              url,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            );
          } else if (mediaUrlController.text.endsWith('.mp4')) {
            return const Column(
              children: [
                Icon(Icons.videocam, size: 80),
                Text("Video selected"),
              ],
            );
          } else {
            return Image.network(
              mediaUrlController.text,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            );
          }
        }

        return AlertDialog(
          title: Text(service == null ? "Add Service" : "Edit Service"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title field.
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                // Description field.
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                // Location field with a button to use current location.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration:
                            const InputDecoration(labelText: "Location"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        await getCurrentLocation();
                        setState(() {}); // Refresh to show updated location.
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                isUploading
                    ? const CircularProgressIndicator()
                    : mediaPreview(),
                const SizedBox(height: 10),
                // The Media URL field is read-only; tapping it lets the user pick media.
                GestureDetector(
                  onTap: chooseMedia,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: mediaUrlController,
                      decoration: InputDecoration(
                        labelText: "Media URL",
                        suffixIcon: mediaUrlController.text.isNotEmpty
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.upload_file),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String date =
                    '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';

                if (mediaUrlController.text == "") {
                  mediaUrlController.text = url;
                }

                // Save the service using your Firebase service.
                if (service == null || docId == null) {
                  FirebaseService().addTempleService(
                      templeId,
                      Service(
                          serviceId: "",
                          title: titleController.text,
                          description: descriptionController.text,
                          location: locationController.text,
                          imageUrl: mediaUrlController.text,
                          price: priceController.text,
                          dateTime: date));
                } else {
                  FirebaseService().updateTempleService(
                    templeId,
                    Service(
                      serviceId: service.serviceId,
                      title: titleController.text,
                      description: descriptionController.text,
                      location: locationController.text,
                      imageUrl: mediaUrlController.text,
                      dateTime: date,
                      price: priceController.text,
                    ),
                    docId,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      });
    },
  );
}
