import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late final String? id;
  late final String? name;
  late final String? username;
  late final String? email;
  late final String? coverImageUrl;
  late final String? imageUrl;
  late final String? bio;
  late final String? deviceToken;
  late final bool? isBanned;
  late final bool? isVerified;
  late final bool? isActive;
  late final bool? isReady;
  late final bool? haveNewActivity;
  late final String? role;
  late final bool? isPrivacyPolicyChecked;
  late final GeoPoint? location;
  late final Timestamp? createdAt;
  late final Timestamp? updatedAt;
  late final String? shopName;
  late final num? ratingCount;
  late final num? postCount;
  late final num? stencilsCount;
  late final num? followerCount;
  late final num? followingCount;

  UserModel(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.coverImageUrl,
      this.imageUrl,
      this.bio,
      this.deviceToken,
      this.isBanned,
      this.isVerified,
      this.isActive,
      this.isReady,
        this.haveNewActivity,
      this.role,
      this.isPrivacyPolicyChecked,
      this.location,
      this.createdAt,
      this.updatedAt,
      this.shopName,
      this.ratingCount,
      this.postCount,
      this.stencilsCount,
      this.followerCount,
      this.followingCount});

  factory UserModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;

    return UserModel(
        id: snap.id,
        name: doc['name'],
        username: doc['username'],
        email: doc['email'],
        coverImageUrl: doc['coverImageUrl'],
        imageUrl: doc['imageUrl'],
        bio: doc['bio'],
        deviceToken: doc['deviceToken'],
        isBanned: doc['isBanned'],
        isVerified: doc['isVerified'],
        isActive: doc['isActive'],
        isReady: doc['isReady'],
        haveNewActivity: doc['haveNewActivity'],
        role: doc['role'],
        isPrivacyPolicyChecked: doc['isPrivacyPolicyChecked'],
        location: doc['location'],
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
        shopName: doc['shopName'],
        ratingCount: doc['ratingCount'] ?? 0,
        postCount: doc['postCount'] ?? 0,
        stencilsCount: doc['stencilsCount'] ?? 0,
        followerCount: doc['followerCount'] ?? 0,
        followingCount: doc['followingCount'] ?? 0);
  }

  UserModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    username = map['username'];
    email = map['email'];
    coverImageUrl = map['coverImageUrl'];
    imageUrl = map['imageUrl'];
    bio = map['bio'];
    deviceToken = map['deviceToken'];
    isBanned = map['isBanned'];
    isVerified = map['isVerified'];
    isActive = map['isActive'];
    isReady = map['isReady'];
    haveNewActivity = map['haveNewActivity'];
    role = map['role'];
    isPrivacyPolicyChecked = map['isPrivacyPolicyChecked'];
    location = null;
    createdAt = null;
    updatedAt = null;
    shopName = map['shopName'];
    ratingCount = map['ratingCount'] ?? 0;
    postCount = map['postCount'] ?? 0;
    stencilsCount = map['stencilsCount'] ?? 0;
    followerCount = map['followerCount'] ?? 0;
    followingCount = map['followingCount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['role'] = role;
    data['name'] = name;
    data['shopName'] = shopName;
    data['isVerified'] = isVerified;
    data['isActive'] = isActive;
    data['bio'] = bio;
    data['ratingCount'] = ratingCount ?? 0;
    data['postCount'] = postCount ?? 0;
    data['stencilsCount'] = stencilsCount ?? 0;
    data['followerCount'] = followerCount ?? 0;
    data['followingCount'] = followingCount ?? 0;
    data['email'] = email;
    data['deviceToken'] = deviceToken;
    data['location'] = null;
    data['createdAt'] = null;
    data['updatedAt'] = null;
    data['isPrivacyPolicyChecked'] = isPrivacyPolicyChecked;
    data['isBanned'] = isBanned;
    data['isReady'] = isReady;
    data['haveNewActivity'] = haveNewActivity;
    data['coverImageUrl'] = coverImageUrl;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
