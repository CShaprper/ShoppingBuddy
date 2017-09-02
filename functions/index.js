//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin'); 
admin.initializeApp(functions.config().firebase); 

//register to onWrite event of my node news
exports.sendShoppingListInvitationNotification = functions.database.ref('/users/{id}/invites/{id2}').onCreate(event => {
    //get the snapshot of the written data
    const snapshot = event.data.val();

        //get snapshot values
        console.log(snapshot);  
    
    //create Notification
    const payload = {
        notification: {
            title: snapshot.inviteTitle,
            body:  snapshot.inviteMessage, 
            badge: '1',
            sound: 'default',
            sbID: String(event.data.key),
            senderImg : snapshot.senderProfileImageURL,
            senderNick : snapshot.senderNickname,
            senderID: snapshot.senderID,
            listID: snapshot.listID, 
            listname: snapshot.listName, 
            receiptID: snapshot.receiptID, 
            receiptImg : snapshot.receiptProfileImageURL,
            receiptNick: snapshot.receiptNickname, 
            receiptToken: snapshot.receiptFcmToken, 
            senderToken: snapshot.senderFcmToken, 
            notificationType: 'SharingInvitation',
        } 
    };   
    
    admin.database().ref("shoppinglists").child(snapshot.listID).child("groupMembers").child(snapshot.senderID).child('status').set('owner');
    admin.database().ref("shoppinglists").child(snapshot.listID).child("groupMembers").child(snapshot.senderID).child('profileImageURL').set(snapshot.senderProfileImageURL);
    admin.database().ref("shoppinglists").child(snapshot.listID).child("groupMembers").child(snapshot.senderID).child('nickname').set(snapshot.senderNickname);
    
    //send a notification to firends token   
    return admin.messaging().sendToDevice(snapshot.receiptFcmToken, payload).then(response => { 
         console.log("Successfully sent message:", response);
         console.log(response.results[0].error);
     }).catch((err) => { 
        console.log("Error sendung Push", err);
    });   
});

exports.updateUserListNodeOnNewListCreation = functions.database.ref('/shoppinglists/{id}').onCreate(event => {
    const snapshot = event.data;

    const listID = snapshot.key;
    const listOwnerID = snapshot.child('owneruid').val();

    console.log('Succesfully updated user node with shopping listID');

    return admin.database().ref('users').child(String(listOwnerID)).child('shoppinglists').child(String(listID)).set('owner');
});

exports.deleteItemsAndReferencesOnShoppingListDelete = functions.database.ref('/shoppinglists/{id}').onDelete( event => {
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
exports.deleteSharingInvitationAndSendPushOnSharingUpdate = functions.database.ref('users/invites/{id}').onUpdate( event => {
    const snapshot = event.data;
    console.log(snapshot.data);

    const inviteID = String(snapshot.key); 
    const inviteValue = String(snapshot.val());

    if (inviteValue == "accepted") {
        admin.database().ref('invites').child(inviteID).once('value').then(function(snap) {  
            
                    const receiptUid  = snapshot.child('receiptID').val(); 
                    const senderUid = snapshot.child('senderID').val();   
            
                   return admin.database().ref('users').child(receiptUid).child('friends').child(senderUid).set('accepted');
            
                });
    }       
     
});

function setInvitationSenderAsFriendInReceiptUserNode(inviteID) {
    admin.database().ref('invites').child(inviteID).once('value').then(function(snap) {  

        const receiptUid  = snapshot.child('receiptID').val(); 
        const senderUid = snapshot.child('senderID').val();   

       return admin.database().ref('users').child(receiptUid).child('friends').child(senderUid).set('accepted');

    });
}*/

exports.deleteEmptySpacesOnNewList = functions.database.ref('/shoppinglists/{id}').onWrite( event => {
    
          const d = event.data.val();
    
           // Exit when the data is deleted.
           if (!event.data.exists()) {
            return;
          }
    
          if(d.trimmed) { return }
    
          const name = d.listName 
          const store = d.relatedStore

          d.trimmed = true
          d.relatedStore = trimString(store)
          d.listName = trimString(name)   
            
         return event.data.ref.set(d)
    }); 
 

exports.deleteEmptySpacesItemName = functions.database.ref('/listItems/{id}/{itemID}').onWrite( event => {

      const itemdata = event.data.val();

       // Exit when the data is deleted.
       if (!event.data.exists()) {
        return;
      }

      if(itemdata.trimmed) { return }

      const str = itemdata.itemName
      itemdata.trimmed = true
      itemdata.itemName = trimString(str)   
        
     return event.data.ref.set(itemdata)
});

function trimString(str) {
    var trimmedText = String(str)
    trimmedText = trimmedText.trim()
    return trimmedText
}