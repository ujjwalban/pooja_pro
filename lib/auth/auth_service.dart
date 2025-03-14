import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja_pro/firebase/firebase_service.dart';
import 'package:pooja_pro/models/temple.dart';
import 'package:pooja_pro/models/customer.dart';
import '../dashboards/temple_dashboard.dart'; // Importing Temple Dashboard
import '../dashboards/customer_dashboard.dart'; // Importing User Dashboard

class AuthService {
  final String userType;
  AuthService({required this.userType});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle sign-in
  Future<void> signIn(String email, String password, String userType,
      BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("$userType not found, please sign up");
      }

      if (userType == "Temple") {
        try {
          // Navigate to Temple Dashboard, passing the Temple ID
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseService().templeData(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data()!;
                    return TempleDashboard(
                      templeDetails: Temple.fromMap(data),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      } else {
        try {
          String customerId = user.uid;
          // Navigate to Temple Dashboard, passing the Temple ID
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseService().customerData(customerId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CustomerDashboard(
                      customer: Customer(
                          id: customerId,
                          name: snapshot.data!.data()!['name'],
                          phoneNumber: snapshot.data!.data()!['phone_number'],
                          email: snapshot.data!.data()!['email'],
                          photo: snapshot.data!.data()!['photo']),
                    );
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // Function to handle sign-up and store Temple ID
  Future<void> signUp(String email, String password, String userType,
      Temple? temple, Customer? customer, BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Error creating account. Please try again.");
      }
      if (userType == "Temple" && temple != null) {
        String templeId = user.uid;
        Temple templeDetails = Temple(
          id: templeId,
          name: temple.name,
          location: temple.location,
          latitude: temple.latitude,
          longitude: temple.longitude,
          description: temple.description,
          image: temple.image,
          images: temple.images,
          videos: temple.videos,
          contact: temple.contact,
        );
        FirebaseService().templeSignUp(templeId, templeDetails);

        // Navigate to Temple Dashboard, passing the Temple ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TempleDashboard(templeDetails: templeDetails),
          ),
        );
      } else if (userType == "Customer" && customer != null) {
        // Generate a user ID and update the user's displayName
        String customerId = user.uid;
        Customer customerDetails = Customer(
            id: customerId,
            name: customer.name,
            phoneNumber: customer.phoneNumber,
            email: customer.email,
            photo: customer.photo);

        FirebaseService().customerSignUp(customerId, customerDetails);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDashboard(
              customer: customerDetails,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
