import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_model.dart';

class ChatModel {
  final String? id;
  final String? recentMessage;
  final String? recentSender;
  final Timestamp? recentTimestamp;
  final List<dynamic>? memberIds;
  final List<UserModel>? memberInfo;
  final dynamic readStatus;

  ChatModel({
    this.id,
    this.recentMessage,
    this.recentSender,
    this.recentTimestamp,
    this.memberIds,
    this.memberInfo,
    this.readStatus,
  });

  factory ChatModel.fromDoc(DocumentSnapshot snap) {
    var doc = snap.data() as Map<String,dynamic>;
    return ChatModel(
      id: snap.id,
      recentMessage: doc['recentMessage'],
      recentSender: doc['recentSender'],
      recentTimestamp: doc['recentTimestamp'],
      memberIds: doc['memberIds'],
      readStatus: doc['readStatus'],
    );
  }
}
