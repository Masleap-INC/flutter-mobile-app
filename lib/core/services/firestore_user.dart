/// Copyright, 2022, by the authors. All rights reserved.
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:inkistry/core/values/database_references.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import 'firestore_user_activity.dart';


/// FirestoreUser is used to handle firestore user related operations.
/// It is used to create, read, update, and delete user data.
/// It is used to upload user profile image, and get user profile image.
/// It is used to get user data, and get user data by user id.
class FirestoreUser {
  /// FirebaseCloudMessaging instance.
  /// It is used to get the current user's token.
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FirebaseStorage instance.
  /// It is used to upload files to firebase storage.
  final Reference _storageReference = FirebaseStorage.instance.ref();


  /// This function is used to check if the newly generated username is unique.
  Future<bool> checkUsernameAvailability(UserModel userModel) async {

    /// Generate a random username.
    var username =
        userModel.name!.toLowerCase() + Random().nextInt(1000).toString();

    /// Check if the username is unique.
    final QuerySnapshot result =
        await DatabaseReference.users.where('username', isEqualTo: username).get();

    /// If the username is unique, return true.
    /// If the username is not unique, return false.
    return result.docs.isEmpty;
  }

  /// This function is used to create a new user.
  /// It is used to create a new user in firestore.
  createUser(UserModel userModel) async {
    await DatabaseReference.users.doc(userModel.id).set(userModel.toJson());
  }

  /// This function is used to get user data by user id.
  Future<DocumentSnapshot> getUser(String uid) async {
    return await DatabaseReference.users.doc(uid).get();
  }

  /// This function is used to get all users data by users id.
  Future<List<UserModel>> getUsers(List<dynamic> uIds) async {

    List<UserModel> users = [];

    for(String uid in uIds){
      DocumentSnapshot userDocSnapshot = await DatabaseReference.users.doc(uid).get();
      UserModel user = UserModel.fromDoc(userDocSnapshot);
      users.add(user);
    }

    return users;
  }

  /// This function is used to get users current device token.
  Future<String> getDeviceToken() async {
    String? token = await _messaging.getToken();
    return token!;
  }

  /// Update user information
  updateUserInformation(UserModel user, Map<String, dynamic> data) async {
    final userDoc = await DatabaseReference.users.doc(user.id).get();
    if (userDoc.exists) {
      UserModel user = UserModel.fromDoc(userDoc);
      DatabaseReference.users.doc(user.id).update(data);
    }
  }

  /// This function is used to update an existing user device token.
  updateDeviceToken(String uid) async {
    /// get the current device token.
    final token = await _messaging.getToken();
    /// get the user data.
    final userDoc = await DatabaseReference.users.doc(uid).get();
    /// If the user data is not null, update the device token.
    if (userDoc.exists) {
      /// parse the user data.
      UserModel user = UserModel.fromDoc(userDoc);
      /// If current device token is not equal to the user device token,
      /// update the device token.
      if (token != user.deviceToken) {
        /// update the device token.
        DatabaseReference.users.doc(uid).update({'deviceToken': token});
      }
    }
  }

  /// This function is used to remove an existing user device token.
  removeDeviceToken(String uid) async {
    await DatabaseReference.users.doc(uid).set({'deviceToken': ''});
  }

  /// This function is used to upload user profile image.
  /// It is used to upload user profile image to firebase storage.
  /// It takes image url and image file as parameters.
  /// The parameter url is nullable.
  /// If the url is null, it will upload the image file.
  /// Else it will get the filename from the url and
  /// upload the image file with the same filename.
  Future<void> uploadUserProfileImageFromFile(
      String? url, File imageFile) async {

    /// Define a random photoId.
    String? photoId = const Uuid().v4();

    /// If the url is null, and url contains userProfile_ string.
    if (url != null && url.contains('userProfile_')) {
      /// Regular expression to get the filename from the url.
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      /// Get the filename from the url.
      photoId = exp.firstMatch(url)![1];
    }

    /// Compress the image file. With quality 50.
    File image = await compressImage(photoId!, imageFile);
    /// Upload the image file to firebase storage.
    /// Path is images/users/userProfile_ + photoId + .jpg
    UploadTask uploadTask = _storageReference
        .child('images/users/userProfile_$photoId.jpg')
        .putFile(image);

    /// Wait for the upload to finish.
    /// When the upload is finished, get the download url.
    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    /// Update the user profile image url.
    await updateUserImage(downloadUrl);

  }


  Future<void> uploadUserCoverImageFromFile(
      String? url, File imageFile) async {

    /// Define a random photoId.
    String? photoId = const Uuid().v4();

    /// If the url is null, and url contains userCover_ string.
    if (url != null && url.contains('userCover_')) {
      /// Regular expression to get the filename from the url.
      RegExp exp = RegExp(r'userCover_(.*).jpg');
      /// Get the filename from the url.
      photoId = exp.firstMatch(url)![1];
    }

    /// Compress the image file. With quality 50.
    File image = await compressImage(photoId!, imageFile);
    /// Upload the image file to firebase storage.
    /// Path is images/users/userCover_ + photoId + .jpg
    UploadTask uploadTask = _storageReference
        .child('images/users/userCover_$photoId.jpg')
        .putFile(image);

    /// Wait for the upload to finish.
    /// When the upload is finished, get the download url.
    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    /// Update the user cover image url.
    await updateCoverImage(downloadUrl);

  }


  /// This function is used to compress the image file.
  Future<File> compressImage(String photoId, File image) async {
    /// Get the application temporary directory.
    final tempDir = await getTemporaryDirectory();
    /// Get the temporary path.
    final path = tempDir.path;
    /// Get the image file from absolute path to temporary path.
    /// The image file is compressed.
    /// The image file is saved in the temporary path.
    /// Quality is 50.
    File? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 50,
    );
    /// The image file is returned.
    return compressedImageFile!;
  }

  /// This function is used to update the user profile image url.
  /// It is used to update the user profile image url in firestore.
  Future<void> updateUserImage(String imageUrl) async {
    /// Get the current user.
    User? user = FirebaseAuth.instance.currentUser;
    /// If the user is not null, update the user profile image url.
    if (user != null) {
      await DatabaseReference.users.doc(user.uid).update({
        'imageUrl': imageUrl,
      });

    }
  }

  Future<void> updateCoverImage(String imageUrl) async {
    /// Get the current user.
    User? user = FirebaseAuth.instance.currentUser;
    /// If the user is not null, update the user profile image url.
    if (user != null) {
      await DatabaseReference.users.doc(user.uid).update({
        'coverImageUrl': imageUrl,
      });

    }
  }

  /// Artist section: Follow user
  Future<bool> getUserIsFollowed(
      {required String artistId, required String currentUserId}) async {

    DocumentSnapshot documentSnapshot = await DatabaseReference.users
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(artistId)
        .get();

    return documentSnapshot.exists;
  }


  /// Follow an artis
  void followUser({required UserModel artistUser, required UserModel currentUser}) async{

    DatabaseReference.users
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(artistUser.id)
        .set({
          'followedBy': artistUser.id,
          'createdAt': Timestamp.fromDate(DateTime.now())
        });

    // Add current user to user's followers collection
    DatabaseReference.users
        .doc(artistUser.id)
        .collection('userFollowers')
        .doc(currentUser.id)
        .set({
          'followedBy': currentUser.id,
          'createdAt': Timestamp.fromDate(DateTime.now())
        });

    PostModel post = PostModel(
      authorId: artistUser.id,
    );

    FirestoreUserActivity().addActivityItem(
      currentUserId: currentUser.id!,
      post: post,
      comment: null,
      isFollowEvent: true,
      isLikeMessageEvent: false,
      isLikeEvent: false,
      isCommentEvent: false,
      isMessageEvent: false,
      receiverToken: artistUser.deviceToken,
    );

  }

  /// Unfollow an artist
  void unfollowUser({required UserModel artistUser, required UserModel currentUser}) async {
    // Remove user from current user's following collection
    await DatabaseReference.users
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(artistUser.id)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

    // Remove current user from user's followers collection
    await DatabaseReference.users
        .doc(artistUser.id)
        .collection('userFollowers')
        .doc(currentUser.id)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });


    PostModel post = PostModel(
      authorId: artistUser.id,
    );

    FirestoreUserActivity().addActivityItem(
      currentUserId: currentUser.id!,
      post: post,
      comment: null,
      isFollowEvent: true,
      isLikeMessageEvent: false,
      isLikeEvent: false,
      isCommentEvent: false,
      isMessageEvent: false,
      receiverToken: artistUser.deviceToken,
    );

  }

  /// Unfollow an artist
  void removeFollower({required UserModel artistUser, required UserModel currentUser}) async {
    // Remove user from current user's following collection
    await DatabaseReference.users
        .doc(artistUser.id)
        .collection('userFollowing')
        .doc(currentUser.id)//
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Remove current user from user's followers collection
    await DatabaseReference.users
        .doc(currentUser.id)//
        .collection('userFollowers')
        .doc(artistUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });


    PostModel post = PostModel(
      authorId: artistUser.id,//
    );

    FirestoreUserActivity().addActivityItem(
      currentUserId: currentUser.id!,
      post: post,
      comment: null,
      isFollowEvent: true,
      isLikeMessageEvent: false,
      isLikeEvent: false,
      isCommentEvent: false,
      isMessageEvent: false,
      receiverToken: artistUser.deviceToken,
    );

  }


  /// create user profile link
  Future<String> createDynamicLink(UserModel currentUser) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://inkistry.page.link',
        link: Uri.parse(
            "https://www.inkistry.com/userDetails/?userId=${currentUser.id!}"),
        androidParameters: const AndroidParameters(
          packageName: 'com.masleap.inkistry',
          minimumVersion: 0,
        ),
        // iosParameters: const IOSParameters(
        //   bundleId: 'com.masleap.inkistry',
        //   minimumVersion: '0',
        // ),
        socialMetaTagParameters: SocialMetaTagParameters(
            imageUrl: currentUser.imageUrl!.isNotEmpty
                ? Uri.parse(currentUser.imageUrl!)
                : null,
            title: currentUser.bio!.isNotEmpty ? currentUser.bio! : 'Inkistry user!!'));

    final ShortDynamicLink shortLink =
    await dynamicLinks.buildShortLink(parameters);
    Uri url = shortLink.shortUrl;

    return "https://inkistry.page.link" + url.path;
  }


}
