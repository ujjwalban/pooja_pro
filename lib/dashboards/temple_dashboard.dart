import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja_pro/screens/home_screen.dart';
import 'package:pooja_pro/sections/blog_section.dart';
import '../sections/service_section.dart';

class TempleDashboard extends StatefulWidget {
  final String templeId;
  final String templeName;
  const TempleDashboard(
      {super.key, required this.templeId, required this.templeName});

  @override
  State<TempleDashboard> createState() => _TempleDashboardState();
}

class _TempleDashboardState extends State<TempleDashboard> {
  int _selectedIndex = 0;
  Widget _buildCurrentSection() {
    if (_selectedIndex == 0) {
      return blogSection(widget.templeId, context, 'temple');
    } else {
      return service_section(widget.templeId, context, 'temple');
    }
  }

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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false, // Removes all previous routes
                  );
                }
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
        title: Text(widget.templeName),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _buildCurrentSection(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Offerings',
          ),
        ],
      ),
    );
  }
}
