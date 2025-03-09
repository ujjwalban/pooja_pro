import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pooja_pro/controllers/image_uploader.dart';
import 'package:video_player/video_player.dart';
import '../firebase/firebase_service.dart';
import '../models/blog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

FirebaseService firebaseService = FirebaseService();

Card blogSection(
    String templeId, String templeName, BuildContext context, String userType) {
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
                    'Temple Blogs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () async {
                      _showBlogDialogForAddingBlog(
                          context, templeId, templeName, null, null);
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
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final blog = stream.data![index];
                        return ListTile(
                          visualDensity: VisualDensity.comfortable,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          // Extract the Blog object from the snapshot
                          // (Assuming 'stream' is your AsyncSnapshot from the StreamBuilder)
                          leading: () {
                            // Create the blog object from Firestore document

                            // If there is an image URL, show the image; otherwise, show a default icon.
                            if (blog.imageUrl.contains(".mp4")) {
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: VideoPlayer(
                                    VideoPlayerController.networkUrl(
                                        Uri.parse(blog.imageUrl))),
                              );
                            }

                            if (blog.imageUrl.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: blog.imageUrl.startsWith('https://')
                                    ? Image.network(
                                        blog.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        blog.imageUrl,
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
                            blog.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              // Convert the DateTime to a string; you might want to format this properly.
                              blog.dateTime,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            // When the ListTile is tapped, create the Blog object and display the details
                            _showBlogDetailsBottomSheet(context, blog);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // You might want to pass the entire Blog object for editing
                                  _showBlogDialogForAddingBlog(
                                    context,
                                    templeId,
                                    templeName,
                                    blog,
                                    stream.data![index].blogId,
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseService().deleteTempleBlog(
                                    templeId,
                                    stream.data![index].blogId,
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
                    'Temple Blogs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.all(20.0),
                      itemCount: stream.data!.docs.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final blog =
                            Blog.fromFirestore(stream.data!.docs[index]);
                        return ListTile(
                          visualDensity: VisualDensity.standard,
                          minTileHeight: 100,

                          // Extract the Blog object from the snapshot
                          // (Assuming 'stream' is your AsyncSnapshot from the StreamBuilder)
                          leading: () {
                            // Create the blog object from Firestore document

                            // If there is an image URL, show the image; otherwise, show a default icon.
                            if (blog.imageUrl.contains(".mp4")) {
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: VideoPlayer(
                                    VideoPlayerController.networkUrl(
                                        Uri.parse(blog.imageUrl))),
                              );
                            }

                            if (blog.imageUrl.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: blog.imageUrl.startsWith('https://')
                                    ? Image.network(
                                        blog.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        blog.imageUrl,
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
                            blog.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              // Convert the DateTime to a string; you might want to format this properly.
                              blog.dateTime,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: _BlogLikes(blog: blog, templeId: templeId),
                          onTap: () {
                            // When the ListTile is tapped, create the Blog object and display the details
                            _showBlogDetailsBottomSheet(context, blog);
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

class _BlogLikes extends StatefulWidget {
  final Blog blog;
  final String templeId;

  const _BlogLikes({required this.blog, required this.templeId});

  @override
  State<_BlogLikes> createState() => _BlogLikesState();
}

class _BlogLikesState extends State<_BlogLikes> {
  late int likes;

  @override
  void initState() {
    super.initState();
    likes = widget.blog.like;
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = const Icon(Icons.thumb_up_alt_outlined);
    return Column(children: [
      Text(likes.toString()),
      IconButton(
          onPressed: () {
            firebaseService.updateBlogLike(widget.blog.blogId, widget.templeId);
            setState(() {
              likes += 1;
              icon = const Icon(Icons.thumb_up);
            });
          },
          icon: icon),
    ]);
  }
}

void _showBlogDetailsBottomSheet(BuildContext context, Blog blog) {
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
                  // Blog title
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

void _showBlogDialogForAddingBlog(
  BuildContext context,
  String templeId,
  String templeName,
  Blog? blog,
  String? docId,
) {
  final titleController = TextEditingController(text: blog?.title ?? "");
  final descriptionController =
      TextEditingController(text: blog?.description ?? "");
  final locationController = TextEditingController(text: blog?.location ?? "");
  final mediaUrlController = TextEditingController(text: blog?.imageUrl ?? "");

  // Manage uploading state outside the builder so it persists.

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
        return AlertDialog(
          title: Text(blog == null ? "Add Blog" : "Edit Blog"),
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
                // The Media URL field is read-only; tapping it lets the user pick media.
                ImageUploader(mediaUrlController: mediaUrlController),
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

                // Save the blog using your Firebase service.
                if (blog == null || docId == null) {
                  FirebaseService().addTempleBlog(
                      templeId,
                      Blog(
                          blogId: "",
                          templeName: templeName,
                          title: titleController.text,
                          description: descriptionController.text,
                          location: locationController.text,
                          imageUrl: mediaUrlController.text,
                          dateTime: date,
                          like: 0));
                } else {
                  FirebaseService().updateTempleBlog(
                    templeId,
                    Blog(
                      blogId: blog.blogId,
                      templeName: templeName,
                      title: titleController.text,
                      description: descriptionController.text,
                      location: locationController.text,
                      imageUrl: mediaUrlController.text,
                      dateTime: date,
                      like: blog.like,
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
