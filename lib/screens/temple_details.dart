import 'package:flutter/material.dart';
import 'package:pooja_pro/screens/temple_profile.dart';
import 'package:pooja_pro/sections/blog_section.dart';
import 'package:pooja_pro/sections/service_section.dart';

// This code is used in customer dashboard to  display the temples information
class TempleDetailsPage extends StatefulWidget {
  final String templeId;
  final String templeName;
  final String templeImage;
  final String templeDescription;
  final String templeLocation;
  final String templeContact;

  const TempleDetailsPage(
      {Key? key,
      required this.templeId,
      required this.templeName,
      required this.templeImage,
      required this.templeDescription,
      required this.templeLocation,
      required this.templeContact})
      : super(key: key);

  @override
  _TempleDetailsPageState createState() => _TempleDetailsPageState();
}

class _TempleDetailsPageState extends State<TempleDetailsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Temple Info Card
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: widget.templeImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.templeImage,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.temple_buddhist, size: 56),
                        ),
                      )
                    : const Icon(Icons.temple_buddhist, size: 56),
                title: Text(
                  widget.templeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.templeLocation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildBlogsTab(widget.templeId, widget.templeName),
                  _buildServicesTab(widget.templeId, widget.templeName),
                  _buildProfileTab(widget.templeId)
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Blogs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildBlogsTab(String templeId, String templeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Expanded(
            child: blogSection(templeId, templeName, context, 'customer'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(String templeId, String templeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Expanded(
            child: serviceSection(templeId, context, 'customer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(String templeId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Expanded(
            child: TempleProfile(userType: 'customer', templeId: templeId),
          ),
        ],
      ),
    );
  }
}
