import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/chat_model.dart';
import '../../model/user_model.dart';
import '../services/local_storage_user.dart';
import '../values/database_query.dart';



class ChatViewModel extends GetxController  with GetSingleTickerProviderStateMixin {

  late TabController tabController;
  RxBool loading = true.obs;

  Rxn<UserModel> localUser = Rxn<UserModel>();
  RxInt unreadChat = 0.obs;
  RxInt chatRequest = 0.obs;

  @override
  void onInit() {
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(() {

    });
    initChatTab();
    super.onInit();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  initChatTab() async{
    loading(true);
    localUser(await LocalStorageUser.getUserData());
    listenToNewMessage();
    listenToChatRequest();
    loading(false);
  }


  listenToNewMessage() async{
    FirestoreQueries.latestChatQuery(localUser.value!.id!)
        .snapshots().listen((event) {
      unreadChat(0);
      for( var doc in event.docs) {
        ChatModel chatData = ChatModel.fromDoc(doc);
        Map<String, dynamic> readStatus = chatData.readStatus;

        if(readStatus[localUser.value!.id] == false) {
          unreadChat.value++;
        }
      }
    });
  }

  listenToChatRequest() async{
    FirestoreQueries.chatRequestQuery(localUser.value!.id!)
        .snapshots().listen((event) {
      chatRequest(0);
      for( var doc in event.docs) {
        ChatModel chatData = ChatModel.fromDoc(doc);
        Map<String, dynamic> readStatus = chatData.readStatus;

        if(readStatus[localUser.value!.id] == false) {
          chatRequest.value++;
        }
      }
    });
  }















}
