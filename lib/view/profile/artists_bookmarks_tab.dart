import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/model/post_history_type.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/database_query.dart';
import '../../model/post_history_model.dart';
import '../../model/user_model.dart';
import '../widgets/post/post_history_card_widget.dart';

class ArtistsBookmarksTab extends StatelessWidget {
  final UserModel remoteUser;

  const ArtistsBookmarksTab({Key? key, required this.remoteUser})
      : super(key: key);

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
          child: Text("No bookmarks available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        PostHistoryModel history =
            PostHistoryModel.fromDoc(documentSnapshots[index]);

        return PostHistoryCardWidget(
          history: history,
          type: PostHistoryType.bookmarks,
          onTap: () {},
        );
      },
      query: FirestoreQueries.artistsBookmarks(remoteUser.id!),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: false,
    );
  }
}
