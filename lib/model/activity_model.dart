import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? id;
  final String? fromUserId;
  final String? postId;
  final String? postImageUrl;
  final String? comment;
  final bool? isFollowEvent;
  final bool? isLikeEvent;
  final bool? isMessageEvent;
  final bool? isCommentEvent;
  final bool? isLikeMessageEvent;
  final String? receiverToken;
  final Timestamp? timestamp;

  ActivityModel({
    this.id,
    this.fromUserId,
    this.postId,
    this.postImageUrl,
    this.comment,
    this.timestamp,
    this.isFollowEvent,
    this.isLikeEvent,
    this.isMessageEvent,
    this.isCommentEvent,
    this.isLikeMessageEvent,
    this.receiverToken,
  });

  factory ActivityModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String,dynamic>;
    return ActivityModel(
      id: snap.id,
      fromUserId: doc['fromUserId'],
      postId: doc['postId'],
      postImageUrl: doc['postImageUrl'],
      comment: doc['comment'],
      timestamp: doc['createdAt'],
      isFollowEvent: doc['isFollowEvent'] ?? false,
      isCommentEvent: doc['isCommentEvent'] ?? false,
      isLikeEvent: doc['isLikeEvent'] ?? false,
      isMessageEvent: doc['isMessageEvent'] ?? false,
      isLikeMessageEvent: doc['isMessageEvent'] ?? false,
      receiverToken: doc['receiverToken'] ?? '',
    );
  }
}
