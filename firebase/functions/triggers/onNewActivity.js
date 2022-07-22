const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
  functions.logger.info('ENTRY::onNewActivity')

  // receiverUserId
  const userId = context.params.userId;

  const activityData = snapshot.data();
  const senderUserRef = admin
    .firestore()
    .collection("users")
    .doc(activityData.fromUserId);

  // Get the message sender - user document
  const senderUserSnapshot = await senderUserRef.get();
  if (!senderUserSnapshot.exists) {
    return;
  }

  const senderUserData = senderUserSnapshot.data();
  let event;
  let senderName = senderUserData.name;
  let body;

  // Check for the message event
  if (activityData.isFollowEvent === true) {
    event = "isFollowEvent";
    body = "Started following you!";
  } else if (activityData.isLikeEvent === true) {
    event = "isLikeEvent";
    if (activityData.comment !== null) {
      body = `Liked your post: "${activityData.comment}"`;
    } else {
      body = `Liked your post`;
    }
  } else if (activityData.isCommentEvent === true) {
    event = "isCommentEvent";
    body = `Commented on your post: "${activityData.comment}"`;
  } else if (activityData.isMessageEvent === true) {
    event = "isMessageEvent";
    if (activityData.comment !== null) {
      body = `Sent a message: "${activityData.comment}"`;
    } else {
      body = `Sent a file message`;
    }
  } else if (activityData.isLikeMessageEvent === true) {
    event = "isLikeMessageEvent";
    if (activityData.comment !== null) {
      body = `Liked your message: "${activityData.comment}"`;
    } else {
      body = `Liked your message file`;
    }
  }

  // If there is a receiver token && the message event matches the events above
  if (
    activityData.receiverToken !== null &&
    activityData.receiverToken.length > 1 &&
    event !== null
  ) {
    const payload = {
      notification: {
        title: senderName,
        body: body,
        image: senderUserData.imageUrl,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };
    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };
    // Send push notifications
    admin
      .messaging()
      .sendToDevice(activityData.receiverToken, payload, options);
  }

  // Set new activity to true
  let data = {
    'haveNewActivity': true,
  };

  // If this activity is message event or like message event - delete doc
  if (activityData.isLikeMessageEvent || activityData.isMessageEvent) {
    data.haveNewActivity = false;
    snapshot.ref.delete();
  }

  let document = await admin
     .firestore()
     .collection("users")
     .doc(userId).get();

  if (document && document.exists) {
    document.ref.update(data);
  }
  else {
    document.ref.set(data, { merge: true });
  }

}


