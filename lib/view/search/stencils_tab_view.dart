import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/post_card_viewmodel.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/local_storage_user.dart';
import '../../core/viewmodel/search_viewmodel.dart';
import '../../model/post_model.dart';
import '../widgets/post/stencil_card_widget.dart';

class StencilsTabView extends StatelessWidget {
  const StencilsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return GetBuilder<SearchViewModel>(
        init: Get.find<SearchViewModel>(),
        builder: (controller) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: REdgeInsets.fromLTRB(0, 15, 0, 5),
                child: SizedBox(
                  height: 52.h,
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.stencilCatList.length,
                      scrollDirection: Axis.horizontal,
                      padding: REdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (BuildContext context, int index) {
                        return Obx(() => GestureDetector(
                              onTap: () => controller.onCategorySelects(controller.stencilCatList[index]),
                              child: Chip(
                                label: Text(
                                  controller.stencilCatList[index],
                                  style: Get.theme.textTheme.bodyText2!
                                      .copyWith(
                                          color: (controller.stencilCat ==
                                                  controller
                                                      .stencilCatList[index])
                                              ? Colors.white
                                              : const Color(0xFF010A1C)),
                                ),
                                backgroundColor: (controller.stencilCat ==
                                        controller.stencilCatList[index])
                                    ? const Color(0xFF010A1C)
                                    : const Color(0xFFF6F7F8),
                                padding: REdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                            ));
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                            width: 10,
                          )),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: REdgeInsets.symmetric(horizontal: 7.5),
                  child: Obx(() => PaginateFirestore(
                        itemsPerPage: 10,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: REdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        onEmpty: SizedBox(
                          height: Get.size.height - 270,
                          child: const Center(
                            child: Text("No Stencils Available"),
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
                        query: controller.stencilQuery.value,
                        itemBuilderType: PaginateBuilderType.gridView,
                        isLive: false,
                        key: UniqueKey(),
                      )),
                ),
              )
            ],
          );
        });
  }
}
