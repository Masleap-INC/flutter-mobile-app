const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
    functions.logger.info('ENTRY::onUnfollowUser')

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // All posts from unfollowed user in current user feed
    const userFeedRef = admin
    .firestore()
    .collection("users")
    .doc(followerId)
    .collection("userFeed")
    .where("authorId", "==", userId);

    // Get all posts unfollowed user
    const userPostsSnapshot = await userFeedRef.get();
    userPostsSnapshot.forEach((doc) => {
    if (doc.exists) {
      // Delete each unfollowed user post from current user feed
      doc.ref.delete();
    }
    });




    // Get users document data
    const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId).get();

    // Get follower document data
    const followerDoc = await admin
        .firestore()
        .collection("users")
        .doc(followerId).get();


    var followerCount = userDoc.data().followerCount ?? 0;
    var followingCount = followerDoc.data().followingCount ?? 0;

    followerCount--;
    followingCount--;

    // Update users document data
    admin
    .firestore()
    .collection("users")
    .doc(userId)
    .update({
        'followerCount': followerCount,
    });


    // Update follower document data
    admin
    .firestore()
    .collection("users")
    .doc(followerId)
    .update({
        'followingCount': followingCount,
    });









}


