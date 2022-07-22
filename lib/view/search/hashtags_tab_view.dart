import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/viewmodel/search_viewmodel.dart';
import '../../model/hashtag_model.dart';

class HashtagsTabView extends StatelessWidget {
  const HashtagsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return GetBuilder<SearchViewModel>(
        init: Get.find<SearchViewModel>(),
        builder: (controller) {
          return Obx(() => PaginateFirestore(
            itemsPerPage: 10,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: REdgeInsets.symmetric(vertical: 15),
            onEmpty: SizedBox(
              height: Get.size.height - 270,
              child: const Center(
                child: Text("No hashtag available"),
              ),
            ),
            itemBuilder: (context, documentSnapshots, index) {

              HashtagModel hashtag = HashtagModel.fromDoc(documentSnapshots[index]);

              return Container(
                padding: REdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
                margin: REdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.cardBackground(Get.isDarkMode),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: ListTile(
                  onTap: () async {

                  },
                  leading: const FaIcon(
                      FontAwesomeIcons.hashtag,
                  ),
                  title: Text(
                    hashtag.tagName!,
                    style: Get.textTheme.bodyText2,
                  ),
                  trailing: Text(
                    '${hashtag.totalUsed} posts',
                    style: Get.textTheme.bodyText2,
                  ),
                ),
              );
            },
            query: controller.hashtagQuery.value,
            itemBuilderType: PaginateBuilderType.listView,
            isLive: false,
            key: UniqueKey(),
          ));
        });
  }
}
