import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;
  final String? authorId;
  final String? comments;
  final String? imageUrl;
  final num? likeCount;
  final num? replyCount;
  final Timestamp? updatedAt;
  final Timestamp? createdAt;

  CommentModel(
      {this.id,
      this.authorId,
      this.comments,
      this.imageUrl,
      this.likeCount,
      this.replyCount,
      this.updatedAt,
      this.createdAt});

  factory CommentModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;
    return CommentModel(
        id: snap.id,
        authorId: doc['authorId'],
        comments: doc['comments'],
        imageUrl: doc['imageUrl'],
        likeCount: doc['likeCount'],
        replyCount: doc['replyCount'],
        updatedAt: doc['updatedAt'],
        createdAt: doc['createdAt']);
  }
}
