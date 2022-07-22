import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {

  static final storageRef = FirebaseStorage.instance.ref();

  // Upload user image from file
  static Future<String> uploadUserProfileImageFromFile(
      String? url, File imageFile) async {
    String? photoId = const Uuid().v4();

    if (url != null && url.contains('userProfile_')) {
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      photoId = exp.firstMatch(url)![1];
    }

    File image = await compressImage(photoId!, imageFile);
    UploadTask uploadTask = storageRef
        .child('images/users/userProfile_$photoId.jpg')
        .putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  // Upload and update userImage from file or url
  static Future<String> uploadUserProfileImageFromFileOrURL(
      String url, File imageFile) async {
    String? photoId = const Uuid().v4();

    if (url.isNotEmpty && url.contains('userProfile_')) {
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      photoId = exp.firstMatch(url)![1];
    }

    File image = await compressImage(photoId!, imageFile);
    UploadTask uploadTask = storageRef
        .child('images/users/userProfile_$photoId.jpg')
        .putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  // Upload and update userCoverImage from file or Url
  static Future<String> uploadUserCoverImageFromFileOrURL(
      String url, File imageFile) async {
    String? photoId = const Uuid().v4();

    if (url.isNotEmpty && url.contains('userCover_')) {
      RegExp exp = RegExp(r'userCover_(.*).jpg');
      photoId = exp.firstMatch(url)![1];
    }

    File image = await compressImage(photoId!, imageFile);
    UploadTask uploadTask = storageRef
        .child('images/users/userCover_$photoId.jpg')
        .putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }


  static Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImageFile!;
  }

  static Future<String> _uploadImage(
      String path, String imageId, File image) async {

    UploadTask uploadTask = storageRef.child(path).putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  static Future<String> uploadPost(File imageFile) async {
    String photoId = const Uuid().v4();
    File image = await compressImage(photoId, imageFile);
    UploadTask uploadTask =
    storageRef.child('images/posts/post_$photoId.jpg').putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  static Future<String> uploadVideo(File videoFile) async {
    String videoId = const Uuid().v4();

    UploadTask uploadTask =
    storageRef.child('videos/posts/post_$videoId.mp4').putFile(videoFile);
    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  static Future<String> uploadMessageImage(File imageFile) async {
    String imageId = const Uuid().v4();
    File image = await compressImage(imageId, imageFile);
    String downloadUrl = await _uploadImage(
      'images/messages/message_$imageId.jpg',
      imageId,
      image,
    );
    return downloadUrl;
  }

  static Future<String> uploadStoryImage(File imageFile) async {
    String imageId = const Uuid().v4();
    File image = await compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
      'images/stories/story_$imageId.jpg',
      imageId,
      image,
    );
    return downloadUrl;
  }

}
