import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String? senderId;
  final String? text;
  final List<dynamic>? imageUrls;
  final String? giphyUrl;
  final String? videoUrl;
  final Timestamp? timeCreated;
  final bool? isLiked;

  MessageModel(
      {this.id,
      this.senderId,
      this.text,
      this.imageUrls,
      this.giphyUrl,
      this.videoUrl,
      this.timeCreated,
      this.isLiked});

  factory MessageModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String,dynamic>;

    return MessageModel(
      id: snap.id,
      senderId: doc['senderId'],
      text: doc['text'],
      imageUrls: doc['imageUrls'] ?? [],
      giphyUrl: doc['giphyUrl'] ?? "",
      videoUrl: doc['videoUrl'] ?? "",
      timeCreated: doc['timeCreated'],
      isLiked: doc['isLiked'],
    );
  }
}
