import 'package:cloud_firestore/cloud_firestore.dart';

class HashtagModel {
  /// Common properties
  final String? id;
  final String? tagName;
  final String? authorId;
  final num? totalUsed;
  final Timestamp? createdAt;

  HashtagModel(
      {this.id, this.tagName, this.authorId, this.totalUsed, this.createdAt});

  factory HashtagModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;

    return HashtagModel(
      id: snap.id,
      tagName: doc['tagName'] ?? '',
      authorId: doc['authorId'] ?? '',
      totalUsed: doc['totalUsed'] ?? 0,
      createdAt: doc['createdAt'],
    );
  }
}
