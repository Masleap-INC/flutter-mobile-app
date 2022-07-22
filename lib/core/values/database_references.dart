/// Copyright, 2022, by the authors. All rights reserved.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// App Firestore DatabaseReference.
/// This class is used to define the app Firestore DatabaseReference.
abstract class DatabaseReference {
  static get storage => FirebaseStorage.instance.ref();
  static get users => FirebaseFirestore.instance.collection('users');
  static get posts => FirebaseFirestore.instance.collection('posts');
  static get studios => FirebaseFirestore.instance.collection('studios');
  static get hashtags => FirebaseFirestore.instance.collection('hashtags');
  static get chats => FirebaseFirestore.instance.collection('chats');
}
