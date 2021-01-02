//
//  MyMessages.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import Firebase
import CryptoSwift

// MARK: Class Declaration
class MyMessages {
    
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    let currentUserSender = Sender(senderId: CurrentUser().email, displayName: CurrentUser().username, senderEmail: CurrentUser().email)
    var messages = [Message]()
    
    // MARK: Chat Functions
    // Loading the messages from the database
    func getMessagesFromDatabase(collection collectionView: UICollectionView, sender senderUser: Sender) {
        let collection = db.collection("conversations").document(senderUser.senderId).collection("messages")
        
        // Reading from the "messages" Collection and ordering them by date
        collection.order(by: "date").addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print()
                print(e)
                
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
    
    // (Not used ATM) Checks if you exist as a contact for the user you want to chat with
    func myUserInContacts(sender senderUser: Sender) -> Bool {
        let docRef = db.collection("users").document(senderUser.senderEmail).collection("contacts").document(currentUser.email)
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
    func sendMessage(collection collectionView: UICollectionView, sender senderUser: Sender, messageBody body: String) {
        
        let collection = db.collection("conversations").document(senderUser.senderId).collection("messages")
        collection.document().setData([
            "body": body,
            "sender": currentUser.email,
            "date": Date().timeIntervalSince1970 ]) { (error) in
                
            if let e = error {
                print()
                print(e)
                
            } else {
                print()
                print("Message Successfully Sent!")
                
                if let aes = try? AES(key: "1234567890123456", iv: "abdefdsrfjdirogf"), let aesE = try? aes.encrypt(Array(body.utf8)) {
                    
                    print()
                    print("AES encrypted: \(aesE)")
                    let aesD = try? aes.decrypt(aesE)
                    let decrypted = String(bytes: aesD!, encoding: .utf8)
                    print("AES decrypted: \(String(describing: decrypted))")
                }
            }
        }
    }
}
