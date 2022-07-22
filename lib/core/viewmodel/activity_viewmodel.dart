import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/database_references.dart';

import '../../model/user_model.dart';
import '../services/local_storage_user.dart';

class ActivityViewModel extends GetxController {
  UserModel? currentUser;

  RxBool haveNewActivity = false.obs;

  @override
  void onInit() {
    getCurrentUser();
    super.onInit();
  }

  getCurrentUser() async {
    currentUser = await LocalStorageUser.getUserData();
    if (currentUser != null) {
      listenToActivity();
    }
  }

  listenToActivity() {
    DatabaseReference.users.doc(currentUser!.id!.trim()).snapshots().listen(
        (event) {
      if (event.exists) {
        var data = event.data() as Map<String, dynamic>;
        haveNewActivity(data['haveNewActivity']);
      } else {
        haveNewActivity(false);
      }
    }, onError: (e) {
      haveNewActivity(false);
    });
  }

  markActivityAsRead() async {
    DocumentSnapshot docSnap =
        await DatabaseReference.users.doc(currentUser!.id!.trim()).get();

    if (docSnap.exists) {
      UserModel userModel = UserModel.fromDoc(docSnap);

      if (userModel.haveNewActivity != null) {
        docSnap.reference.update({
          'haveNewActivity': false,
        });
      } else {
        docSnap.reference.set({
          'haveNewActivity': false,
        }, SetOptions(merge: true));
      }

      haveNewActivity(false);
    }
  }
}
