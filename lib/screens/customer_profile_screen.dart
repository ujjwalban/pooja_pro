import 'package:flutter/material.dart';
import '../controllers/image_uploader.dart';
import '../firebase/firebase_service.dart';
import '../models/customer.dart';

FirebaseService firebaseService = FirebaseService();
Customer? customer_profile;

class CustomerProfileScreen extends StatefulWidget {
  final Customer customer;
  const CustomerProfileScreen({super.key, required this.customer});

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late Customer customerProfile;

  @override
  void initState() {
    super.initState();
    customerProfile = widget.customer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 1000,
        height: 1000,
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: customerProfile.photo.isNotEmpty
                    ? Image.network(customerProfile.photo,
                        width: 250, height: 250)
                    : const Icon(Icons.person),
              ),
              const SizedBox(height: 5, width: 500),
              Text(
                customerProfile.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5, width: 500),
              Text(
                customerProfile.email,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5, width: 500),
              Text(
                customerProfile.phoneNumber,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          customerProfileEditForm(customerProfile, context),
                    ),
                  ).then((_) {
                    // Ensure customer_profile is not null before using it
                    if (customer_profile != null) {
                      setState(() {
                        customerProfile = customer_profile!;
                      });
                    }
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// Dummy edit form widget
Widget customerProfileEditForm(Customer customerProfile, BuildContext context) {
  TextEditingController customerNameController =
      TextEditingController(text: customerProfile.name);
  TextEditingController customerPhoneNumberController =
      TextEditingController(text: customerProfile.phoneNumber);
  TextEditingController customerPhotoController =
      TextEditingController(text: customerProfile.photo);

  return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 10),
          TextField(
            controller: customerNameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: customerPhoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ImageUploader(mediaUrlController: customerPhotoController),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Simulate saving changes
              firebaseService.updateCustomerProfile(customer_profile = Customer(
                id: customerProfile.id,
                name: customerNameController.text,
                email: customerProfile.email,
                phoneNumber: customerPhoneNumberController.text,
                photo: customerPhotoController.text,
              ));

              // Close the form
              Navigator.pop(context);
              customer_profile = Customer(
                  id: customerProfile.id,
                  name: customerNameController.text,
                  email: customerProfile.email,
                  phoneNumber: customerPhoneNumberController.text,
                  photo: customerPhotoController.text);
            },
            child: const Text("Save"),
          ),
        ]),
      ));
}
