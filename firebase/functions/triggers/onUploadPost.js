const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
   functions.logger.info('ENTRY::onUploadPost')

   // Get author id from snapshot.data()
   const userId = snapshot.data().authorId;
   // Get the postId from context parameter
   const postId = context.params.postId;

   // Get all the authors followers
   const userFollowersSnapshot = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("userFollowers")
        .get();

   userFollowersSnapshot.forEach((doc) => {
     // Uploading post to authors followers feed
     admin
       .firestore()
       .collection("users")
       .doc(doc.id)
       .collection("userFeed")
       .doc(postId)
       .set(snapshot.data());
   });

   // Uploading post to authors feed
   admin
     .firestore()
     .collection("users")
     .doc(userId)
     .collection("userFeed")
     .doc(postId)
     .set(snapshot.data());

   // Get author document data
   const userDoc = await admin
    .firestore()
    .collection("users")
    .doc(userId).get();


    var postCount = userDoc.data().postCount ?? 0;
    var stencilsCount = userDoc.data().stencilsCount ?? 0;
    postCount++;

    var postType = snapshot.data().postType

    if (postType === "stencil") {
        stencilsCount++;
    }

    admin
    .firestore()
    .collection("users")
    .doc(userId)
    .update({
        'postCount': postCount,
        'stencilsCount': stencilsCount
    });

}


