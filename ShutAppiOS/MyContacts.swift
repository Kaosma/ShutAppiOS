//
//  MyContacts.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import Firebase

// MARK: Class Declaration
class MyContacts {
    
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    var filteredContacts = [Contact]()
    var contacts = [Contact]()
    var latestMessages = [String:String]()
    var filter: Bool = false
    
    // MARK: Functions
    // Filtering the contacts when using the SearchBar
    func filterContacts() {
        filteredContacts = []
        filteredContacts = bubble(arr: &contacts)
    }
    
    // Add user as a new contact
    func addContact(document doc: DocumentSnapshot, contactEmail email: String, contactUsername username: String, updatingTableView tableView: UITableView) {
        
        filter = false
        
        if let dataDescription = doc.data() {
            if let contactId = dataDescription["id"] as? String {
                
                let conversationsCollection = db.collection("conversations").addDocument(data: [
                    "firstSender" : currentUser.email,
                    "secondSender" : email])
                
                let conversationId = conversationsCollection.documentID
                
                // Add contact to the user's contacts in the database
                let contactsCollection = self.db.collection("users").document(currentUser.email).collection("contacts")
                contactsCollection.document(email).setData(["id" : contactId as String,
                                                            "name" : username as String,
                                                            "conversation" : conversationId as String])
                let newContact = Contact(username: username, email: email, id: contactId, conversationId: conversationId, latestMessageDate: 0.0)
                filteredContacts.append(newContact)
                getLatestMessages(updatingTableView: tableView)
                // Add my user as contact to the added contact
                UserFunctions().setMyUserAsContact(contactEmail: email, conversationId: conversationId)
            }
        }
    }
    
    // Change name of contact
    func changeContactName(contactEmail email: String, newName name: String, updatingTableView tableView: UITableView) {
        
        let updateRef = self.db.collection("users").document(self.currentUser.email).collection("contacts").document(email)
        
        updateRef.getDocument { (document, err) in
            if let err = err {
                print(err.localizedDescription)
                
            } else {
                document?.reference.updateData([ "name": name ])
                tableView.reloadData()
                let dismissAlert = UIAlertController(title: "Contact name changed", message: "", preferredStyle: .alert)
                
                dismissAlert.addAction(UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil))
            }
        }
    }
    
    // Delete contact
    func deleteContact(indexPath index: IndexPath, updatingTableView tableView: UITableView) {
        
        let item = filteredContacts[index.row]
        filter = false
        
        db.collection("users").document(self.currentUser.email).collection("contacts").document(item.email).delete() { (error) in
            
            if let e = error {
                print()
                print(e)
                
            } else {
                print()
                print("Contact Successfully Removed!")
                self.deleteMyUserAsContact(contactItem: item, updatingTableView: tableView)
                self.deleteConversation(conversationId: item.conversationId)
                self.filteredContacts.remove(at: index.row)
                tableView.reloadData()
            }
        }
    }
    
    // Delete me as a contact for my deleted contact
    func deleteMyUserAsContact(contactItem item: Contact, updatingTableView tableView: UITableView) {
        
        db.collection("users").document(item.email).collection("contacts").document(self.currentUser.email).delete() { (error) in
            
            if let e = error {
                print()
                print(e)
                
            } else {
                print()
                print("My User Successfully Removed As Contact!")
            }
        }
    }
    
    // Delete conversation
    func deleteConversation(conversationId conversation: String) {
        
        db.collection("conversations").document(conversation).delete() { (error) in
            if let e = error {
                print()
                print(e)
                
            } else {
                print()
                print("Conversation Successfully Removed!")
            }
        }
    }
    
    // Getting the latest message sent in a conversation with a user
    func getLatestMessages(updatingTableView tableView: UITableView) {
        
        for contact in filteredContacts {
            let collectionRef = db.collection("conversations").document(contact.conversationId).collection("messages")
            // Reading from the "messages" Collection and ordering them by date
            collectionRef.order(by: "date").addSnapshotListener { (documents, error) in
                
                if let e = error {
                    print()
                    print(e)
                    
                } else {
                    if let index = (documents?.documents.count) {
                        if index != 0 {
                            
                            if let document = documents?.documents[index-1] {
                                if let messageBody = document.data()["body"] as? String {
                                    self.latestMessages.updateValue(messageBody, forKey: contact.email)
                                    self.filteredContacts = self.bubble(arr: &self.filteredContacts)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    // Loading the contacts from the database
    func getContactsFromDatabase(updatingTableView tableView: UITableView) {
        
        let collectionRef = db.collection("users").document(currentUser.email).collection("contacts")
        
        collectionRef.addSnapshotListener { (querySnapshot, error) in
            self.contacts = []
            if let e = error {
                print()
                print(e)
                
            } else {
                for document in querySnapshot!.documents {
                    
                    if let contactID = document.data()["id"] as? String, let contactUsername = document.data()["name"] as? String, let contactConversation = document.data()["conversation"] as? String {
                        let contactEmail = document.documentID
                        
                        if let contactMessage = document.data()["latestMessageDate"] as? Double {
                            
                            let contact = Contact(username: contactUsername, email: contactEmail, id: contactID, conversationId: contactConversation, latestMessageDate: contactMessage)
                            self.contacts.append(contact)
                            
                        } else {
                            
                            let contactMessage = 0.0
                            let contact = Contact(username: contactUsername, email: contactEmail, id: contactID, conversationId: contactConversation, latestMessageDate: contactMessage)
                            self.contacts.append(contact)
                        }
                        
                        if self.filter {
                            self.filterContacts()
                        }
                        tableView.reloadData()
                    }
                    DispatchQueue.main.async {
                        self.getLatestMessages(updatingTableView: tableView)
                    }
                }
            }
        }
    }
    
    //Bubble sort function
    func bubble(arr: inout [Contact]) -> [Contact] {
        for i in (1..<arr.count).reversed() {
            for j in 0..<i where arr[j].latestMessageDate < arr[j + 1].latestMessageDate {
                arr.swapAt(j, j + 1)
            }
        }
        return arr
    }
}
