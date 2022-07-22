const admin = require('firebase-admin')
const functions = require('firebase-functions')

exports.handler = async (snapshot, context) => {
  functions.logger.info('ENTRY::onAddChatMessage')

  const chatId = context.params.chatId;
  const messageData = snapshot.data();

  const chatRef = admin.firestore().collection("chats").doc(chatId);
  // Get chat document
  const chatDoc = await chatRef.get();
  const chatData = chatDoc.data();

  if (chatDoc.exists) {
    // Update read status to false
    const readStatus = chatData.readStatus;
    for (let userId in readStatus) {
      if (
        readStatus.hasOwnProperty(userId) &&
        userId !== messageData.senderId
      ) {
        readStatus[userId] = false;
      }
    }

    var chatRequest = chatData.chatRequest;

    if(chatData.chatRequest === true) {
        chatRequest = (chatData.recentSender !== chatData.requestedBy);
    }

    // Update the chat doc
    chatRef.update({
      recentMessage: messageData.text,
      recentSender: messageData.senderId,
      recentTimestamp: messageData.timeCreated,
      readStatus: readStatus,
      chatRequest: chatRequest,
    });
  }
}