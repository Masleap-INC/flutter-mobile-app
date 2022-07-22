import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/model/post_history_type.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/system_overlay.dart';
import '../../model/post_history_model.dart';
import '../widgets/post/post_history_card_widget.dart';

class PostHistoryView extends StatelessWidget {
  final Query query;
  final PostHistoryType type;
  const PostHistoryView({Key? key, required this.query, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              FontAwesomeIcons.angleLeft,
            ),
          ),
          title: Text("${type.name.capitalize} Posts"),
        ),
        body: PaginateFirestore(
          itemsPerPage: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: REdgeInsets.all(15),
          onEmpty: SizedBox(
            height: Get.size.height - 270,
            child: Center(
              child: Text("No ${type.name} available"),
            ),
          ),
          itemBuilder: (context, documentSnapshots, index) {
            PostHistoryModel history =
                PostHistoryModel.fromDoc(documentSnapshots[index]);

            return PostHistoryCardWidget(
              history: history,
              type: type,
              onTap: () {

              },
            );
          },
          query: query,
          itemBuilderType: PaginateBuilderType.listView,
          isLive: false,
        ),
      ),
    );
  }
}
