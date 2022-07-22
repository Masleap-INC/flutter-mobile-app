import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:inkistry/model/message_model.dart';
import 'package:inkistry/model/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../model/chat_model.dart';
import '../../model/post_model.dart';
import '../values/database_references.dart';
import 'firestore_user_activity.dart';

class FirestoreChat {
  final Reference _storageReference = FirebaseStorage.instance.ref();

  Future<ChatModel> createChat(String requestedUserId,
      List<UserModel> users, List<String> userIds) async {
    Map<String, dynamic> readStatus = {};

    for (UserModel user in users) {
      readStatus[user.id!] = false;
    }

    Timestamp timestamp = Timestamp.now();

    DocumentReference res = await DatabaseReference.chats.add({
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'requestedBy': requestedUserId,
      'chatRequest': users.length > 2? false : true,
      'recentTimestamp': timestamp,
      'memberIds': userIds,
      'readStatus': readStatus,
    });

    return ChatModel(
      id: res.id,
      recentMessage: 'Chat Created',
      recentSender: '',
      recentTimestamp: timestamp,
      memberIds: userIds,
      readStatus: readStatus,
      memberInfo: users,
    );
  }

  sendChatMessage(
      ChatModel chat, MessageModel message, List<UserModel> receiverUsers) {

    DatabaseReference.chats.doc(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrls': message.imageUrls,
      'timeCreated': message.timeCreated,
      'isLiked': message.isLiked ?? false,
      'giphyUrl': message.giphyUrl,
    });

    for(UserModel receiverUser in receiverUsers) {
      PostModel post = PostModel(
        authorId: receiverUser.id,
      );

      FirestoreUserActivity().addActivityItem(
        currentUserId: message.senderId,
        post: post,
        comment: message.text,
        isFollowEvent: false,
        isLikeMessageEvent: false,
        isLikeEvent: false,
        isCommentEvent: false,
        isMessageEvent: true,
        receiverToken: receiverUser.deviceToken,
      );
    }
  }

  sendGroupChatMessage(
      ChatModel chat, MessageModel message, List<UserModel> receiverUsers) {

    DatabaseReference.chats.doc(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrls': message.imageUrls,
      'timeCreated': message.timeCreated,
      'isLiked': message.isLiked ?? false,
      'giphyUrl': message.giphyUrl,
    });

    for(UserModel receiverUser in receiverUsers) {
      PostModel post = PostModel(
        authorId: receiverUser.id,
      );

      FirestoreUserActivity().addActivityItem(
        currentUserId: message.senderId,
        post: post,
        comment: message.text,
        isFollowEvent: false,
        isLikeMessageEvent: false,
        isLikeEvent: false,
        isCommentEvent: false,
        isMessageEvent: true,
        receiverToken: receiverUser.deviceToken,
      );
    }

  }


  Future<ChatModel?> getChatByUsers(List<String> users) async {
    QuerySnapshot snapshot =
        await DatabaseReference.chats.where('memberIds', whereIn: [
      //[users[1], users[0]]
          users.reversed.toList()
    ]).get();

    if (snapshot.docs.isEmpty) {
      snapshot = await DatabaseReference.chats.where('memberIds', whereIn: [
        //[users[0], users[1]]
        users
      ]).get();
    }

    if (snapshot.docs.isNotEmpty) {
      return ChatModel.fromDoc(snapshot.docs[0]);
    }
    return null;
  }

  void setChatRead(String currentUserId, ChatModel chat, bool read) async {
    DatabaseReference.chats.doc(chat.id).update({
      'readStatus.$currentUserId': read,
    });
  }



  Future<void> likeUnlikeMessage(MessageModel message, String chatId,
      bool isLiked, UserModel receiverUser, String currentUserId) async {

    DatabaseReference.chats
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .update({'isLiked': isLiked});

    PostModel post = PostModel(
      authorId: receiverUser.id,
    );

    if (isLiked == true) {
      FirestoreUserActivity().addActivityItem(
        currentUserId: currentUserId,
        post: post,
        comment: message.text,
        isFollowEvent: false,
        isLikeMessageEvent: true,
        isLikeEvent: false,
        isCommentEvent: false,
        isMessageEvent: true,
        receiverToken: receiverUser.deviceToken,
      );
    } else {
      FirestoreUserActivity().addActivityItem(
        currentUserId: currentUserId,
        post: post,
        comment: message.text,
        isFollowEvent: false,
        isLikeMessageEvent: true,
        isLikeEvent: false,
        isCommentEvent: false,
        isMessageEvent: true,
      );
    }
  }



  Future<String> uploadMessageImage(File imageFile) async {
    String imageId = const Uuid().v4();
    File image = await compressImage(imageId, imageFile);
    String downloadUrl = await _uploadImage(
      'images/messages/message_$imageId.jpg',
      imageId,
      image,
    );
    return downloadUrl;
  }

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

  Future<String> _uploadImage(String path, String imageId, File image) async {
    UploadTask uploadTask = _storageReference.child(path).putFile(image);

    String downloadUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());

    return downloadUrl;
  }
}
