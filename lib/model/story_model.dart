import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String? id;
  final String? authorId;
  final String? imageUrl;
  final String? videoUrl;
  final String? caption;
  final String? captureType;
  final Map<dynamic, dynamic>? views;
  final String? linkUrl;
  final String? location;
  final String? filter;
  final int? duration;
  final Timestamp? timeEnd;
  final Timestamp? timeStart;
  final Timestamp? timeCreated;

  StoryModel(
      {this.id,
      this.authorId,
      this.imageUrl,
      this.videoUrl,
      this.captureType,
      this.caption,
      this.views,
      this.linkUrl,
      this.location,
      this.filter,
      this.duration,
      this.timeEnd,
      this.timeStart,
      this.timeCreated});

  factory StoryModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String, dynamic>;

    return StoryModel(
        id: snap.id,
        authorId: doc['authorId'],
        imageUrl: doc['imageUrl'],
        videoUrl: doc['videoUrl'],
        captureType: doc['captureType'],
        caption: doc['caption'],
        views: doc['views'],
        linkUrl: doc['linkUrl'],
        location: doc['location'],
        filter: doc['filter'],
        duration: doc['duration'] ?? 10,
        timeEnd: doc['timeEnd'],
        timeStart: doc['timeStart'],
        timeCreated: doc['timeCreated']);
  }

  StoryModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        duration = json['duration'],
        filter = json['filter'],
        location = json['location'],
        timeStart = json['timeStart'] != null
            ? Timestamp((json['timeStart'] as Map<String, dynamic>)["_seconds"],
                (json['timeStart'] as Map<String, dynamic>)["_nanoseconds"])
            : null,
        timeEnd = json['timeEnd'] != null
            ? Timestamp((json['timeEnd'] as Map<String, dynamic>)["_seconds"],
                (json['timeEnd'] as Map<String, dynamic>)["_nanoseconds"])
            : null,
        timeCreated = json['timeCreated'] != null
            ? Timestamp(
                (json['timeCreated'] as Map<String, dynamic>)["_seconds"],
                (json['timeCreated'] as Map<String, dynamic>)["_nanoseconds"])
            : null,
        views = json['views'],
        authorId = json['authorId'],
        imageUrl = json['imageUrl'],
        videoUrl = json['videoUrl']??'',
        captureType = json['captureType']??'',
        caption = json['caption'],
        linkUrl = json['linkUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['duration'] = duration;
    data['filter'] = filter;
    data['location'] = location;
    if (timeStart != null) {
      data['timeStart'];
    }
    if (timeEnd != null) {
      data['timeEnd'];
    }
    if (timeCreated != null) {
      data['timeCreated'];
    }
    if (views != null) {
      data['views'] = views;
    }
    data['authorId'] = authorId;
    data['imageUrl'] = imageUrl;
    data['videoUrl'] = videoUrl;
    data['captureType'] = captureType;
    data['caption'] = caption;
    data['linkUrl'] = linkUrl;
    return data;
  }
}
