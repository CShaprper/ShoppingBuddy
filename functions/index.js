//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin'); 
admin.initializeApp(functions.config().firebase); 

//register to onWrite event of my node news
exports.sendShoppingListInvitationNotification = functions.database.ref('/invites/{id}').onCreate(event => {
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
    const receiptUid  = snapshot.child('receiptID').val();    

    const userRef = admin.database().ref('users').child(String(receiptUid)).child('invites').child(String(snapshot.key)).set('pending');
  
 
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
            receiptID: `${receiptUid}`, 
        } 
    };               
    
    //send a notification to firends token   
    return admin.messaging().sendToDevice(receiptToken, payload).then(response => { 
         console.log("Successfully sent message:", response);
     }).catch((err) => {
        console.log(err);
    });   
});

exports.updateUserListNodeOnNewListCreation = functions.database.ref('/shoppinglists/{id}').onCreate(event => {
    const snapshot = event.data;

    const listID = snapshot.key;
    const listOwnerID = snapshot.child('owneruid').val();

    console.log('Succesfully updated user node with shopping listID');

    return admin.database().ref('users').child(String(listOwnerID)).child('shoppinglists').child(String(listID)).set('owner');
});

exports.deleteItemsAndReferencesOnShoppingListDelete = functions.database.ref('/shoppinglists/{id}').onDelete(event => {
    //Get prvious data before detele action
    const snapshot = event.data.previous;

    console.log(snapshot.data);

    const listID = String(snapshot.key);
    const listOwnerID = String(snapshot.child('owneruid').val());

    console.log(listID)
    console.log(listOwnerID)

        admin.database().ref('users').child(listOwnerID).child('shoppinglists').child(listID).set(null).then(() => {
            return admin.database().ref('listItems').child(String(listID)).set(null);
        })        
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