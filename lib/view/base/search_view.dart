import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/core/viewmodel/search_viewmodel.dart';

import '../search/artists_tab_view.dart';
import '../search/stencils_tab_view.dart';
import '../search/studios_tab_view.dart';
import '../search/hashtags_tab_view.dart';
import '../widgets/search/rounded_corner_tab_indicator.dart';

class SearchView extends StatelessWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return GetBuilder<SearchViewModel>(
        init: Get.put(SearchViewModel()),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Get.theme.appBarTheme.backgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: AppBar(
                //backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: Padding(
                  padding: REdgeInsets.fromLTRB(15, 35, 15, 0),
                  child: Obx(() => TextField(
                        controller: controller.searchTextEditingController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value)=> controller.onSearchSubmit(value),
                        decoration: InputDecoration(
                            hintText: "Search ${controller.activeTab}...",
                            labelText: "Search",
                            prefixIcon: Icon(
                              FontAwesomeIcons.search,
                              color: Get.theme.textTheme.bodyText2!.color,
                            )),
                        style: Get.textTheme.bodyText2,
                        keyboardType: TextInputType.text,
                      )),
                ),
                bottom: TabBar(
                  controller: controller.tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.enabledButtonColor,
                  unselectedLabelColor: AppColors.disabledButtonColor,
                  automaticIndicatorColorAdjustment: true,
                  isScrollable: false,
                  indicator: RoundedCornerTabIndicator(
                    color: AppColors.enabledButtonColor,
                    radius: 3,
                    height: 3,
                  ),
                  tabs: controller.tabList.map((item) {
                    return Tab(
                      text: item,
                    );
                  }).toList(),
                ),
              ),
            ),
            body: TabBarView(
              controller: controller.tabController,
              children: const [
                ArtistsTabView(),
                StencilsTabView(),
                StudiosTabView(),
                HashtagsTabView()
              ],
            ),
          );
        });
  }
}
