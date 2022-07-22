import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/search_viewmodel.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/local_storage_user.dart';
import '../../core/values/database_query.dart';
import '../../core/viewmodel/post_card_viewmodel.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../widgets/post/stencil_card_widget.dart';

class ArtistsStencilsTab extends StatelessWidget {
  final UserModel remoteUser;

  const ArtistsStencilsTab({Key? key, required this.remoteUser})
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
          child: Text("No stencils available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {


        PostModel post =
        PostModel.fromDoc(documentSnapshots[index]);

        if (post.postType != null) {
          return StencilCardWidget(
            post: post,
            onTap: () async {
              /// Open in details
              bool test = Get.isRegistered<PostCardViewModel>(
                  tag: post.id);
              if (test) {
                Get.find<PostCardViewModel>(tag: post.id)
                    .navigateToPostDetailsView();
              } else {
                Get.put(
                    PostCardViewModel(
                        post: post,
                        currentUser: await LocalStorageUser
                            .getUserData()),
                    tag: post.id);
                Get.find<PostCardViewModel>(tag: post.id)
                    .navigateToPostDetailsView();
              }
            },
          );
        }

        return const SizedBox.shrink();


      },
      query: FirestoreQueries.artistsStencilsQuery(remoteUser.id!),
      itemBuilderType: PaginateBuilderType.gridView,
      isLive: false,
    );
  }
}

