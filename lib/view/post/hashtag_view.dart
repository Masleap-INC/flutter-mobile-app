import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/database_references.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/system_overlay.dart';

class HashTagController extends GetxController {
  Rx<Query> query =
      FirebaseFirestore.instance.collection('hashtags').orderBy('tagName').obs;
  TextEditingController hashtagTextEditingController = TextEditingController();

  @override
  dispose() {
    hashtagTextEditingController.dispose();
    super.dispose();
  }

  onDoneButtonPressed() {
    if (hashtagTextEditingController.text.toString().trim().isNotEmpty) {
      Get.back(result: hashtagTextEditingController.text.toString().trim());
    } else {
      Get.snackbar(
        "Message...",
        "Please type or select a hashtag text to continue...",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  onHashtagItemPressed(String tag) {
    Get.back(result: tag);
  }
}

class HashtagView extends StatelessWidget {
  const HashtagView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: GetBuilder<HashTagController>(
            init: Get.put(HashTagController()),
            builder: (controller) {
              return Scaffold(
                backgroundColor: AppColors.primaryBackground(Get.isDarkMode),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      FontAwesomeIcons.angleLeft,
                    ),
                  ),
                  title: const Text("Hashtags"),
                  actions: [
                    Padding(
                      padding: REdgeInsets.all(15),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.appColorBlue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: Get.textTheme.bodyText2!
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () => controller.onDoneButtonPressed(),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: REdgeInsets.fromLTRB(15, 15, 15, 30),
                        child: TextField(
                          controller: controller.hashtagTextEditingController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("a-zA-Z0-9]+\b")),
                          ],
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            controller.query.value = DatabaseReference.hashtags
                                .where('tagName', isGreaterThanOrEqualTo: value)
                                .orderBy('tagName');
                          },
                          decoration: InputDecoration(
                              hintText: "Type a tag",
                              labelText: "Hashtags",
                              prefixIcon: Icon(
                                FontAwesomeIcons.hashtag,
                                color: Get.theme.textTheme.bodyText2!.color,
                              )),
                          style: Theme.of(context).textTheme.bodyText2,
                          keyboardType: TextInputType.multiline,
                        )),
                    Padding(
                      padding:
                          REdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Text(
                        'Or, Select a hashtag',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Expanded(
                      child: Obx(() => PaginateFirestore(
                            itemBuilder: (context, documentSnapshots, index) {
                              final data =
                                  documentSnapshots[index].data() as Map?;

                              return Container(
                                padding: REdgeInsets.symmetric(
                                    vertical: 7.5, horizontal: 15),
                                margin: REdgeInsets.symmetric(
                                    vertical: 7.5, horizontal: 15),
                                decoration: BoxDecoration(
                                    color: AppColors.cardBackground(Get.isDarkMode),
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  onTap: () =>
                                      controller.onHashtagItemPressed(
                                          data!['tagName'].trim()),
                                  leading: FaIcon(FontAwesomeIcons.hashtag,
                                      color:
                                          Theme.of(context).iconTheme.color),
                                  title: Text(
                                    data!['tagName'],
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  trailing: Text(
                                    '${data['totalUsed']} posts',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ),
                              );
                            },
                            query: controller.query.value,
                            itemBuilderType: PaginateBuilderType.listView,
                            isLive: false,
                            key: UniqueKey(),
                          )),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
