import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/post_model.dart';
import '../values/database_query.dart';

class SearchViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// Tab bar controller
  late TabController tabController;
  final tabList = ['Artists', 'Stencils', 'Studios', 'Tags'];
  RxString activeTab = ''.obs;

  /// Search textEditingController
  TextEditingController searchTextEditingController = TextEditingController();

  /// Firestore Database Query
  Rx<Query> artistQuery = Rx(FirestoreQueries.artistsQuery());
  Rx<Query> stencilQuery = Rx(FirestoreQueries.stencilsQuery());
  Rx<Query> studioQuery = Rx(FirestoreQueries.studiosQuery());
  Rx<Query> hashtagQuery = Rx(FirestoreQueries.hashtagsQuery());

  /// Stencils
  List stencilCatList = ['All'] + PostModel.stencilCatList;
  RxString stencilCat = 'All'.obs;

  @override
  void onInit() {
    activeTab.value = tabList[0];
    tabController = TabController(vsync: this, length: tabList.length);
    tabController.addListener(() {
      activeTab.value = tabList[tabController.index];
      searchTextEditingController.clear();
    });
    super.onInit();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchTextEditingController.dispose();
    super.dispose();
  }

  void onSearchSubmit(String searchKey) {
    switch (tabController.index) {

      /// Artists query
      case 0:
        artistQuery(FirestoreQueries.artistsSearchQuery(searchKey));
        break;

      /// Stencils query
      case 1:
        stencilQuery(
            FirestoreQueries.stencilsSearchQuery(searchKey, stencilCat.value));
        break;

      /// Studios query
      case 2:
        studioQuery(FirestoreQueries.studiosSearchQuery(searchKey));
        break;

      /// Hashtag query
      case 3:
        hashtagQuery(FirestoreQueries.hashtagsSearchQuery(searchKey));
        break;
    }
  }

  void onCategorySelects(String category) {
    stencilCat(category);

    String searchKey = searchTextEditingController.text.toString();

    if (searchKey.isNotEmpty) {
      stencilQuery(
          FirestoreQueries.stencilsSearchQuery(searchKey, stencilCat.value));
    } else {
      stencilQuery(
          FirestoreQueries.stencilsCategorySearchQuery(stencilCat.value));
    }
  }
}
