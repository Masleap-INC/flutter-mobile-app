import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  /// Common properties
  final String? id;
  final String? authorId;
  final String? videoUrl;
  final List? taggedPeopleList;
  final String? caption;
  final int? likeCount;
  final int? commentCount;
  final int? shareCount;
  final String? location;
  final bool? commentsAllowed;
  final String? postType;
  final String? captureType;
  final String? status;
  final Timestamp? createdAt;
  final Timestamp? updateAt;

  /// Posts properties
  /// imageUrls.length == 0 ? Stencil : Post
  final List? imageUrls;

  /// Stencils properties
  final String? shopName;
  final String? category;
  final bool? isPremium;

  PostModel(
      {this.id,
      this.authorId,
      this.imageUrls,
      this.videoUrl,
      this.taggedPeopleList,
      this.caption,
      this.likeCount,
      this.commentCount,
      this.shareCount,
      this.location,
      this.shopName,
      this.category,
      this.isPremium,
      this.commentsAllowed,
      this.postType,
      this.captureType,
      this.status,
      this.createdAt,
      this.updateAt});

  factory PostModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;

    return PostModel(
      id: snap.id,
      authorId: doc['authorId'] ?? '',
      imageUrls: doc['imageUrls'] ?? [],
      videoUrl: doc['videoUrl'] ?? '',
      taggedPeopleList: doc['taggedPeopleList'] ?? [],
      caption: doc['caption'] ?? '',
      likeCount: doc['likeCount'] ?? 0,
      commentCount: doc['commentCount'] ?? 0,
      shareCount: doc['shareCount'] ?? 0,
      location: doc['location'] ?? '',
      shopName: doc['shopName'] ?? '',
      category: doc['category'] ?? '',
      isPremium: doc['isPremium'] ?? false,
      commentsAllowed: doc['commentsAllowed'] ?? true,
      postType: doc['postType'],
      captureType: doc['captureType'] ?? '',
      status: doc['status'] ?? '',
      createdAt: doc['createdAt'],
      updateAt: doc['updateAt'],
    );
  }

  static get stencilCatList => [
        'Abstract',
        'Geometric',
        'Tribal',
        'Minimalistic',
        'Black & Grey',
      ];
}
