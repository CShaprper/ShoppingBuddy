//
//  ShoppingBuddyMessageWebService.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 30.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ShoppingBuddyMessageWebservice {
    
    var alertMessageDelegate: IAlertMessageDelegate?
    var activityAnimationServiceDelegate: IActivityAnimationService?
    internal var sbUserService:ShoppingBuddyUserWebservice!
    
    internal var ref = Database.database().reference()
    internal var userRef = Database.database().reference().child("users")
    
    init() {
        sbUserService = ShoppingBuddyUserWebservice()
    }
    
    func SendWillGoToStoreMessage(list: ShoppingList) -> Void {
        
        self.ShowActivityIndicator()
        let msgTitle = String.localizedStringWithFormat(String.WillGoShoppingMessageTitle, currentUser!.nickname!)
        let msgMessage = String.localizedStringWithFormat(String.WillGoShoppingMessageMessage, currentUser!.nickname!, list.relatedStore!, list.name!)
        
        self.ref.child("messages").childByAutoId().updateChildValues(["senderID":Auth.auth().currentUser!.uid, "message":msgMessage, "title":msgTitle, "listID":list.id!, "messageType":eNotificationType.WillGoShoppingMessage.rawValue]) { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            self.HideActivityIndicator()
            NSLog("Succesfully added Will Go Shopping to messages")
            
        }
    }
    
    
    //Share Functions
    func SendFriendSharingInvitation(friendsEmail:String, list: ShoppingList, listOwner: ShoppingBuddyUser) -> Void {
        
        self.ShowActivityIndicator()
        
        userRef.queryOrdered(byChild: "email").queryEqual(toValue: friendsEmail).observe(.value, with: { (snapshot) in
            
            if snapshot.value is NSNull {
                
                let title = String.UserEmailNotFoundTitle
                let message = String.localizedStringWithFormat(String.UserEmailNotFoundMessage, friendsEmail)
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            for childs in snapshot.children {
                
                let receipt = childs as! DataSnapshot
                
                //Write invitation Data to receipt ref
                let msgRef = self.ref.child("messages").childByAutoId()
                let inviteTitle = String.localizedStringWithFormat(String.ShareListTitle , listOwner.nickname!)
                let inviteMessage = String.localizedStringWithFormat(String.ShareListMessage, listOwner.nickname!) 
                
                //Add receipt to message_receipts node before creating message
                self.ref.child("message_receipts").child(msgRef.key).updateChildValues([receipt.key:"receipt"], withCompletionBlock: { (error, dbRef) in
                    
                    if error != nil {
                        
                        NSLog(error!.localizedDescription)
                        let title = String.OnlineFetchRequestError
                        let message = error!.localizedDescription
                        self.ShowAlertMessage(title: title, message: message)
                        return
                        
                    }
                    
                    msgRef.updateChildValues(["senderID":currentUser!.id!, "message":inviteMessage, "title":inviteTitle, "listID":list.id!, "messageType":eNotificationType.SharingInvitation.rawValue], withCompletionBlock: { (error, dbRef) in
                        
                        if error != nil {
                            
                            NSLog(error!.localizedDescription)
                            let title = String.OnlineFetchRequestError
                            let message = error!.localizedDescription
                            self.ShowAlertMessage(title: title, message: message)
                            return
                            
                        }
                        
                        self.HideActivityIndicator()
                        NSLog("Succesfully added SharingInvitation to messages")
                        
                    })
                    
                })
                
            }
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            return
            
        }
    }
    
    func AcceptInvitation(invitation: ShoppingBuddyMessage) -> Void {
        
        self.ShowActivityIndicator()
        let inviteAccepetdMessage = String.localizedStringWithFormat(String.ShareListAcceptedMessage, currentUser!.nickname!)
        
        let msgRef = ref.child("messages").childByAutoId()
        
        //Add receipt to sharing accepted message before creating message
        self.ref.child("message_receipts").child(msgRef.key).child(invitation.senderID!).setValue("receipt", withCompletionBlock: { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            //delete sharing invitation message after accepted and before sending accepted message
            self.ref.child("messages").child(invitation.id!).removeValue(completionBlock: { (error, dbRef) in
                
                if error != nil {
                    
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                }
                
                //delete all users_messages node related to the invitation message
                for receipt in invitation.receipts {
                    
                    self.ref.child("users_messages").child(receipt.memberID!).child(invitation.id!).removeValue(completionBlock: { (error, dbRef) in
                        
                        if error != nil {
                            
                            NSLog(error!.localizedDescription)
                            let title = String.OnlineFetchRequestError
                            let message = error!.localizedDescription
                            self.ShowAlertMessage(title: title, message: message)
                            return
                            
                        }
                        
                        //Add invite accepted message
                        msgRef.updateChildValues(["senderID":currentUser!.id!, "message":inviteAccepetdMessage, "title":String.ShareListAcceptedTitle, "listID":invitation.listID!, "messageType":eNotificationType.SharingAccepted.rawValue], withCompletionBlock: { (error, dbRef) in
                            
                            if error != nil {
                                
                                NSLog(error!.localizedDescription)
                                let title = String.OnlineFetchRequestError
                                let message = error!.localizedDescription
                                self.ShowAlertMessage(title: title, message: message)
                                return
                                
                            }
                            
                            self.HideActivityIndicator()
                            NSLog("Successfully accepted invite node")
                            
                        })
                        
                        
                    })
                    
                }
                
            })
            
            
        })
        
    }
    
    func DeclineSharingInvitation(message: ShoppingBuddyMessage) -> Void {
        
        
        let msgRef = ref.child("messages").childByAutoId()
        ref.child("message_receipts").child(msgRef.key).child(message.senderID!).setValue("DeclineSharingInvitation") { (error, dbRef) in
        
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            
            //delete sharing invitation message after declined and before sending accepted message
            self.ref.child("messages").child(message.id!).removeValue(completionBlock: { (error, dbRef) in
                
                if error != nil {
                    
                    NSLog(error!.localizedDescription)
                    let title = String.OnlineFetchRequestError
                    let message = error!.localizedDescription
                    self.ShowAlertMessage(title: title, message: message)
                    return
                    
                }

                //delete all users_messages node related to the invite message
                for receipt in message.receipts {
                    
                    self.ref.child("users_messages").child(receipt.memberID!).child(message.id!).removeValue(completionBlock: { (error, dbRef) in
                        
                        if error != nil {
                            
                            NSLog(error!.localizedDescription)
                            let title = String.OnlineFetchRequestError
                            let message = error!.localizedDescription
                            self.ShowAlertMessage(title: title, message: message)
                            return
                            
                        }
                        
                        //Add invite declined message
                        let title = String.SharingDeclinedMessageTitle
                        let msg = String.localizedStringWithFormat(String.SharingDeclinedMessageMessage, currentUser!.nickname!)
                        msgRef.updateChildValues(["senderID":currentUser!.id!, "message":msg, "title":title, "listID":message.listID!, "messageType":eNotificationType.DeclinedSharingInvitation.rawValue], withCompletionBlock: { (error, dbRef) in
                            
                            if error != nil {
                                
                                NSLog(error!.localizedDescription)
                                let title = String.OnlineFetchRequestError
                                let message = error!.localizedDescription
                                self.ShowAlertMessage(title: title, message: message)
                                return
                                
                            }
                            
                            self.HideActivityIndicator()
                            NSLog("Successfully accepted invite node")
                            
                        })
                        
                        
                    })
                    
                }
                
            })
            
        }
        
        
    }
    
    func DeleteMessage(messageID: String) -> Void {
        
        self.ShowActivityIndicator()
        ref.child("users_messages").child(currentUser!.id!).child(messageID).removeValue { (error, dbRef) in
            
            if error != nil {
                
                NSLog(error!.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error!.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                return
                
            }
            self.HideActivityIndicator()
            NSLog("Successfully removed invite accepted message")
        }
        
    }
    
    func ObserveAllMessages() -> Void {
        
        if currentUser?.id == nil { return }
        ShowActivityIndicator()
        
        ref.child("users_messages").child(currentUser!.id!).observe(.value, with: { (alluserMessagesSnap) in
            
            allMessages = []
            
            if alluserMessagesSnap.value is NSNull {
                
                allMessages = []
                self.HideActivityIndicator()
                NotificationCenter.default.post(name: Notification.Name.AllInvitesReceived, object: nil, userInfo: nil)
                return
                
            }
            
            for messages in alluserMessagesSnap.children {
                
                let msg = messages as! DataSnapshot
                self.ObserveMessage(messageID: msg.key)
                
            }
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
        
    }
    
    
    func ObserveMessage(messageID:String) -> Void {
        
        ShowActivityIndicator()
        ref.child("messages").child(messageID).observeSingleEvent(of: .value, with: { (messageSnap) in
            
            if messageSnap.value is NSNull { self.HideActivityIndicator(); return }
            
            var newMsg = ShoppingBuddyMessage()
            newMsg.id = messageSnap.key
            newMsg.message = messageSnap.childSnapshot(forPath: "message").value as? String
            newMsg.title = messageSnap.childSnapshot(forPath: "title").value as? String
            newMsg.listID = messageSnap.childSnapshot(forPath: "listID").value as? String
            newMsg.senderID = messageSnap.childSnapshot(forPath: "senderID").value as? String
            newMsg.messageType = messageSnap.childSnapshot(forPath: "messageType").value as? String
            
            
            self.ref.child("message_receipts").child(messageID).observeSingleEvent(of: .value, with: { (receiptsSnap) in
                
                //get all receipts
                var newReceipts = [ShoppingListMember]()
                for receipts in receiptsSnap.children {
                    
                    let receipt = receipts as! DataSnapshot
                    var member = ShoppingListMember()
                    member.memberID = receipt.key
                    member.status = receipt.value as? String
                    newReceipts.append(member)
                    
                    self.getUser(userID: member.memberID!)
                    
                }
                newMsg.receipts = newReceipts
                
                if let index = allMessages.index(where: { $0.id == newMsg.id }) {
                    
                    allMessages[index] = newMsg
                    
                } else {
                    
                    allMessages.append(newMsg)
                    
                }
                    
                    //all invites received so lets inform userWebservice to download all users
                    NotificationCenter.default.post(name: Notification.Name.AllInvitesReceived, object: nil, userInfo: nil)
                    
                
                self.HideActivityIndicator()
                
            }, withCancel: { (error) in
                
                
                NSLog(error.localizedDescription)
                let title = String.OnlineFetchRequestError
                let message = error.localizedDescription
                self.ShowAlertMessage(title: title, message: message)
                
            })
            
            
        }) { (error) in
            
            NSLog(error.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
            
        }
    }
    
    private func getUser(userID:String) -> Void {
        
        //download user if unknown
        if let _ = allUsers.index(where: { $0.id == userID }) { }
        else {
            sbUserService.ObserveUser(userID:userID, dlType: .DownloadForMessagesController)
        }
    }
}
extension ShoppingBuddyMessageWebservice: IAlertMessageDelegate, IActivityAnimationService {
    
    //MARK: - IActivityAnimationService implementation
    func ShowActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
                self.activityAnimationServiceDelegate!.ShowActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. ShowActivityIndicator in ShoppingBuddyMessageWebservice")
        }
    }
    func HideActivityIndicator() {
        if activityAnimationServiceDelegate != nil {
            OperationQueue.main.addOperation {
                self.activityAnimationServiceDelegate!.HideActivityIndicator!()
            }
        } else {
            NSLog("activityAnimationServiceDelegate not set from calling class. HideActivityIndicator in ShoppingBuddyMessageWebservice")
        }
    }
    
    //MARK: IAlertMessageDelegate implementation
    func ShowAlertMessage(title: String, message: String) {
        self.HideActivityIndicator()
        if alertMessageDelegate != nil {
            OperationQueue.main.addOperation {
                self.alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
            }
        } else {
            NSLog("AlertMessageDelegate not set from calling class in ShoppingBuddyMessageWebservice")
        }
    }
    
}
