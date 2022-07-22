import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/database_query.dart';
import '../../core/values/system_overlay.dart';
import '../widgets/user/artist_cards/tag_artist_card_widget.dart';

class TagPeopleView extends StatelessWidget {
  final String currentUserId;

  const TagPeopleView({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                FontAwesomeIcons.angleLeft,
              ),
            ),
            title: const Text("Tag People"),
            actions: [
              Padding(
                padding: REdgeInsets.all(15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0.0),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.appColorBlue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style:
                        Get.textTheme.bodyText2!.copyWith(color: Colors.white),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
          body: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: PaginateFirestore(
              itemBuilder: (context, documentSnapshots, index) {
                String artistId = documentSnapshots[index].id;

                return TaggedArtistCardWidget(
                  controller: Get.put(
                      TaggedArtistCardViewModel(artistId: artistId),
                      tag: artistId),
                );
              },
              query: FirestoreQueries.artistsFollowingQuery(currentUserId),
              itemBuilderType: PaginateBuilderType.listView,
              isLive: false,
            ),
          ),
        ),
      ),
    );
  }
}
