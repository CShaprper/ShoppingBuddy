//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin'); 
admin.initializeApp(functions.config().firebase); 

//register to onWrite event of my node news
exports.sendShoppingListInvitationNotification = functions.database.ref('/invites/{id}/').onWrite(event => {
    //get the snapshot of the written data
    const snapshot = event.data;  

    if (!event.data.exists()){
        return;
    }
    if (event.data.previous.exists()){
        return;
    }

        //get snapshot values
        console.log(snapshot.key);
    const receiptToken = snapshot.child('receiptFcmToken').val();
    const senderName = snapshot.child('senderNickname').val();
    const inviteMessage = snapshot.child('inviteMessage').val();
    const senderImage = snapshot.child('senderProfileImageURL').val();
    
 
    //create Notification
    const payload = {
        notification: {
            title: `Invitation from ${senderName}`,
            body:  `${inviteMessage}`,
            icon: `${senderImage}`,
            badge: '1',
            sound: 'default',
        }
    };               
    
    //send a notification to firends token   
    return admin.messaging().sendToDevice(receiptToken, payload).then(response => { 
         console.log("Successfully sent message:", response);
     }).catch((err) => {
        console.log(err);
    });   
});

/*
exports.deleteEmptySpacesItemName = functions.database.ref('/listItems/{id}/{itemID}').onWrite(event => {

      const data = event.data.val();

      if(data.sanitized) {
          return;
      }
      const str = data.itemName; 
        data.itemName = str.trim();   
        
        return data.ref.push(data);
});*/