import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/blog.dart';
import '../models/service.dart';
import '../models/customer.dart';
import '../models/temple.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTempleService(String templeId, Service service) async {
    String serviceId = const Uuid().v1();
    User? temple = _auth.currentUser;

    if (temple == null) {
      throw Exception("User not authenticated");
    }

    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .add(Service(
                dateTime: service.dateTime,
                description: service.description,
                imageUrl: service.imageUrl,
                location: service.location,
                price: service.price,
                serviceId: serviceId,
                title: service.title)
            .toMap());
  }

  Future<void> addTempleBlog(String templeId, Blog blog) async {
    User? temple = _auth.currentUser;
    String blogId = const Uuid().v1();

    if (temple == null) {
      throw Exception("User not authenticated");
    }

    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .add(Blog(
          blogId: blogId,
          templeName: blog.templeName,
          title: blog.title,
          description: blog.description,
          location: blog.location,
          dateTime: blog.dateTime,
          imageUrl: blog.imageUrl,
        ).toMap());
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
    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('services')
        .doc(docId)
        .update(service.toMap());

    return [service];
  }

  Future<List<Blog>> updateTempleBlog(
      String templeId, Blog blog, String? docId) async {
    await _firestore
        .collection('temples')
        .doc(templeId)
        .collection('blogs')
        .doc(docId)
        .update(blog.toMap());

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

  Stream<List<Customer>> customerData() {
    return FirebaseFirestore.instance.collection('customers').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList());
  }

  Stream<List<Temple>> templeData() {
    return FirebaseFirestore.instance.collection('temples').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Temple.fromMap(doc.data())).toList());
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

    await FirebaseFirestore.instance.collection('temples').doc(templeId).set(
        Temple(
                id: templeId,
                name: temple.name,
                location: temple.location,
                description: temple.description,
                image: temple.image)
            .toMap());
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
                fullName: customer.fullName,
                phoneNumber: customer.phoneNumber,
                email: customer.email)
            .toMap());
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
