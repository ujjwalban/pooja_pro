import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/blog.dart';
import '../models/service.dart';
import '../models/customer.dart';
import '../models/temple.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> addTempleService(String templeId, Service service) async {
    String serviceId = const Uuid().v1();
    User? temple = _auth.currentUser;

    if (temple == null) {
      throw Exception("User not authenticated");
    }

    // Create a new document reference
    DocumentReference docRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc();

    // Create the service with the Firestore document ID
    Service newService = Service(
        dateTime: service.dateTime,
        description: service.description,
        mediaUrls: service.mediaUrls,
        location: service.location,
        price: service.price,
        serviceId: docRef.id, // Use Firestore document ID as service ID
        title: service.title);

    // Set the document data
    await docRef.set(newService.toMap());

    return docRef.id; // Return the document ID
  }

  void updateTempleProfile(Temple templeProfile) {
    _firestore
        .collection('temples')
        .doc(templeProfile.id)
        .update(templeProfile.toMap());
  }

  void updateCustomerProfile(Customer customer) {
    _firestore
        .collection('customers')
        .doc(customer.id)
        .update(customer.toMap());
  }

  Future<String> addTempleBlog(String templeId, Blog blog) async {
    User? temple = _auth.currentUser;

    if (temple == null) {
      throw Exception("User not authenticated");
    }

    // Create a new document reference
    DocumentReference docRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc();

    // Create the blog with the Firestore document ID
    Blog newBlog = Blog(
        blogId: docRef.id, // Use Firestore document ID as blog ID
        templeName: blog.templeName,
        title: blog.title,
        description: blog.description,
        location: blog.location,
        dateTime: blog.dateTime,
        mediaUrls: blog.mediaUrls,
        like: 0);

    // Set the document data
    await docRef.set(newBlog.toMap());

    return docRef.id; // Return the document ID
  }

  Future<List<Service>> deleteTempleService(
      String templeId, String serviceId) async {
    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(serviceId)
        .delete();

    return [];
  }

  Future<List<Service>> deleteTempleBlog(String templeId, String blogId) async {
    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc(blogId)
        .delete();

    return [];
  }

  Future<List<Service>> updateTempleService(
      String templeId, Service service, String? docId) async {
    if (docId == null || docId.isEmpty) {
      // If docId is null or empty, create a new document instead of updating
      await addTempleService(templeId, service);
    } else {
      // Try to update, but if document doesn't exist, create it
      try {
        await _firestore
            .collection('temples')
            .doc(templeId)
            .collection('services')
            .doc(docId)
            .update(service.toMap());
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('No document to update')) {
          // Document doesn't exist, create it
          await _firestore
              .collection('temples')
              .doc(templeId)
              .collection('services')
              .doc(docId)
              .set(service.toMap());
        } else {
          // Other error, rethrow
          rethrow;
        }
      }
    }

    return [service];
  }

  Future<List<Blog>> updateTempleBlog(
      String templeId, Blog blog, String? docId) async {
    if (docId == null || docId.isEmpty) {
      // If docId is null or empty, create a new document instead of updating
      await addTempleBlog(templeId, blog);
    } else {
      // Try to update, but if document doesn't exist, create it
      try {
        await _firestore
            .collection('temples')
            .doc(templeId)
            .collection('blogs')
            .doc(docId)
            .update(blog.toMap());
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('No document to update')) {
          // Document doesn't exist, create it
          await _firestore
              .collection('temples')
              .doc(templeId)
              .collection('blogs')
              .doc(docId)
              .set(blog.toMap());
        } else {
          // Other error, rethrow
          rethrow;
        }
      }
    }

    return [blog];
  }

  Stream<List<Blog>> templeBlogs(templeId) {
    return FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .orderBy('date_time', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Blog.fromFirestore(doc)).toList());
  }

  // Get a single blog by ID - for refreshing a specific blog
  Stream<Blog?> getSingleBlog(String templeId, String blogId) {
    return FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc(blogId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? Blog.fromFirestore(snapshot) : null);
  }

  // Get a single service by ID - for refreshing a specific service
  Stream<Service?> getSingleService(String templeId, String serviceId) {
    return FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(serviceId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? Service.fromFirestore(snapshot) : null);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> customerData(
      String customerId) {
    return FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> templeData(String templeId) {
    return FirebaseFirestore.instance.collection('temples').doc(templeId).get();
  }

  Future<Temple> templeProfile(String templeId) async {
    final docRef =
        FirebaseFirestore.instance.collection("temples").doc(templeId);
    final doc = await docRef.get();
    return Temple.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<List<String>> getBookmarkedTemples(String userId) {
    return FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<bool> checkBookmark(Temple temple, customerId) async {
    return await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('bookmarks')
        .where('templeId', isEqualTo: temple.id)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  void addBookmark(customerId, Temple temple) async {
    FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('bookmarks')
        .doc(temple.id)
        .set({'templeId': temple.id});
  }

  Stream<List<Blog>> getLatestBlogs(List<String> documents) {
    debugPrint(documents.first.toString());
    return FirebaseFirestore.instance
        .collection('temples')
        .where(FieldPath.documentId, whereIn: documents)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Blog> blogs = [];
      for (var doc in snapshot.docs) {
        final blogsSnapshot = await doc.reference.collection('blogs').get();
        blogs.addAll(
            blogsSnapshot.docs.map((blogDoc) => Blog.fromFirestore(blogDoc)));
      }
      return blogs;
    });
  }

  void templeSignUp(templeId, Temple temple) async {
    FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .set({'timestamp': FieldValue.serverTimestamp()});

    await FirebaseFirestore.instance
        .collection('temples')
        .doc(templeId)
        .set(Temple(
          id: templeId,
          name: temple.name,
          location: temple.location,
          latitude: temple.latitude,
          longitude: temple.longitude,
          description: temple.description,
          image: temple.image,
          images: temple.images,
          videos: temple.videos,
          contact: temple.contact ?? "",
        ).toMap());
  }

  void customerSignUp(customerId, Customer customer) async {
    FirebaseFirestore.instance.collection('customers').doc(customerId).set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .set(Customer(
                id: customerId,
                name: customer.name,
                phoneNumber: customer.phoneNumber,
                email: customer.email,
                photo: customer.photo)
            .toMap());
  }

  Future<void> updateBlogLike(String blogId, String templeId) async {
    DocumentReference blogRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc(blogId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(blogRef);
      if (snapshot.exists) {
        int currentLikes = snapshot.get('like') ?? 0;
        transaction.update(blogRef, {'like': currentLikes + 1});
      }
    });
  }

  // Method to remove a like from a blog
  Future<void> removeBlogLike(String blogId, String templeId) async {
    DocumentReference blogRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc(blogId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(blogRef);
      if (snapshot.exists) {
        int currentLikes = snapshot.get('like') ?? 0;
        // Ensure likes don't go below 0
        transaction.update(blogRef, {'like': math.max(0, currentLikes - 1)});
      }
    });
  }

  Future<void> updateServiceLike(String serviceId, String templeId) async {
    DocumentReference serviceRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(serviceId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(serviceRef);
      if (snapshot.exists) {
        int currentLikes = snapshot.get('like') ?? 0;
        transaction.update(serviceRef, {'like': currentLikes + 1});
      }
    });
  }

  // Method to remove a like from a service
  Future<void> removeServiceLike(String serviceId, String templeId) async {
    DocumentReference serviceRef = _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(serviceId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(serviceRef);
      if (snapshot.exists) {
        int currentLikes = snapshot.get('like') ?? 0;
        // Ensure likes don't go below 0
        transaction.update(serviceRef, {'like': math.max(0, currentLikes - 1)});
      }
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
