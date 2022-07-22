import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/database_query.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../core/values/system_overlay.dart';
import '../widgets/user/artist_cards/mention_artist_card_widget.dart';

class MentionPeopleView extends StatelessWidget {
  final String currentUserId;

  const MentionPeopleView({Key? key, required this.currentUserId})
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
            title: const Text("Mention People"),
          ),
          body: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: PaginateFirestore(
              itemBuilder: (context, documentSnapshots, index) {
                String artistId = documentSnapshots[index].id;
                return MentionedArtistCardWidget(
                  controller: Get.put(
                      MentionedArtistCardViewModel(artistId: artistId),
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
