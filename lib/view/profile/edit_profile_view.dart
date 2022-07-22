import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/profile_viewmodel.dart';

class EditProfileView extends StatelessWidget {
  final ProfileViewModel controller;

  EditProfileView({Key? key, required this.controller}) : super(key: key);

  /// Global key for the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Obx(() => controller.loading.value
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    FontAwesomeIcons.angleLeft,
                    color: Colors.white,
                  ),
                ),
                title: Text('Edit Profile', style: Get.textTheme.titleLarge!.copyWith(color: Colors.white),),
                actions: [
                  IconButton(
                    onPressed: () {
                      controller.pickCoverImage();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.images,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
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
                        SizedBox(
                          height: 180,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Obx(() => controller.coverImagePath.value.isEmpty
                                  ? CachedNetworkImage(
                                      imageUrl:
                                      controller.remoteUser.value!
                                          .coverImageUrl!.isNotEmpty
                                          ? controller.remoteUser.value!.coverImageUrl!
                                          : controller.remoteUser.value!.imageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(controller.coverImagePath.value),
                                      fit: BoxFit.cover,
                                    )),




                              Obx(() => (controller.remoteUser.value!
                                          .coverImageUrl!.isEmpty &&
                                      controller.coverImagePath.value.isEmpty)
                                  ? ClipRRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: AppColors.linearGradient,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                              Align(
                                child: Transform.translate(
                                  offset: const Offset(0, 90),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Get.theme.scaffoldBackgroundColor,
                                        width: 5.0,
                                      ),
                                    ),
                                    child: Obx(() => controller
                                            .profileImagePath.value.isEmpty
                                        ? CircleAvatar(
                                            backgroundColor:
                                                Get.theme.scaffoldBackgroundColor,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              controller
                                                  .remoteUser.value!.imageUrl!,
                                            ),
                                            radius: 65.0,
                                          )
                                        : CircleAvatar(
                                            backgroundColor:
                                                Get.theme.scaffoldBackgroundColor,
                                            backgroundImage: FileImage(File(
                                                controller
                                                    .profileImagePath.value)),
                                            radius: 65.0,
                                          )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80.h),
                        Material(
                          borderRadius: BorderRadius.circular(8.r),
                          child: InkWell(
                            onTap: () {
                              controller.pickProfileImage();
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: REdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const WidgetSpan(
                                        child: Icon(
                                          FontAwesomeIcons.plusSquare,
                                          size: 16.0,
                                        ),
                                        alignment: PlaceholderAlignment.middle),
                                    const WidgetSpan(
                                        child: SizedBox(
                                          width: 5,
                                        ),
                                        alignment: PlaceholderAlignment.middle),
                                    TextSpan(
                                        text: "Choose profile photo",
                                        style:
                                            Get.textTheme.bodyText2!.copyWith()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
                body: SingleChildScrollView(
                  child: Padding(
                    padding: REdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Form(
                      /// form key.
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          /// Name input.
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: controller.remoteUser.value!.name!,
                              hintText: 'Ishtian Revee',
                            ),
                            keyboardType: TextInputType.name,
                            obscureText: false,
                            initialValue: controller.remoteUser.value!.name!,
                            validator: (value) => value!.length >= 4
                                ? null
                                : "Name must be at least 4 characters in length",
                            onSaved: (value) {
                              controller.name = value!;
                            },
                          ),

                          SizedBox(
                            height: 38.h,
                          ),

                          /// Bio input.
                          TextFormField(
                            decoration: InputDecoration(
                              labelText:
                                  controller.remoteUser.value!.bio!.isNotEmpty
                                      ? controller.remoteUser.value!.bio
                                      : 'bio',
                              hintText: "I'm not feeling well today",
                            ),
                            keyboardType: TextInputType.name,
                            obscureText: false,
                            initialValue: controller.remoteUser.value!.bio!,
                            validator: (value) => value!.length <= 200
                                ? null
                                : "Bio must be less then 200 characters in length",
                            onSaved: (value) {
                              controller.bio = value!;
                            },
                          ),

                          SizedBox(
                            height: 50.h,
                          ),

                          MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                controller.updateTheArtist();
                              }
                            },
                            child: Ink(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: AppColors.enabledButtonColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.0),
                                  )),
                              child: Container(
                                  padding: EdgeInsets.all(15.h),
                                  alignment: Alignment.center,
                                  child: const Text("SUBMIT",
                                      style: TextStyle(color: Colors.white))),
                            ),
                            splashColor: Colors.black12,
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
    );
  }
}
