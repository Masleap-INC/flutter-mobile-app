/// Copyright, 2022, by the authors. All rights reserved.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/database_references.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../model/user_model.dart';

/// Local storage user is used to store and retrieve user data from local storage.
class LocalStorageUser {

  /// Set user data to local storage.
  static setUserData(UserModel userModel) async {
    /// Get shared preferences instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /// Set user data to local storage.
    await prefs.setString('user', json.encode(userModel.toJson()));
  }

  /// Get user data from local storage.
  static Future<UserModel> getUserData() async {
    /// Get shared preferences instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /// Return user data from local storage.
    UserModel user = UserModel.fromJson(
        json.decode(prefs.getString('user')!) as Map<String, dynamic>);

    if(user.id == null) {
      try {

        if(FirebaseAuth.instance.currentUser != null) {
          DocumentSnapshot docSnap = DatabaseReference.users.doc(FirebaseAuth.instance.currentUser!.uid).get();
          if(docSnap.exists) {
            docSnap.reference.delete();
          }
          await FirebaseAuth.instance.currentUser!.delete();
        }

        clearUserData();
        await Get.deleteAll(force: true);
        Phoenix.rebirth(Get.context!);
        Get.reset();
      } catch (error) {
        clearUserData();
        await Get.deleteAll(force: true);
        Phoenix.rebirth(Get.context!);
        Get.reset();
      }
    }

    return user;
  }

  /// Remove user data from local storage.
  static clearUserData() async {
    /// Get shared preferences instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /// Remove user data from local storage.
    await prefs.clear();
  }

}
