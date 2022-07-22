/// Copyright, 2022, by the authors. All rights reserved.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/post_status.dart';
import '../../model/post_type.dart';
import 'database_references.dart';

/// App FirestoreQueries.
/// This class is used to define the app FirestoreQueries.
abstract class FirestoreQueries {
  /// Artist query get artist based on their creation date order.
  static Query artistsQuery() =>
      DatabaseReference.users.orderBy('createdAt', descending: true);

  static Query artistsSearchQuery(String key) => DatabaseReference.users
      .where('name', isGreaterThanOrEqualTo: key)
      .where('name', isLessThanOrEqualTo: '$key\uf8ff')
      .orderBy('name');

  /// Stencil query get stencils based on its creation date order.
  static Query stencilsQuery() => DatabaseReference.posts
      .where('postType', isEqualTo: PostType.stencil.name)
      .where('status', isEqualTo: PostStatus.published.name)
      .orderBy('createdAt', descending: true);

  static Query stencilsCategorySearchQuery(String category) => category !=
      'All'
      ? DatabaseReference.posts
      .where('category', isEqualTo: category)
      .where('postType', isEqualTo: PostType.stencil.name)
      .where('status', isEqualTo: PostStatus.published.name)
      .orderBy('createdAt', descending: true)
      : stencilsQuery();

  static Query stencilsSearchQuery(String key, String category) => category !=
          'All'
      ? DatabaseReference.posts
          .where('caption', isGreaterThanOrEqualTo: key)
          .where('caption', isLessThanOrEqualTo: '$key\uf8ff')
          .where('category', isEqualTo: category)
          .where('postType', isEqualTo: PostType.stencil.name)
          .where('status', isEqualTo: PostStatus.published.name)
          .orderBy('caption', descending: true)
      : DatabaseReference.posts
          .where('caption', isGreaterThanOrEqualTo: key)
          .where('caption', isLessThanOrEqualTo: '$key\uf8ff')
          .where('category', isEqualTo: category)
          .where('postType', isEqualTo: PostType.stencil.name)
          .where('status', isEqualTo: PostStatus.published.name)
          .orderBy('caption', descending: true);

  /// Studio query to get studios based on total members number.
  static Query studiosQuery() =>
      DatabaseReference.studios.orderBy('totalMember', descending: true);

  static Query studiosSearchQuery(String key) =>
      DatabaseReference.studios
          .where('title', isGreaterThanOrEqualTo: key)
          .where('title', isLessThanOrEqualTo: '$key\uf8ff')
          .orderBy('totalMember', descending: true);

  /// Hashtag query get hashtags based on its totalUsed on posts order.
  static Query hashtagsQuery() =>
      DatabaseReference.hashtags.orderBy('totalUsed', descending: true);

  static Query hashtagsSearchQuery(String key) => DatabaseReference.hashtags
      .where('tagName', isGreaterThanOrEqualTo: key)
      .where('tagName', isLessThanOrEqualTo: '$key\uf8ff')
      .orderBy('tagName', descending: true);

  /// Feed query get user feeds based on their createdAt date in descending order.
  static Query feedQuery(String id) => DatabaseReference.users
      .doc(id)
      .collection('userFeed')
      .where('status', isEqualTo: PostStatus.published.name)
      .orderBy('createdAt', descending: true);

  static Query postQuery(String id) => DatabaseReference.posts;

  static Query activitiesQuery(String id) => DatabaseReference.users
      .doc(id)
      .collection('userActivities')
      .orderBy('createdAt', descending: true);

  static Query commentsQuery(String id) => DatabaseReference.posts
      .doc(id)
      .collection('postComments')
      .orderBy('createdAt', descending: true);



  /// artists post query
  static Query artistsPostQuery(String id) => DatabaseReference.posts
      .where('authorId', isEqualTo: id)
      .where('status', isEqualTo: PostStatus.published.name)
      .orderBy('createdAt', descending: true);

  /// artists post query
  static Query artistsBookmarks(String id) => DatabaseReference.users
      .doc(id)
      .collection('userBookmark')
      .orderBy('createdAt', descending: true);

  static Query artistsArchivedPosts(String id) => DatabaseReference.users
      .doc(id)
      .collection('archivedPosts')
      .orderBy('createdAt', descending: true);

  static Query artistsHiddenPosts(String id) => DatabaseReference.users
      .doc(id)
      .collection('hiddenPosts')
      .orderBy('createdAt', descending: true);

  static Query artistsDeletedPosts(String id) => DatabaseReference.users
      .doc(id)
      .collection('userTrash')
      .orderBy('createdAt', descending: true);

  static Query artistsStencilsQuery(String id) => DatabaseReference.posts
      .where('authorId', isEqualTo: id)
      .where('postType', isEqualTo: PostType.stencil.name)
      .where('status', isEqualTo: PostStatus.published.name)
      .orderBy('createdAt', descending: true);

  /// reviews
  static Query artistsReviewsQuery(String id) => DatabaseReference.users
      .doc(id)
      .collection('usersReviews')
      .orderBy('createdAt', descending: true);

  /// followers
  static Query artistsFollowersQuery(String id) => DatabaseReference.users
      .doc(id)
      .collection('userFollowers')
      .orderBy('createdAt', descending: true);

  /// following
  static Query artistsFollowingQuery(String id) => DatabaseReference.users
      .doc(id)
      .collection('userFollowing')
      .orderBy('createdAt', descending: true);



  /// chat Tab query
  static Query latestChatQuery(String id) => DatabaseReference.chats
      .where('memberIds', arrayContains: id)
      .where('chatRequest', isEqualTo: false)
      .orderBy('recentTimestamp', descending: true);


  static Query chatRequestQuery(String id) => DatabaseReference.chats
      .where('memberIds', arrayContains: id)
      .where('chatRequest', isEqualTo: true)
      .orderBy('recentTimestamp', descending: true);


  /// DirectMessage query
  static Query directMessageQuery(String id) => DatabaseReference.chats
      .doc(id)
      .collection('messages')
      .orderBy('timeCreated', descending: true);



}
