//
//  MyContacts.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import Firebase

// Class containing the logged in user's contacts
class MyContacts {
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    
    var filteredContacts : [Contact] = []
    var contacts : [Contact] = []
    
    // Filtering the contacts when using the SearchBar
    func filterContacts(tableView: UITableView) {
        filteredContacts = []
        for contact in contacts {
            filteredContacts.append(contact)
        }
    }
    
    func addContact(doc: DocumentSnapshot, email: String, tableView: UITableView) {
        let dataDescription = doc.data()
        if let contactId = dataDescription!["id"] as? String, let contactUsername = dataDescription!["name"] as? String {
            let conversationsCollection = db.collection("conversations").addDocument(data: [
                "firstSender" : currentUser.email,
                "secondSender" : email])
            
            let conversationId = conversationsCollection.documentID
            
            // Add contact to the user's contacts in the database
            let contactsCollection = self.db.collection("users").document(currentUser.email).collection("contacts")
            contactsCollection.document(email).setData(["id" : contactId as String,
                                                        "name" : contactUsername as String,
                                                        "conversation" : conversationId as String])
            DispatchQueue.main.async {
                self.getContactsFromDatabase(tableView: tableView, filter: true)
                self.addMyUserAsContact(contactUserEmail: email, conversation: conversationId)
            }
        }
    }
    
    func addMyUserAsContact(contactUserEmail: String, conversation: String) {
        currentUser.setName(contactUserEmail: contactUserEmail, conversation: conversation)
    }
    
    // Loading the contacts from the database
    func getContactsFromDatabase(tableView: UITableView, filter: Bool) {
        contacts = []
        let collection = db.collection("users").document(currentUser.email).collection("contacts")
        collection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let contactID = document.data()["id"] as? String, let contactUsername = document.data()["name"] as? String, let contactConversation = document.data()["conversation"] as? String {
                        let contactEmail = document.documentID
                        let contact = Contact(username: contactUsername, email: contactEmail, id: contactID, conversationId: contactConversation)
                        self.contacts.append(contact)
                        
                        if filter {
                            self.filterContacts(tableView: tableView)
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
