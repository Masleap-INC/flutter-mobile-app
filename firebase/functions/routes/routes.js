const express = require("express");
const router = express.Router();
const firestore = require("../controllers/firestoreControllers");

router.get("/user", firestore.get_all_user);
router.get("/stories", firestore.get_stories);

router.get("/", (req, res) => {
  res.status(200).send("Welcome Inkistry People");
});

module.exports = router;
