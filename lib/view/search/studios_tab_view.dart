import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/viewmodel/search_viewmodel.dart';

class StudiosTabView extends StatelessWidget {
  const StudiosTabView({Key? key}) : super(key: key);

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
                    child: Text("No Studios found"),
                  ),
                ),
                itemBuilder: (context, documentSnapshots, index) {
                  return const SizedBox.shrink();
                },
                query: controller.studioQuery.value,
                itemBuilderType: PaginateBuilderType.listView,
                isLive: false,
                key: UniqueKey(),
              ));
        });
  }
}
