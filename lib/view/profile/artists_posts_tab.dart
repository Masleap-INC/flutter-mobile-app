import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/database_query.dart';
import '../../core/viewmodel/post_card_viewmodel.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../widgets/post/post_card_widget.dart';

class ArtistsPostTab extends StatelessWidget {
  final UserModel currentUser;
  final UserModel remoteUser;
  const ArtistsPostTab({Key? key, required this.remoteUser, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return PaginateFirestore(
      itemsPerPage: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: REdgeInsets.all(15),
      onEmpty: SizedBox(
        height: Get.size.height - 270,
        child: const Center(
          child: Text("No post available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        PostModel post = PostModel.fromDoc(
            documentSnapshots[index]);

        if (post.postType != null) {
          return PostCardWidget(
            controller: Get.put(
                PostCardViewModel(
                  post: post,
                  currentUser: currentUser,
                ),
                tag: post.id),
            isListViewType: true,
          );
        }
        return const SizedBox.shrink();
      },
      query: FirestoreQueries.artistsPostQuery(remoteUser.id!),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: false,
    );
  }
}
