const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
    functions.logger.info('ENTRY::onFollowUser')

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // Followed User posts
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .where("authorId", "==", userId);

    functions.logger.info(userId)

    // Current User feed
    const userFeedRef = admin
      .firestore()
      .collection("users")
      .doc(followerId)
      .collection("userFeed");

    // Get all posts from followed user
    const followedUserPostsSnapshot = await followedUserPostsRef.get();

    followedUserPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        // Add followed user posts to current user feed
        userFeedRef.doc(doc.id).set(doc.data());
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

    followerCount++;
    followingCount++;

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


