import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inkistry/model/post_model.dart';

import '../values/database_references.dart';

class FirestoreUserActivity {

  void addActivityItem({
    String? currentUserId,
    PostModel? post,
    String? comment,
    bool? isFollowEvent,
    bool? isCommentEvent,
    bool? isLikeEvent,
    bool? isMessageEvent,
    bool? isLikeMessageEvent,
    String? receiverToken,
  }) {
    if (currentUserId != post!.authorId) {
      var timeCreated = Timestamp.fromDate(DateTime.now());

      DatabaseReference.users
          .doc(post.authorId)
          .collection('userActivities')
          .add({
        'fromUserId': currentUserId,
        'postId': post.id,
        'postImageUrls': post.imageUrls,
        'comment': comment,
        'createdAt': timeCreated,
        'isFollowEvent': isFollowEvent,
        'isCommentEvent': isCommentEvent,
        'isLikeEvent': isLikeEvent,
        'isMessageEvent': isMessageEvent,
        'isLikeMessageEvent': isLikeMessageEvent,
        'receiverToken': receiverToken,
      });
    }
  }

  void deleteActivityItem(
      {String? currentUserId,
      PostModel? post,
      String? comment,
      bool? isFollowEvent,
      bool? isCommentEvent,
      bool? isLikeEvent,
      bool? isMessageEvent,
      bool? isLikeMessageEvent}) async {
    String? boolCondition;

    if (isFollowEvent!) {
      boolCondition = 'isFollowEvent';
    } else if (isCommentEvent!) {
      boolCondition = 'isCommentEvent';
    } else if (isLikeEvent!) {
      boolCondition = 'isLikeEvent';
    } else if (isMessageEvent!) {
      boolCondition = 'isMessageEvent';
    } else if (isLikeMessageEvent!) {
      boolCondition = 'isLikeMessageEvent';
    }

    QuerySnapshot activities = await DatabaseReference.users
        .doc(post!.authorId)
        .collection('userActivities')
        .where('fromUserId', isEqualTo: currentUserId)
        .where('postId', isEqualTo: post.id)
        .where(boolCondition!, isEqualTo: true)
        .get();

    for (var element in activities.docs) {
      DatabaseReference.users
          .doc(post.authorId)
          .collection('userActivities')
          .doc(element.id)
          .delete();
    }
  }
}
