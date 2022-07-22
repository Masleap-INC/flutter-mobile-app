const functions = require("firebase-functions");
const admin = require("firebase-admin");
//admin.initializeApp(functions.config().firebase);
let serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://inkistry-67d82.firebaseio.com"
});

const cors = require("cors");
const bodyParser = require("body-parser");
const express = require("express");
const route = require("./routes/routes");
const app = express();
app.use(cors({ origin: true }));


const middleware = async (req, res, next) => {

  let idToken
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
    console.log('Found "Authorization" header')
    // Read the ID Token from the Authorization header.
    idToken = req.headers.authorization.split('Bearer ')[1]
  } else if (req.cookies) {
    console.log('Found "__session" cookie')
    // Read the ID Token from cookie.
    idToken = req.cookies.__session
  } else {
    // No cookie
    res.status(403).send('Unauthorized')
    return -1
  }

  try {
    const decodedIdToken = await admin.auth().verifyIdToken(idToken)
    console.log('ID Token correctly decoded', decodedIdToken)
    req.idToken = idToken
    req.user = decodedIdToken
    req.uid = decodedIdToken.uid
    req.email = (await admin.auth().getUser(decodedIdToken.uid)).email
    next()
    return -1
  } catch (error) {
    console.error('Error while verifying Firebase ID token:', error)
    res.status(403).send('Unauthorized')
    return -1
  }
}

app.use(express.urlencoded({ extended: true }))
app.use(express.json())
app.use(middleware)
app.use(route);

app.use((req, res) => {
  res.status(404).send("Error: endpoint not found");
});


exports.api = functions.runWith({
    timeoutSeconds: 540,
    memory: '1GB'
  }).https.onRequest(app)


exports.onFollowUser = functions.firestore
    .document("/users/{userId}/userFollowers/{followerId}")
    .onCreate(require('./triggers/onFollowUser').handler);

exports.onUnfollowUser = functions.firestore
    .document("/users/{userId}/userFollowers/{followerId}")
    .onDelete(require('./triggers/onUnfollowUser').handler);

exports.onUploadPost = functions.firestore
    .document("/posts/{postId}")
    .onCreate(require('./triggers/onUploadPost').handler);

exports.onUpdatePost = functions.firestore
    .document("/posts/{postId}")
    .onUpdate(require('./triggers/onUpdatePost').handler);

exports.onDeletePost = functions.firestore
    .document("/posts/{postId}")
    .onDelete(require('./triggers/onDeletePost').handler);

exports.onAddChatMessage = functions.firestore
  .document("/chats/{chatId}/messages/{messageId}")
  .onCreate(require('./triggers/onAddChatMessage').handler);

exports.onNewActivity = functions.firestore
  .document("/users/{userId}/userActivities/{activityId}")
  .onCreate(require('./triggers/onNewActivity').handler);
