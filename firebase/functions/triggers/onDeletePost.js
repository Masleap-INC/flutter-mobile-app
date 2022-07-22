const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
  functions.logger.info('ENTRY::onDeletePost')
  functions.logger.info(snapshot.data().authorId)

  const userId = snapshot.data().authorId;
  const postId = context.params.postId;
  // All the current user followers
  const userFollowersRef = admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("userFollowers");

  // Get current user followers
  const userFollowersSnapshot = await userFollowersRef.get();

  userFollowersSnapshot.forEach(async (userDoc) => {
    // Deleting post to current user followers feed
    const postRef = admin
      .firestore()
      .collection("users")
      .doc(userDoc.id)
      .collection("userFeed");
    const postDoc = await postRef.doc(postId).get();
    if (postDoc.exists) {
      postDoc.ref.delete();
    }
  });

  // Deleting post to author feed
  const postRef = admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("userFeed");
  const postDoc = await postRef.doc(postId).get();
  if (postDoc.exists) {
    postDoc.ref.delete();
  }
}


