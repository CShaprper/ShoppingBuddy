//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin'); 
admin.initializeApp(functions.config().firebase); 

//register to onWrite event of my node news
exports.sendShoppingListInvitationNotification = functions.database.ref('/invites/{id}').onWrite(event => {
    //get the snapshot of the written data
    const snapshot = event.data;

        //get snapshot values
        console.log(snapshot);
    
    const receiptToken = snapshot.child('receiptFcmToken').val();
    const senderName = snapshot.child('senderNickname').val();
    const inviteMessage = snapshot.child('inviteMessage').val();
    const inviteTitle = snapshot.child('inviteTitle').val();
    const senderImage = snapshot.child('senderProfileImageURL').val(); 
    const senderUid = snapshot.child('senderID').val();      
    const listUid = snapshot.child('listID').val();       
    const listName = snapshot.child('listName').val();  
 
    //create Notification
    const payload = {
        notification: {
            title: `Invitation from ${senderName}`,
            body:  `${inviteMessage}`, 
            badge: '1',
            sound: 'default',
            senderImg : `${senderImage}`,
            senderNick : `${senderName}`,
            senderID: `${senderUid}`,
            listID: `${listUid}`, 
            listname: `${listName}`, 
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