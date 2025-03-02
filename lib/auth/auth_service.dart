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
          String templeId = user.uid;

          // Navigate to Temple Dashboard, passing the Temple ID
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StreamBuilder<List<Temple>>(
                stream: FirebaseService().templeData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TempleDashboard(
                      templeId: templeId,
                      templeName: snapshot.data!.first.name,
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
              builder: (context) => StreamBuilder<List<Customer>>(
                stream: FirebaseService().customerData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CustomerDashboard(
                      userId: customerId,
                      customerName: snapshot.data!.first.fullName,
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
        FirebaseService().templeSignUp(
            templeId,
            Temple(
                id: templeId,
                name: temple.name,
                location: temple.location,
                description: temple.description,
                image: temple.image));

        // Navigate to Temple Dashboard, passing the Temple ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TempleDashboard(templeId: templeId, templeName: temple.name),
          ),
        );
      } else if (customer != null) {
        // Generate a user ID and update the user's displayName
        String customerId = user.uid;
        FirebaseService().customerSignUp(
            customerId,
            Customer(
                id: customerId,
                fullName: customer.fullName,
                phoneNumber: customer.phoneNumber,
                email: customer.email));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDashboard(
                userId: customerId, customerName: customer.fullName),
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
