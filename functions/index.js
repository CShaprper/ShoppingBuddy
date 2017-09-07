//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin'); 
admin.initializeApp(functions.config().firebase); 

//register to onWrite event of my node news
exports.send_ShoppingListInvitationNotification = functions.database.ref('/invites/{id}').onCreate(event => {
    const snapshot = event.data.val();

    //log snapshot values
    console.log(snapshot);  
    return admin.database().ref('/users_friends/').child(snapshot.senderID).child(snapshot.receiptID).set('pending').then( snap => { 

        return admin.database().ref('/users_friends/').child(snapshot.receiptID).child(snapshot.senderID).set('pending').then( ufriendsSnap => {

            return admin.database().ref('/users_invites/').child(snapshot.receiptID).child(event.params.id).set('pending').then( snap => {

            //Get the receipt users values for sending Push
            console.log('snapshot.receiptID: ' + snapshot.receiptID)
               
            return admin.database().ref('/users/' + snapshot.receiptID).once('value').then( usnap => { 
               
                //Send push to users fcmToken
                const userSnap = usnap.val()
                console.log('sending Push to ' + userSnap.fcmToken)
                
                //create Notification
                var payload = {
                    notification: {
                        title: snapshot.inviteTitle,
                        body:  snapshot.inviteMessage, 
                        badge: '1',
                        sound: 'default',
                        sbID: String(event.data.key),
                        senderID: snapshot.senderID,
                        listID: snapshot.listID, 
                        receiptID: snapshot.receiptID, 
                        notificationType: 'SharingInvitation',
                    } 
                };             
               
                return admin.messaging().sendToDevice(userSnap.fcmToken, payload).then( response => {
               
                    console.log("Successfully sent invite message:", response)
                    console.log(response.results[0].error)
               
                }).catch((err) => {  console.log("Error sending Push", err) })

            })
                                   
            }) 
        })
    })
});       

exports.delete_AllItemsAndReferencesOnShoppingListDelete = functions.database.ref('/users_shoppinglists/{userID}/{listID}').onDelete( event => { 
    //Get previous data before detele action
   // const snapshot = event.data.previous
    var listID = event.params.listID
    var userID = event.params.userID

    console.log('userID: ' + userID + 'listID : ' + listID) 

      return admin.database().ref('shoppinglists').child(listID).set(null).then( () => {
            return admin.database().ref('listItems').child(listID).set(null) 
        })     
});

exports.add_NewListIDToUsersListsNodeOnCreate = functions.database.ref('/shoppinglists/{id}').onCreate( event => {
    var uid = event.auth.variable ? event.auth.variable.uid : null
    var listID = event.params.id
    console.log('key: ' + listID)
    console.log('uid: ' + uid)

    return admin.database().ref('/shoppinglists/' + listID).child('members').child(uid).set('owner').then( () => {
        return admin.database().ref('/users_shoppinglists/').child(uid).child(listID).set('owner')
    })
}); 

exports.delete_Invite_AfterAccepted_SetFriendAcceptes = functions.database.ref('/invites/{inviteID}').onUpdate( event => {
    var inviteSnap = event.data.val()
    var senderID = inviteSnap.senderID
    var receiptID = inviteSnap.receiptID
    var listID = inviteSnap.listID
    var inviteID = event.params.inviteID
    var inviteAcceptedTitle = inviteSnap.inviteAcceptedTitle
    var inviteAcceptedMessage = inviteSnap.inviteAcceptedMessage

    console.log(inviteSnap.status)

    if (inviteSnap.status != 'accepted') { return }

    return admin.database().ref('/users_invites/' + receiptID + '/' + inviteID).set(null).then( snap => {

        return admin.database().ref('/shoppinglists/' + listID +'/members/').child(receiptID).set('observer').then( listSnap => {

            return admin.database().ref('/users_friends/' + senderID).child(receiptID).set('accepted').then( usersFriendsSnap => {

                return admin.database().ref('/users_friends/' + receiptID).child(senderID).set('accepted').then( usersFriendsSnap2 => {

                    return admin.database().ref('/invites/' + inviteID).set(null).then( inviteSnap => {

                        return admin.database().ref('/users_shoppinglists/').child(receiptID).child(listID).set('observer').then( snoop => {

                            return admin.database().ref('/users/' + senderID).once('value').then( uSnap => {

                                var userSnap = uSnap.val()
                                console.log('sending Push to ' + userSnap.fcmToken)

                                 //create Notification
                                var payload = {
                                    notification: {
                                        title: String(inviteAcceptedTitle),
                                        body: String(inviteAcceptedMessage), 
                                        badge: '1',
                                        sound: 'default', 
                                        senderID: receiptID,
                                        listID: listID, 
                                        receiptID: senderID, 
                                        notificationType: 'SharingAccepted',
                                    } 
                                }

                                return admin.messaging().sendToDevice(userSnap.fcmToken, payload).then( response => {
                                    
                                         console.log("Successfully sent sharing accepted message:", response)
                                         console.log(response.results[0].error)
                                    
                                     }).catch((err) => {  console.log("Error sending Push", err) })


                            })

                        })

                    }) 

                })

            })

        })

    }) 

});



exports.deleteEmptySpacesOnNewListCreate = functions.database.ref('/shoppinglists/{id}').onCreate( event => {
    
          var d = event.data.val();
    
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
 

exports.deleteEmptySpacesItemNameonCreate = functions.database.ref('/listItems/{id}/{itemID}').onCreate( event => {

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