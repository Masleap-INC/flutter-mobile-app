import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import '../../core/viewmodel/chat_viewmodel.dart';
import '../chat/chat_requests_tab.dart';
import '../chat/create_chat_group_view.dart';
import '../chat/latest_chat_tab.dart';
import '../chat/message_people_view.dart';
import '../widgets/profile/custom_tab_widget.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Scaffold(
      body: GetBuilder<ChatViewModel>(
        init: Get.find<ChatViewModel>(),
        builder: (controller) => Obx(() => controller.loading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Get.theme.appBarTheme.backgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () {
                      Get.to(()=> MessagePeopleView(currentUserId: controller.localUser.value!.id!,));
                    },
                    icon: const Icon(
                      FontAwesomeIcons.search,
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    "Messages",
                    style: Get.textTheme.titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Get.to(()=> CreateChatGroupView(currentUserId: controller.localUser.value!.id!,));
                      },
                      icon: const Icon(
                        FontAwesomeIcons.solidEdit,
                      ),
                    )
                  ],
                ),
                body: NestedScrollView(
                  scrollDirection: Axis.vertical,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      //headerSilverBuilder only accepts slivers
                      child: Column(
                        children: [
                          Container(
                            margin: REdgeInsets.fromLTRB(15, 15, 15, 5),
                            padding: REdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: AppColors.cardBackground(Get.isDarkMode),
                              borderRadius: BorderRadius.circular(
                                25.r,
                              ),
                            ),
                            child: TabBar(
                              controller: controller.tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  25.r,
                                ),
                                color: Get.theme.appBarTheme.backgroundColor,
                              ),
                              labelColor: AppColors.enabledButtonColor,
                              unselectedLabelColor:
                                  AppColors.disabledButtonColor,
                              tabs: [
                                CustomTabWidget(
                                    title: 'Latest',
                                    isActive:
                                        controller.tabController.index == 0),
                                Obx(()=> CustomTabWidget(
                                    title: 'Requests (${controller.chatRequest.value})',
                                    isActive:
                                    controller.tabController.index == 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: controller.tabController,
                    children: [
                      LatestChatTab(
                        localUser: controller.localUser.value!,
                      ),
                      ChatRequestsTab(
                        localUser: controller.localUser.value!,
                      ),
                    ],
                  ),
                ),
              )),
      ),
    );
  }
}
