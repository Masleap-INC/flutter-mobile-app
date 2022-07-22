/// Copyright, 2022, by the authors. All rights reserved.
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../view/auth/profile_photo_view.dart';
import '../../view/control_view.dart';
import '../services/local_storage_user.dart';
import '../services/firestore_user.dart';
import '../../model/user_model.dart';
import '../services/location_service.dart';

/// AuthViewModel is used to handle auth related operations.
/// It is used to sign in, sign out, and sign up.
/// Social login is used to sign in with facebook, google, and apple.
/// This class extends from GetxController.
/// It is used to listen to auth changes, and get current user.
/// It is used to get current user data, and set user data to local storage.
/// It is used to get current user location, and set user location to local storage.
class AuthViewModel extends GetxController {
  /// Auth form fields.
  /// These are used to store the values of the form fields.
  String? email, password, name;

  /// The isPrivacyPolicyChecked is used to store the value
  /// of the privacy policy checkbox.
  /// The isTermsOfServiceChecked is used to store the value
  RxBool isPrivacyPolicyChecked = false.obs;

  /// Rxn nullable _user Listens to observable (obs) changes.
  final Rxn<User>? user = Rxn<User>();

  /// FirebaseAuth instance.
  final _auth = FirebaseAuth.instance;

  /// RxString imagePatch Listens to observable (obs) changes.
  RxString imagePath = ''.obs;

  /// ImagePicker instance.
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    /// Binding an existing authStateChanged listener to keep
    /// the _user observable updated.
    user!.bindStream(_auth.authStateChanges());
  }

  /// Sign un with email and password.
  /// This method is used to sign up with email and password.
  void signUpWithEmailAndPassword() async {
    try {
      /// Create a new user with email and password.
      /// Then get the user data.
      await _auth
          .createUserWithEmailAndPassword(email: email!, password: password!)
          .then((user) async {
        /// Get the user current location.
        Position currentLocation = await currentPosition();

        /// username generation
        var username = email!.split('@')[0].toLowerCase() + Random().nextInt(1000).toString();

        /// Call the saveUser method to save the user data to firestore
        /// and local storage.
        saveUser(

            /// Create a new user model.
            UserModel(

                /// Get and set the user uid.
                id: user.user!.uid,

                /// Set the user name.
                name: name,
                username: username,

                /// Set the user email.
                email: email,
                imageUrl: '',
                coverImageUrl: '',
                bio: '',

                /// Get the user device token and set it to the user device token.
                deviceToken: await FirestoreUser().getDeviceToken(),
                isVerified: false,
                isBanned: false,
                isActive: true,
                isReady: false,

                /// By default, the user is not a moderator.
                role: 'user',
                shopName: '',
                ratingCount: 0.0,
                updatedAt: Timestamp.now(),
                isPrivacyPolicyChecked: true,

                /// Set the user location.
                location: GeoPoint(
                    currentLocation.latitude, currentLocation.longitude),
                createdAt: Timestamp.now()),

            /// Telling the saveUser method that it is a sign up.
            isSignUp: true);
      });
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
          error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed to login..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with email and password.
  /// This method is used to sign in with email and password.
  void signInWithEmailAndPassword() async {
    try {
      /// Sign in with email and password.
      /// Then get the user data.
      await _auth
          .signInWithEmailAndPassword(email: email!, password: password!)
          .then((user) {
        /// Update the user device token.
        FirestoreUser().updateDeviceToken(user.user!.uid);

        /// Get the user data from firestore using the user uid.
        FirestoreUser().getUser(user.user!.uid).then((doc) {
          /// Set the user data to the local storage.
          saveUserLocal(
              UserModel.fromJson(doc.data() as Map<String, dynamic>));
        });
      });
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
          error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed to login..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with google.
  /// This method is used to sign in with google.
  void signInWithGoogleAccount() async {
    try {
      /// Create a google sign in instance. with scopes.
      GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

      /// Sign in with google.
      final GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();

      /// Authenticate with google.
      GoogleSignInAuthentication _googleSignInAuthentication =
          await _googleUser!.authentication;

      /// Create a credential with google sign in authentication.
      final _googleAuthCredential = GoogleAuthProvider.credential(
        idToken: _googleSignInAuthentication.idToken,
        accessToken: _googleSignInAuthentication.accessToken,
      );

      /// Sign in with google credential.
      /// Then get the user data.
      await _auth
          .signInWithCredential(_googleAuthCredential)
          .then((user) async {
        /// Get the user current location.
        Position currentLocation = await currentPosition();

        /// Trying to get the user data from firestore using the user uid.
        DocumentSnapshot userDocSnapshot =
            await FirestoreUser().getUser(user.user!.uid);

        /// If the user data is not null.
        /// Then Update the user device token.
        /// Else, save the user data to firestore and local storage.
        if (userDocSnapshot.exists) {
          /// Update the user device token.
          FirestoreUser().updateDeviceToken(user.user!.uid);

          /// Navigate to the home screen.
          Get.offAll(const ControlView());
        } else {

          /// username generation
          var username = _googleUser.email.split('@')[0].toLowerCase() + Random().nextInt(1000).toString();

          /// Call the saveUser method to save the user data to firestore
          /// and local storage.
          saveUser(

              /// Create a new user model.
              UserModel(

                  /// Get and set the user uid.
                  id: user.user!.uid,

                  /// Get the user display name from the google user.
                  name: _googleUser.displayName ?? "User",
                  username: username,

                  /// Get the user email from the google user.
                  email: _googleUser.email,

                  /// Get the user image url from the google user.
                  imageUrl: _googleUser.photoUrl,
                  coverImageUrl: '',
                  bio: '',

                  /// Get the user device token and set it to the user device token.
                  deviceToken: await FirestoreUser().getDeviceToken(),
                  isVerified: false,
                  isBanned: false,
                  isActive: true,
                  isReady: false,

                  /// By default, the user is not a moderator.
                  role: 'user',
                  shopName: '',
                  ratingCount: 0.0,
                  updatedAt: Timestamp.now(),
                  isPrivacyPolicyChecked: true,

                  /// Set the user location.
                  location: GeoPoint(
                      currentLocation.latitude, currentLocation.longitude),
                  createdAt: Timestamp.now()));
        }
      });
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
          error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed to login..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with facebook.
  /// This method is used to sign in with facebook.
  void signInWithFacebookAccount() async {
    try {
      /// Create a facebook sign in instance.
      final _facebookSignIn = await FacebookAuth.instance.login(
          permissions: [
            'email', 'public_profile', 'user_birthday'
          ]
      );

      /// Get the facebook auth credential using the facebook sign in
      /// access token.
      final _facebookAuthCredential =
          FacebookAuthProvider.credential(_facebookSignIn.accessToken!.token);

      /// Sign in with facebook credential.
      /// Then get the user data.
      await _auth
          .signInWithCredential(_facebookAuthCredential)
          .then((user) async {
        /// Get user data from the Facebook Auth instance.
        final userData = await FacebookAuth.instance
            .getUserData(fields: "id,name,email,picture.type(large)");

        /// Get the user current location.
        Position currentLocation = await currentPosition();

        /// Get the user data from firestore using the user uid.
        DocumentSnapshot userDocSnapshot =
            await FirestoreUser().getUser(user.user!.uid);

        /// If the user data is not null.
        /// Then Update the user device token.
        /// Else, save the user data to firestore and local storage.
        if (userDocSnapshot.exists) {
          /// Update the user device token.
          FirestoreUser().updateDeviceToken(user.user!.uid);

          /// Navigate to the home screen.
          Get.offAll(const ControlView());
        } else {
          /// username generation
          var username = userData["email"]!.split('@')[0].toLowerCase() + Random().nextInt(1000).toString();

          /// Call the saveUser method to save the user data to firestore
          /// and local storage.
          saveUser(

              /// Create a new user model.
              UserModel(

                  /// Get and set the user uid.
                  id: user.user!.uid,

                  /// Get the user name from the facebook user data.
                  name: userData["name"],
                  username: username,

                  /// Get the user email from the facebook user data.
                  email: userData["email"],

                  /// Get the user image url from the facebook user data.
                  imageUrl: userData["picture"]["data"]["url"],
                  coverImageUrl: '',
                  bio: '',

                  /// Get the user device token and set it to the user device token.
                  deviceToken: await FirestoreUser().getDeviceToken(),
                  isVerified: false,
                  isBanned: false,
                  isActive: true,

                  /// By default, the user is not a moderator.
                  role: 'user',
                  shopName: '',
                  ratingCount: 0.0,
                  updatedAt: Timestamp.now(),
                  isPrivacyPolicyChecked: true,

                  /// Set the user location.
                  location: GeoPoint(
                      currentLocation.latitude, currentLocation.longitude),
                  createdAt: Timestamp.now()));
        }
      });    } catch (error) {
      /// Show the error message.
      Get.snackbar(
        'Failed to login..',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

  }

  /// This function is used to send password reset email.
  void sendPasswordResetLink() async {
    try {
      /// Sending the password reset email.
      await _auth.sendPasswordResetEmail(email: email!);
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
          error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed!!..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// This function is used to sign out.
  void signOut() async {
    try {
      /// Sign out from firebase.
      await _auth.signOut();

      /// Remove the user data from the local storage.
      LocalStorageUser.clearUserData();
      await Get.deleteAll(force: true);
      Phoenix.rebirth(Get.context!);
      Get.reset();
    } catch (error) {
      /// Printing the error message.
      /// If the app is in debug mode, then print the error message.
      if (kDebugMode) {
        print(error);
      }
    }
  }

  /// This function is used to save the user data to firestore and local storage.
  void saveUser(UserModel _userModel, {bool isSignUp = false}) async {
    /// Checking if the username is unique.
    /// If the username is unique, then save the user data to firestore and local storage.
    if (await FirestoreUser().checkUsernameAvailability(_userModel)) {
      /// Save the user data to firestore.
      FirestoreUser().createUser(_userModel);

      /// Check if the user is signing up.
      /// If the user is signing up, then navigate to the Profile photo uploading
      /// screen.
      /// else, Save the user data to local storage.
      if (isSignUp) {
        /// Navigate to the Profile photo uploading screen.
        Get.offAll(() => const ProfilePhotoView());
      } else {
        /// Save the user data to local storage.
        saveUserLocal(_userModel);
      }
    } else {
      /// Show the error message.
      Get.snackbar(
        'Failed to login..',
        'Username not available',
        snackPosition: SnackPosition.BOTTOM,
      );

      /// Call the signOut method to sign out.
      signOut();
    }
  }

  /// Save the user data to local storage.
  void saveUserLocal(UserModel userModel) async {
    /// Save the user data to local storage.
    LocalStorageUser.setUserData(userModel);

    /// Navigate to the home screen.
    Get.offAll(const ControlView());
  }

  /// This method is used to pick the user profile photo from the gallery.
  void pickGalleryImage() async {
    /// XFile Picker is used to pick the image from the gallery.
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    /// If the picked file is not null.
    /// Then set the picked file path to the imagePath variable.
    /// Else, show the error message.
    if (pickedFile != null) {
      /// Set the picked file path to the imagePath variable.
      imagePath.value = pickedFile.path;
    } else {
      /// Show the error message.
      Get.snackbar(
        'Message!!',
        'No image selected.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// This method is used to upload the user profile photo to firestore.
  void uploadUserImage() async {
    /// Checking if the image path is not null.
    /// If the image path is not null, then upload the image to firestore.
    /// Else, show the error message.
    if (imagePath.value != '') {
      /// Get current user from the firebase auth instance.
      User? user = FirebaseAuth.instance.currentUser;

      /// Uploading the image to firestore.
      await FirestoreUser()
          .uploadUserProfileImageFromFile(null, File(imagePath.value));

      /// Get the user data from firestore using the user uid.
      FirestoreUser().getUser(user!.uid).then((doc) {
        /// Saving the user data to local storage.
        saveUserLocal(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      });
    } else {
      /// Show the error message.
      Get.snackbar(
        'Message!!',
        'No image selected.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
