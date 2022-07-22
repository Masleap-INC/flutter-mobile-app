import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/database_query.dart';
import '../../model/user_model.dart';

class ArtistsReviewsTab extends StatelessWidget {
  final UserModel remoteUser;

  const ArtistsReviewsTab({Key? key, required this.remoteUser})
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
          child: Text("No Reviews available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {

        return const SizedBox.shrink();


      },
      query: FirestoreQueries.artistsReviewsQuery(remoteUser.id!),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: false,
    );
  }
}