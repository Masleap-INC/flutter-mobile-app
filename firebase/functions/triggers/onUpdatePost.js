const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
  functions.logger.info('ENTRY::onUpdatePost')

  // Get the postId from context parameter
  const postId = context.params.postId;

  const newPostData = snapshot.after.data();

  // Get author id from snapshot.data()
  const userId = newPostData.authorId;

  // Get all the authors followers
  const userFollowersSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("userFollowers")
      .get();

  userFollowersSnapshot.forEach(async (userDoc) => {
    // Updating post to author's followers feed
    const postRef = admin
      .firestore()
      .collection("users")
      .doc(userDoc.id)
      .collection("userFeed");

    const postDoc = await postRef.doc(postId).get();

    if (postDoc.exists) {
      postDoc.ref.update(newPostData);
    }

  });

  // Updating post to author feed
  const postRef = admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("userFeed");
  const postDoc = await postRef.doc(postId).get();
  if (postDoc.exists) {
    postDoc.ref.update(newPostData);
  }
}

