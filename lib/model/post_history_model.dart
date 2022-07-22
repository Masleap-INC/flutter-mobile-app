import 'package:cloud_firestore/cloud_firestore.dart';

class PostHistoryModel {
  final String? id;
  final String? authorId;
  final String? imageUrl;
  final String? caption;
  final String? location;
  final Timestamp? createdAt;

  PostHistoryModel(
      {this.id,
      this.authorId,
      this.imageUrl,
      this.caption,
      this.location,
      this.createdAt});

  factory PostHistoryModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;

    return PostHistoryModel(
      id: snap.id,
      authorId: doc['authorId'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
      caption: doc['caption'] ?? '',
      location: doc['location'] ?? '',
      createdAt: doc['createdAt'],
    );
  }
}
