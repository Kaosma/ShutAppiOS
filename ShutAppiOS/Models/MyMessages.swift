//
//  MyMessages.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import Firebase

class MyMessages {
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    let currentUserSender = Sender(senderId: CurrentUser().email, displayName: CurrentUser().username, senderEmail: CurrentUser().email)
    var messages = [Message]()
    
    // Loading the messages from the database
    func getMessagesFromDatabase(collectionView: UICollectionView, senderUser: Sender) {
        let collection = db.collection("conversations").document(senderUser.senderId).collection("messages")
        
        // Reading from the "messages" Collection and ordering them by date
        collection.order(by: "date").addSnapshotListener { (querySnapshot, err) in
            self.messages = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let messageBody = document.data()["body"] as? String, let messageSender = document.data()["sender"] as? String, let messageDate = document.data()["date"] as? Double{
                        // If the retrieved message has currentUser as sender create a rightside Message
                        if messageSender == self.currentUser.email {
                            self.messages.append(Message(sender: self.currentUserSender, messageId: document.documentID, sentDate: Date().addingTimeInterval(messageDate), kind: .text(messageBody)))
                            
                        // Else create a leftside Message
                        } else {
                            self.messages.append(Message(sender: senderUser, messageId: document.documentID, sentDate: Date().addingTimeInterval(messageDate), kind: .text(messageBody)))
                        }
                        // Reload the MessageCollectionView and scroll to latest message
                        DispatchQueue.main.async {
                            collectionView.reloadData()
                            let indexPath = IndexPath(row: 0, section: self.messages.count - 1)
                            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    func myUserInContacts(sender: Sender) -> Bool {
        let docRef = db.collection("users").document(sender.senderEmail).collection("contacts").document(currentUser.email)
        var exists = false
        docRef.getDocument { (document, error) in
            // If the new contact's email exists -> Add the contact
            if let document = document, document.exists {
                exists = true
                
            // If the new contact's email doesn't exist -> Let the user know with an alert
            } else {
                exists = false
            }
        }
        return exists
    }
    // Adding a message from the currentUser to the "messages" collection
    func sendMessage(collectionView: UICollectionView, senderUser: Sender, body: String) {
        //if myUserInContacts(sender: senderUser) {
            let collection = db.collection("conversations").document(senderUser.senderId).collection("messages")
            collection.document().setData([
                "body": body,
                "sender": currentUser.email,
                "date": Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Message Sent")
                }
            }
        //} else {
            //print("You do not exist in the other user's contacts")
        //}
    }
}
