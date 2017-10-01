//Firebase functions setup
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);



//register to onWrite event of my node news
exports.send_NotificationOnNewMessage = functions.database.ref('/messages/{messageID}').onCreate(event => {

    var msgData = event.data.val()

    console.log('MessageType: ' + msgData.messageType)


    //Handle Sharing Invite
    if (String(msgData.messageType) == 'SharingInvitation') {

        //get receiptID
        return admin.database().ref('message_receipts').child(event.params.messageID).once('value').then(receiptSnap => {

            //iterate all receipts
            var promises = []
            receiptSnap.forEach(function (receipt) {
                console.log('receipt key: ' + receipt.key)

                //get receipt user Data
                console.log('get user data of receipt key: ' + receipt.key)
                promises.push(admin.database().ref('users').child(receipt.key).once('value').then(userSnap => {
                    console.log('user data: ' + userSnap.val())
                    var userData = userSnap.val()

                    //create Notification Payload
                    var payload = {
                        notification: {
                            title: msgData.title,
                            body: msgData.message,
                            badge: '1',
                            sound: 'default',
                            sbID: String(event.data.key),
                            senderID: msgData.senderID,
                            listID: msgData.listID,
                            receiptID: receipt.key,
                            notificationType: String(msgData.messageType),
                        }
                    };

                    //send push to receipts
                    console.log('Receipt token: ' + userData.fcmToken)
                    return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                        console.log("Successfully sent invite message:", response)
                        console.log(response.results[0].error)

                    }).catch((err) => { console.log("Error sending Push", err) }).then(() => {

                        //add message to users_messages node
                        return admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType))

                    })

                }))

            })

        })
    }//*********************************************************************************************************** 

    //*********************************************************************************************************** 
    //Handle Sharing Invite Accepted
    if (String(msgData.messageType) == 'SharingAccepted') {

        //add user to shoppinglist_member node
        return admin.database().ref('shoppinglist_member').child(msgData.listID).child(msgData.senderID).set('observer').then(() => {

            //add shopping list of invite sender to users_shoppinglists node
            return admin.database().ref('users_shoppinglists').child(msgData.senderID).child(msgData.listID).set('observer').then(() => {

                //add user to shoppinglist_member node
                return admin.database().ref('shoppinglist_member').child(msgData.listID).child(msgData.senderID).set('observer').then(() => {

                    //get receiptID
                    return admin.database().ref('message_receipts').child(event.params.messageID).once('value').then(receiptSnap => {

                        //iterate all receipts
                        var promises = []
                        receiptSnap.forEach(function (receipt) {
                            console.log('receipt key: ' + receipt.key)

                            //add message key to users_messages for each receipt
                            promises.push(admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType)).then(() => {

                                //add message to users_messages node
                                return admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType)).then(() => {

                                    //get receipt user Data
                                    return admin.database().ref('users').child(receipt.key).once('value').then(userSnap => {
                                        console.log('user data: ' + userSnap.val())
                                        var userData = userSnap.val()

                                        //create Notification Payload
                                        var payload = {
                                            notification: {
                                                title: msgData.title,
                                                body: msgData.message,
                                                badge: '1',
                                                sound: 'default',
                                                sbID: String(event.data.key),
                                                senderID: msgData.senderID,
                                                listID: msgData.listID,
                                                receiptID: receipt.key,
                                                notificationType: String(msgData.messageType),
                                            }
                                        };

                                        //send push to receipts
                                        return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                                            console.log("Successfully sent Sharing Accepted message:", response)
                                            console.log(response.results[0].error)


                                        }).catch((err) => { console.log("Error sending Push", err) })

                                    })

                                })

                            }))

                        })

                    })

                })

            })

        })

    }//*********************************************************************************************************** 

    if (String(msgData.messageType) == 'DeclinedSharingInvitation') {

        //get receiptID
        return admin.database().ref('message_receipts').child(event.params.messageID).once('value').then(receiptSnap => {

            //iterate all receipts
            var promises = []
            receiptSnap.forEach(function (receipt) {

                //get receipt user Data
                promises.push(admin.database().ref('users').child(receipt.key).once('value').then(userSnap => {

                    var userData = userSnap.val()
                    //create Notification Payload
                    var payload = {
                        notification: {
                            title: msgData.title,
                            body: msgData.message,
                            badge: '1',
                            sound: 'default',
                            sbID: String(event.data.key),
                            senderID: msgData.senderID,
                            listID: msgData.listID,
                            receiptID: receipt.key,
                            notificationType: String(msgData.messageType),
                        }
                    };

                    //send push to receipts
                    console.log('Receipt token: ' + userData.fcmToken)
                    return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                        console.log("Successfully sent invite message:", response)
                        console.log(response.results[0].error)

                    }).catch((err) => { console.log("Error sending Push", err) }).then(() => {

                        //add message to users_messages node
                        return admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType))

                    })

                }))

            })

        })

    }

    //*********************************************************************************************************** 
    //handle cancel sharing by Owner message
    if (String(msgData.messageType) == 'CancelSharingByOwner') {

        //get receiptID
        return admin.database().ref('shoppinglist_member').child(msgData.listID).once('value').then(receiptSnap => {

            //iterate all receipts
            var promises = []
            receiptSnap.forEach(function (receipt) {

                // dont send message to List owner he canceled the sharing and dont needs to be informed
                console.log('receipt key ', receipt.key)
                console.log('msgData.senderID ', msgData.senderID)
                if (receipt.key != msgData.senderID) {

                    //add message key to users_messages for each receipt
                    promises.push(admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType)).then(() => {

                        if (msgData.userIDToDelete == receipt.key) {

                            //add receipt to message_receipts node
                            return admin.database().ref('message_receipts').child(event.params.messageID).child(receipt.key).set('CancelSharingMessage_Receipt').then(() => {

                                // delete member from shoppinglist
                                return admin.database().ref('shoppinglist_member').child(msgData.listID).child(receipt.key).set(null).then(() => {

                                    //delete shopping list from sharing canceled users_shoppinglists
                                    return admin.database().ref('users_shoppinglists').child(receipt.key).child(msgData.listID).set(null).then(() => {

                                        //Send member push
                                        return admin.database().ref('/users/' + receipt.key).once('value').then(usnap => {

                                            //Send push to users fcmToken
                                            var userSnap = usnap.val()
                                            console.log('sending Push to ' + userSnap.fcmToken)

                                            //create Notification Payload
                                            var payload = {
                                                notification: {
                                                    title: msgData.title,
                                                    body: msgData.message,
                                                    badge: '1',
                                                    sound: 'default',
                                                    sbID: String(event.data.key),
                                                    senderID: msgData.senderID,
                                                    listID: msgData.listID,
                                                    receiptID: receipt.key,
                                                    notificationType: String(msgData.messageType),
                                                }
                                            };

                                            return admin.messaging().sendToDevice(userSnap.fcmToken, payload).then(response => {

                                                console.log("Successfully sent Cancel Sharing by Owner message:", response)
                                                console.log(response.results[0].error)

                                            }).catch((err) => { console.log("Error sending Push", err) })

                                        })
                                    })

                                })

                            })

                        } else {

                            //add receipt to message_receipts node
                            return admin.database().ref('message_receipts').child(receipt.key).set('CancelSharingMessage_Receipt').then(() => {

                                //Send member push
                                return admin.database().ref('/users/' + receipt.key).once('value').then(usnap => {

                                    //Send push to users fcmToken
                                    var userSnap = usnap.val()
                                    console.log('sending Push to ' + userSnap.fcmToken)

                                    //create Notification Payload
                                    var payload = {
                                        notification: {
                                            title: msgData.title,
                                            body: msgData.message,
                                            badge: '1',
                                            sound: 'default',
                                            sbID: String(event.data.key),
                                            senderID: msgData.senderID,
                                            listID: msgData.listID,
                                            receiptID: receipt.key,
                                            notificationType: String(msgData.messageType),
                                        }
                                    };

                                    return admin.messaging().sendToDevice(userSnap.fcmToken, payload).then(response => {

                                        console.log("Successfully sent Canceled sharing by Owner message:", response)
                                        console.log(response.results[0].error)

                                    }).catch((err) => { console.log("Error sending Push", err) })

                                })

                            })

                        }

                    }))
                }

            })

        })

    }//*********************************************************************************************************** 

    //*********************************************************************************************************** 
    //handle cancel sharing by Shared User message
    if (String(msgData.messageType) == 'CancelSharingBySharedUser') {

        //delete shopping list from your own users_shoppinglists
        return admin.database().ref('users_shoppinglists').child(msgData.senderID).child(msgData.listID).set(null).then(() => {

            //get message receipts receiptID
            return admin.database().ref('shoppinglist_member').child(msgData.listID).once('value').then(memberSnap => {

                //iterate all receipts
                var promises = []
                memberSnap.forEach(function (receipt) {

                    //Set message key at user_messages 
                    promises.push(admin.database().ref('users_messages').child(receipt.key).child(event.params.messageID).set(String(msgData.messageType)).then(() => {

                        //Send push all other list members 
                        return admin.database().ref('shoppinglist_member').child(msgData.listID).once('value').then(memberSnap => {

                            var promises = []
                            memberSnap.forEach(function (listMember) {

                                promises.push(admin.database().ref('users').child(listMember.key).once('value').then(userSnap => {

                                    var userData = userSnap.val()

                                    console.log('sending Push to ' + userData.fcmToken)

                                    //create Notification Payload
                                    var payload = {
                                        notification: {
                                            title: msgData.title,
                                            body: msgData.message,
                                            badge: '1',
                                            sound: 'default',
                                            sbID: String(event.data.key),
                                            senderID: msgData.senderID,
                                            listID: msgData.listID,
                                            receiptID: listMember.key,
                                            notificationType: String(msgData.messageType),
                                        }
                                    }

                                    return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                                        console.log("Successfully sent list item added message:", response)
                                        console.log(response.results[0].error)

                                    }).catch((err) => { console.log("Error sending Push", err) })

                                }))

                            })

                        })

                    }))

                })
            })

        })

    }//*********************************************************************************************************** 


    //*********************************************************************************************************** 
    //handle list item added by shared user
    //*********************************************************************************************************** 
    if (String(msgData.messageType) == 'ListItemAddedBySharedUser') {

        return admin.database().ref('shoppinglist_member').child(msgData.listID).once('value').then(memberSnap => {

            var promises = []
            memberSnap.forEach(function (listMember) {

                promises.push(admin.database().ref('users').child(listMember.key).once('value').then(userSnap => {

                    var userData = userSnap.val()

                    if (msgData.senderID != userSnap.key) {

                        console.log('sending Push to ' + userData.fcmToken)

                        //create Notification Payload
                        var payload = {
                            notification: {
                                title: msgData.title,
                                body: msgData.message,
                                badge: '1',
                                sound: 'default',
                                sbID: String(event.data.key),
                                senderID: msgData.senderID,
                                listID: msgData.listID,
                                receiptID: listMember.key,
                                notificationType: String(msgData.messageType),
                            }
                        }

                        return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                            console.log("Successfully sent list item added message:", response)
                            console.log(response.results[0].error)

                        }).catch((err) => { console.log("Error sending Push", err) })

                    }

                }))

                //remove message
                console.log('deleting message')
                return admin.database().ref('messages').child(event.params.messageID).set(null)

            })

        })

    }//*********************************************************************************************************** 

    //*********************************************************************************************************** 
    //handle Will go for shopping message
    //*********************************************************************************************************** 
    if (String(msgData.messageType) == 'WillGoShoppingMessage') {

        return admin.database().ref('shoppinglist_member').child(msgData.listID).once('value').then(memberSnap => {

            var promises = []
            memberSnap.forEach(function (listMember) {

                promises.push(admin.database().ref('users').child(listMember.key).once('value').then(userSnap => {

                    var userData = userSnap.val()

                    if (msgData.senderID != userSnap.key) {

                        return admin.database().ref('users_messages').child(listMember.key).child(event.params.messageID).set(String(msgData.messageType)).then(() => {

                            //add receipt to message_receipts node
                            return admin.database().ref('message_receipts').child(event.params.messageID).child(listMember.key).set('WillGoShoppingMessage_Receipt').then(() => {

                                console.log('sending Push to ' + userData.fcmToken)

                                //create Notification Payload
                                var payload = {
                                    notification: {
                                        title: msgData.title,
                                        body: msgData.message,
                                        badge: '1',
                                        sound: 'default',
                                        sbID: String(event.data.key),
                                        senderID: msgData.senderID,
                                        listID: msgData.listID,
                                        receiptID: listMember.key,
                                        notificationType: String(msgData.messageType),
                                    }
                                }

                                return admin.messaging().sendToDevice(userData.fcmToken, payload).then(response => {

                                    console.log("Successfully sent list item added message:", response)
                                    console.log(response.results[0].error)

                                }).catch((err) => { console.log("Error sending Push", err) })


                            })

                        })
                    }

                }))

            })

        })

    }//*********************************************************************************************************** 
});

//****************************************************************************************************************/
// Handles an action when status value changed in users_shoppinglists node
//****************************************************************************************************************/
exports.handle_ListStatusUpdate = functions.database.ref('/shoppinglists/{listID}').onUpdate(event => {

    var listData = event.data.val()
    console.log('Status', listData.status)

    //handle deleted by owner
    if (String(listData.status) == 'deleted by owner') {

        // delete the original shopping list
        return admin.database().ref('shoppinglists').child(event.params.listID).set(null).then(() => {

            return admin.database().ref('listItems').child(event.params.listID).set(null).then(() => {

                //Get all members to delete the list on their users_shoppinglists node
                return admin.database().ref('shoppinglist_member').child(event.params.listID).once('value').then(listMember => {

                    var promises = []
                    listMember.forEach(function (member) {

                        promises.push(admin.database().ref('users_shoppinglists').child(member.key).child(event.params.listID).set(null))

                    })

                })

            })

        })

    }

});/*********************************************************************************************************** */

//****************************************************************************************************************/
// Add shopping list key to users_shoppinglists on new list create
// Then add userID to shoppinglist_member/listID node
//****************************************************************************************************************/
exports.handle_NewShoppingList_OnCreate = functions.database.ref('/shoppinglists/{listID}').onCreate(event => {

    //get current userID
    var memberID = event.auth.variable ? event.auth.variable.uid : null
    //add 
    return admin.database().ref('/users_shoppinglists/').child(memberID).child(event.params.listID).set('owner').then(() => {

        return admin.database().ref('shoppinglist_member').child(event.params.listID).child(memberID).set('owner')

    })

});


//****************************************************************************************************************/
// Handles users_messages/messageID delete action
//****************************************************************************************************************/
exports.handle_UsersMessages_MessageDelete = functions.database.ref('/users_messages/{userID}/{messageID}').onDelete(event => {

    //user deleted message in users_Messages node so lets delete user on Message/receipts node
    return admin.database().ref('message_receipts').child(event.params.messageID).set(null)

})

//****************************************************************************************************************/
// Handles messages/messageID/message_receipts all receipts deleted
//****************************************************************************************************************/
exports.handle_Messages_AllMessageReceipts_Deleted = functions.database.ref('/message_receipts/{messageID}').onDelete(event => {

    //all receipts are deleted so lets delete parent message
    return admin.database().ref('messages').child(event.params.messageID).set(null)

})

//****************************************************************************************************************/
// Removes empty spaces in listName and relatedStore
//****************************************************************************************************************/
exports.deleteEmptySpacesOnNewListCreate = functions.database.ref('/shoppinglists/{id}').onCreate(event => {

    var d = event.data.val();

    // Exit when the data is deleted.
    if (!event.data.exists()) {
        return;
    }

    if (d.trimmed) { return }

    const name = d.listName
    const store = d.relatedStore

    d.trimmed = true
    d.relatedStore = trimString(store)
    d.listName = trimString(name)

    return event.data.ref.set(d)
});

//****************************************************************************************************************/
// Removes empty spaces when listItem is created
//****************************************************************************************************************/
exports.deleteEmptySpacesItemNameonCreate = functions.database.ref('/listItems/{id}/{itemID}').onCreate(event => {

    const itemdata = event.data.val();

    // Exit when the data is deleted.
    if (!event.data.exists()) {
        return;
    }

    if (itemdata.trimmed) { return }

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