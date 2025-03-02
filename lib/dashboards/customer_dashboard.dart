import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pooja_pro/screens/temple_details.dart';
import 'package:video_player/video_player.dart';
import '../models/temple.dart';
import '../screens/home_screen.dart';
import '../screens/customer_home_screen.dart';

/// CustomerDashboard allows users to browse temple blogs and opt for services.
/// It follows **Single Responsibility Principle (SRP)** by focusing on user navigation.
class CustomerDashboard extends StatefulWidget {
  final String userId;
  final String customerName;
  const CustomerDashboard(
      {super.key, required this.userId, required this.customerName});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

/// `_CustomerDashboardState` manages the user dashboard state.
/// This class follows **Open/Closed Principle (OCP)**, allowing the addition of new tabs without modifying core logic.
class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0; // Tracks which tab is selected
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _screens() {
    if (_selectedIndex == 0) {
      return CustomerHomeScreen(userId: widget.userId);
    } else {
      return Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('temples')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error found',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data?.docs.isEmpty == true) {
                    return const Center(child: Text("No data available"));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      final temple =
                          Temple.fromFirestore(snapshot.data!.docs[index]);
                      return ListTile(
                        visualDensity: VisualDensity.comfortable,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: () {
                          if (temple.image.contains(".mp4")) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: VideoPlayer(
                                  VideoPlayerController.networkUrl(
                                      Uri.parse(temple.image))),
                            );
                          }

                          if (temple.image.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                temple.image,
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
                          temple.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            temple.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              if (await FirebaseFirestore.instance
                                  .collection('customers')
                                  .doc(widget.userId)
                                  .collection('bookmarks')
                                  .where('templeId', isEqualTo: temple.id)
                                  .get()
                                  .then((value) => value.docs.isNotEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bookmark already exists!'),
                                  ),
                                );
                                return;
                              } else {
                                FirebaseFirestore.instance
                                    .collection('customers')
                                    .doc(widget.userId)
                                    .collection('bookmarks')
                                    .add({'templeId': temple.id});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bookmark added!'),
                                  ),
                                );
                              }
                            }),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TempleDetailsPage(
                                  templeId: temple.id,
                                  templeName: temple.name,
                                  templeImage: temple.image,
                                  templeDescription: temple.description,
                                  templeLocation: temple.location,
                                ),
                              ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Logs out the user with a confirmation dialog.
  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancels the logout
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false, // Removes all previous routes
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.customerName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Triggers the logout confirmation dialog
          ),
        ],
      ),
      body: _screens(), // Dynamically displays the selected tab content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'All Temples',
          ),
        ],
      ),
    );
  }
}
