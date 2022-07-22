const admin = require("firebase-admin");
const functions = require('firebase-functions')
//let serviceAccount = require("../serviceAccountKey.json");
//admin.initializeApp({
//  credential: admin.credential.cert(serviceAccount),
//  databaseURL: "https://inkistry-67d82.firebaseio.com"
//});

const db = admin.firestore();

const get_all_user = async (req, res) => {
  let users = db.collection("users");
  let response = [];
  try {
    const snapshot = await users
      .get();
    snapshot.forEach(doc => {
      const selectedItem = {
        id: doc.id,
        data: doc.data()
      };
      response.push(selectedItem);
    });
    return res.status(200).json({ response: response });
  } catch {
    return res.status(500).json({ error: error });
  }
};


const get_stories = async (req, res) => {

  // Empty array to store all the results
  let response = [];
  try {

    // Get requested document
    let requestedUserDoc = await db.collection("users")
      .doc(req.uid.trim()).get();

    // Check if the user has stories ------->
    let requestedUserStoriesSnapshot = await db.collection("users")
      .doc(requestedUserDoc.id.trim())
      .collection("stories")
      .where('timeEnd', '>=', admin.firestore.Timestamp.fromDate( new Date())).get();

    // Empty array to store stories
    let requestedUserStories = [];

    // Loop through each story
    requestedUserStoriesSnapshot.forEach(async (storyDoc) => {
      let story = {
        id: storyDoc.id,
        data: storyDoc.data()
      };
      requestedUserStories.push(story);
    });

    console.log(`Requested user stories length: ${requestedUserStoriesSnapshot.docs.length}`);

    // check stories is empty or not
    if (requestedUserStories.length > 0) {
      let user = {
        id: requestedUserDoc.id.trim(),
        data: requestedUserDoc.data(),
        stories: requestedUserStories
      };
      response.push(user);
    }
    // Repeaded code for getting stories ------->


    // Get the list of following users
    let followingUsersSnapshot = await db.collection('users')
      .doc(req.uid.trim())
      .collection("userFollowing").get();

    // for loop through the following users snapshots
    for (let followingUserDoc of followingUsersSnapshot.docs) {


      // Get a follower document
      let followerDoc = await db.collection("users")
        .doc(followingUserDoc.id.trim()).get();

      // Get a list of stories of a follower
      let storiesSnapshot = await db.collection("users")
        .doc(followerDoc.id.trim())
        .collection("stories")
        .where('timeEnd', '>=', admin.firestore.Timestamp.fromDate( new Date())).get();

      // Empty array to store stories
      let stories = [];

      // Loop through each story
      storiesSnapshot.forEach(async (storyDoc) => {
        let story = {
          id: storyDoc.id,
          data: storyDoc.data()
        };
        stories.push(story);
      });

      // check stories is empty or not
      if (stories.length > 0) {
        let user = {
          id: followerDoc.id.trim(),
          data: followerDoc.data(),
          stories: stories
        };
        response.push(user);
      }


    }
    
    return res.status(200).json({ response: response });
  } catch {
    return res.status(500).json({ error: error });
  }
};


module.exports = {
  get_all_user,
  get_stories
};
