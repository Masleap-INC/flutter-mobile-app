import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../model/post_model.dart';
import '../../model/post_status.dart';
import '../../model/user_model.dart';
import '../values/database_references.dart';
import 'firestore_user_activity.dart';

class FirestorePost {
  final Reference _storageReference = FirebaseStorage.instance.ref();


  /// Create post/ stencils
  void createPost(Map<String, dynamic> data) {
    DatabaseReference.posts.add(data);
  }

  updatePost({required Map<String, dynamic> data,
    required String postId}) async {

    DatabaseReference.posts
        .doc(postId)
        .update(data);
  }

  /// Create stories video or images
  void createStory(
      {required String authorId, required Map<String, dynamic> data}) {
    DatabaseReference.users.doc(authorId).collection('stories').add(data);
  }

  /// Create comments on a post
  void createComment(
      {required String postId,
      required String authorId,
      required Map<String, dynamic> data}) async{
    DatabaseReference.posts
        .doc(postId)
        .collection('postComments')
        .add(data);

    DocumentSnapshot postDocumentSnapshot = await getPost(postId: postId);

    var post = PostModel.fromDoc(postDocumentSnapshot);

    var commentCount = post.commentCount ?? 0;

    DatabaseReference.posts
        .doc(postId)
        .update({'commentCount': commentCount + 1});

  }

  /// Create Hashtag of a post
  void createOrUpdateHashtag(
      {required String postId,
        required String authorId,
        required Map<String, dynamic> data}) async{
    DatabaseReference.posts
        .doc(postId)
        .collection('postComments')
        .add(data);

    DocumentSnapshot postDocumentSnapshot = await getPost(postId: postId);

    var post = PostModel.fromDoc(postDocumentSnapshot);

    var commentCount = post.commentCount ?? 0;

    DatabaseReference.posts
        .doc(postId)
        .update({'commentCount': commentCount + 1});

  }

  /// Get a post document
  Future<DocumentSnapshot> getPost({required String postId}) async {
    return await DatabaseReference.posts
        .doc(postId)
        .get();
  }


  /// Checking if the post is liked by the user
  Future<bool> getPostIsLiked(
      {required String postId, required String currentUserId}) async {

    DocumentSnapshot documentSnapshot = await DatabaseReference.posts
        .doc(postId)
        .collection('postLikes')
        .doc(currentUserId)
        .get();

    return documentSnapshot.exists;
  }

  /// Checking if the post is booked by the user
  Future<bool> getPostIsBooked(
      {required String postId, required String currentUserId}) async {
    DocumentSnapshot documentSnapshot = await DatabaseReference.users
        .doc(currentUserId)
        .collection('userBookmark')
        .doc(postId)
        .get();

    return documentSnapshot.exists;
  }

  /// Like the post
  Future<int?> likePost({required UserModel author,
    required UserModel currentUser,
    required String postId}) async {
    int? likeCount;
    try {
      DocumentSnapshot postDocumentSnapshot = await getPost(postId: postId);

      var post = PostModel.fromDoc(postDocumentSnapshot);

      likeCount = post.likeCount ?? 0;

      DatabaseReference.posts
          .doc(postId)
          .update({'likeCount': likeCount + 1});

      DatabaseReference.posts
          .doc(post.id)
          .collection('postLikes')
          .doc(currentUser.id!)
          .set({
            'likedBy': currentUser.id,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          });

      FirestoreUserActivity().addActivityItem(
        currentUserId: currentUser.id!,
        post: post,
        comment: post.caption,
        isFollowEvent: false,
        isLikeMessageEvent: false,
        isLikeEvent: true,
        isCommentEvent: false,
        isMessageEvent: false,
        receiverToken: author.deviceToken,
      );
      likeCount++;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed to like..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return likeCount;
  }

  /// Unlike the post
  Future<int?> unlikePost({required UserModel author,
    required UserModel currentUser,
    required String postId}) async {
    int? likeCount;
    try {
      DocumentSnapshot postDocumentSnapshot = await getPost(postId: postId);

      var post = PostModel.fromDoc(postDocumentSnapshot);

      likeCount = post.likeCount ?? 0;

      DatabaseReference.posts
          .doc(postId)
          .update({'likeCount': likeCount - 1});

      DatabaseReference.posts
          .doc(post.id)
          .collection('postLikes')
          .doc(currentUser.id!)
          .delete();

      FirestoreUserActivity().deleteActivityItem(
        comment: null,
        currentUserId: author.id!,
        isFollowEvent: false,
        post: post,
        isCommentEvent: false,
        isLikeMessageEvent: false,
        isLikeEvent: true,
        isMessageEvent: false,
      );
      likeCount--;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Failed to unlike..',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return likeCount;
  }


  /// Save the post into the users bookmark list
  bool createBookmark(
      {required UserModel currentUser, required PostModel post}) {
    try {
      var imageUrl = "";

      if(post.imageUrls!.isNotEmpty) {
        imageUrl = post.imageUrls![0];
      }else {
        imageUrl = currentUser.imageUrl ?? '';
      }

      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('userBookmark')
          .doc(post.id)
          .set({
        'imageUrl': imageUrl,
        'caption': post.caption,
        'authorId': post.authorId,
        'location': post.location,
        'createdAt': Timestamp.fromDate(DateTime.now())
      });
      return true;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Bookmark failed...',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Remove the post from the users bookmark list
  void removeBookmark({required String currentUserId, required String postId}) {
    DatabaseReference.users
        .doc(currentUserId)
        .collection('userBookmark')
        .doc(postId)
        .delete();
  }

  /// Move post to the users trash collection
  bool moveToTrash({required  UserModel currentUser, required PostModel post}) {

    try {
      var imageUrl = "";

      if(post.imageUrls!.isNotEmpty) {
        imageUrl = post.imageUrls![0];
      }else {
        imageUrl = currentUser.imageUrl ?? '';
      }

      /// Create trash in users->userDoc->userTrash->trashDoc
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('userTrash')
          .doc(post.id)
          .set({
        'imageUrl': imageUrl,
        'caption': post.caption,
        'authorId': post.authorId,
        'location': post.location,
        'createdAt': Timestamp.fromDate(DateTime.now())
      });

      /// Delete post from the user feed
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('userFeed')
          .doc(post.id).delete();

      /// Update original post
      DatabaseReference.posts
          .doc(post.id)
          .update({'status': PostStatus.deleted.name});

      return true;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Move to trash...',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

  }

  /// Move post to the users archive collection
  bool moveToArchive({required  UserModel currentUser, required PostModel post}) {

    try {
      var imageUrl = "";

      if(post.imageUrls!.isNotEmpty) {
        imageUrl = post.imageUrls![0];
      }else {
        imageUrl = currentUser.imageUrl ?? '';
      }

      /// Create trash in users->userDoc->archivedPosts->trashDoc
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('archivedPosts')
          .doc(post.id)
          .set({
        'imageUrl': imageUrl,
        'caption': post.caption,
        'authorId': post.authorId,
        'location': post.location,
        'createdAt': Timestamp.fromDate(DateTime.now())
      });

      /// Delete post from the user feed
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('userFeed')
          .doc(post.id).delete();

      /// Update original post
      DatabaseReference.posts
          .doc(post.id)
          .update({'status': PostStatus.archived.name});

      return true;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Move to archive...',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

  }

  /// Hide post from the users feed collection
  bool hideFeedPost({required  UserModel currentUser, required PostModel post}) {

    try {
      var imageUrl = "";

      if(post.imageUrls!.isNotEmpty) {
        imageUrl = post.imageUrls![0];
      }else {
        imageUrl = currentUser.imageUrl ?? '';
      }

      /// Create trash in users->userDoc->archivedPosts->trashDoc
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('hiddenPosts')
          .doc(post.id)
          .set({
        'imageUrl': imageUrl,
        'caption': post.caption,
        'authorId': post.authorId,
        'location': post.location,
        'createdAt': Timestamp.fromDate(DateTime.now())
      });

      /// Hide post from the user feed
      DatabaseReference.users
          .doc(currentUser.id!)
          .collection('userFeed')
          .doc(post.id)
          .update({'status': PostStatus.hidden.name});

      return true;
    } catch (error) {
      /// Extract the error message.
      String errorMessage =
      error.toString().substring(error.toString().indexOf(' ') + 1);

      /// Show the error message.
      Get.snackbar(
        'Move to archive...',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

  }



  /// Storage related methods: Image Upload
  Future<String> uploadImage(File imageFile) async {
    String photoId = const Uuid().v4();
    File image = await compressImage(photoId, imageFile);
    UploadTask uploadTask =
    _storageReference.child('images/posts/post_$photoId.jpg').putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }

  /// Compress images before uploading
  Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImageFile!;
  }

  /// Storage related methods: Video Upload
  Future<String> uploadVideo(File videoFile) async {
    String videoId = const Uuid().v4();

    UploadTask uploadTask =
    _storageReference.child('videos/posts/post_$videoId.mp4').putFile(
        videoFile);
    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }


  /// create postLink
  Future<String> createDynamicLink(UserModel currentUser, PostModel post) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://inkistry.page.link',
        link: Uri.parse(
            "https://www.inkistry.com/postsDetails/?authorId=${currentUser.id!}&postId=${post.id!}"),
        androidParameters: const AndroidParameters(
          packageName: 'com.masleap.inkistry',
          minimumVersion: 0,
        ),
        // iosParameters: const IOSParameters(
        //   bundleId: 'com.masleap.inkistry',
        //   minimumVersion: '0',
        // ),
        socialMetaTagParameters: SocialMetaTagParameters(
            imageUrl: post.imageUrls!.isNotEmpty
                ? Uri.parse(post.imageUrls![0])
                : null,
            title: post.caption!));

    final ShortDynamicLink shortLink =
    await dynamicLinks.buildShortLink(parameters);
    Uri url = shortLink.shortUrl;

    return "https://inkistry.page.link" + url.path;
  }





}
