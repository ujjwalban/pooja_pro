import 'package:flutter/material.dart';
import '../controllers/image_uploader.dart';
import '../firebase/firebase_service.dart';
import '../models/temple.dart';

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
  @override
  Widget build(BuildContext context) {
    Future<Temple> temple = firebaseService.templeProfile(widget.templeId);
    return Scaffold(
        body: Center(
            child: FutureBuilder<Temple>(
                future: temple,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Temple templeData = snapshot.data!;
                    temple_profile = templeData;
                    return SizedBox(
                        height: 1000,
                        width: 1000,
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
                              const SizedBox(height: 5, width: 500),
                              Text(templeData.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5, width: 500),
                              Image.network(
                                templeData.image,
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 5, width: 500),
                              Text(templeData.description,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5, width: 500),
                              Text(templeData.location,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5, width: 500),
                              Text(templeData.contact,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              if (widget.userType == 'temple')
                                templeProfileEdit(templeData)
                            ],
                          ),
                        ));
                  }
                  return const Center(child: CircularProgressIndicator());
                })));
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
                      templeProfileEditForm(templeProfile, context)),
            ).then((_) {
              setState(() {
                templeProfile = temple_profile!;
              });
            });
          },
          child: const Text('Edit Profile'),
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
      body: Form(
    child: Column(
      children: [
        TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            controller: templeNameController),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Location'),
          controller: templeLocationController,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description'),
          controller: templeDescriptionController,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
          controller: templeContactController,
        ),
        const SizedBox(height: 10),
        ImageUploader(mediaUrlController: templeImageController),
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
          child: const Text('Save'),
        )
      ],
    ),
  ));
}
