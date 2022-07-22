import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/control_viewmodel.dart';
import 'package:inkistry/core/viewmodel/search_viewmodel.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/local_storage_user.dart';
import '../../core/viewmodel/profile_viewmodel.dart';
import '../../model/user_model.dart';
import '../profile/artists_profile_view.dart';
import '../widgets/user/artist_cards/search_artist_card_widget.dart';

class ArtistsTabView extends StatelessWidget {
  const ArtistsTabView({Key? key}) : super(key: key);

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
                    child: Text("No artist available"),
                  ),
                ),
                itemBuilder: (context, documentSnapshots, index) {
                  UserModel artist =
                      UserModel.fromDoc(documentSnapshots[index]);

                  return SearchArtistCardWidget(
                    controller: Get.put(
                        SearchArtistCardViewModel(artist: artist),
                        tag: artist.id),
                    onTap: () async {
                      var currentUser = await LocalStorageUser.getUserData();
                      if (currentUser.id == artist.id) {
                        Get.find<ControlViewModel>().changeCurrentScreen(4);
                      } else {
                        /// Navigate to the artist profile
                        Get.to(()=> ArtistsProfileView(
                          controller: Get.put(
                              ProfileViewModel(userId: artist.id!),
                              tag: artist.id
                          ),
                        ));
                      }
                    },
                  );
                },
                query: controller.artistQuery.value,
                itemBuilderType: PaginateBuilderType.listView,
                isLive: false,
                key: UniqueKey(),
              ));
        });
  }
}
