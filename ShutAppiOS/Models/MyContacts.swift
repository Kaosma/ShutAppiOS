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
    var latestMessages = [String:String]()
    var filter: Bool = false
    
    
    
    // Filtering the contacts when using the SearchBar
    func filterContacts(tableView: UITableView) {
        print("FILTER CONTACTS")
        filteredContacts = []
        for contact in contacts {
            filteredContacts.append(contact)
        }
    }
    
    // Add user as a new contact
    func addContact(doc: DocumentSnapshot, email: String, tableView: UITableView) {
        filter = false
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
            let newContact = Contact(username: contactUsername, email: email, id: contactId, conversationId: conversationId)
            filteredContacts.append(newContact)

            DispatchQueue.main.async {
                self.currentUser.setAsContact(contactUserEmail: email, conversation: conversationId)
            }
        }
    }
    
    // Delete contact
    func deleteContact(index: IndexPath, tableView: UITableView) {
        let item = filteredContacts[index.row]
        filter = false
        db.collection("users").document(self.currentUser.email).collection("contacts").document(item.email).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Contact removed!")
                self.deleteMyUserAsContact(index: index, tableView: tableView)
                self.deleteConversation(conversation: item.conversationId)
            }
        }
    }
    
    // Delete me as a contact for my deleted contact
    func deleteMyUserAsContact(index: IndexPath, tableView: UITableView) {
        let item = filteredContacts[index.row]
        db.collection("users").document(item.email).collection("contacts").document(self.currentUser.email).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Removed me as contact!")
            }
        }
    }
    
    // Delete conversation
    func deleteConversation(conversation: String) {
        db.collection("conversations").document(conversation).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Removed conversation!")
            }
        }
    }
    
    // Getting the latest message sent in a conversation with a user
    func getLatestMessages(tableView: UITableView) {
        for i in filteredContacts {
            let collection = db.collection("conversations").document(i.conversationId).collection("messages")
            // Reading from the "messages" Collection and ordering them by date
            collection.order(by: "date").addSnapshotListener { (documents, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let index = (documents?.documents.count) {
                        if index != 0 {
                            if let document = documents?.documents[index-1] {
                                if let messageBody = document.data()["body"] as? String{
                                    self.latestMessages.updateValue(messageBody, forKey: i.email)
                                }
                                DispatchQueue.main.async {
                                    //print(self.bubble(arr: &self.contacts))
                                    tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // Loading the contacts from the database
    func getContactsFromDatabase(tableView: UITableView) {
        let collection = db.collection("users").document(currentUser.email).collection("contacts")
        
        collection.addSnapshotListener { (querySnapshot, err) in
            self.contacts = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let contactID = document.data()["id"] as? String, let contactUsername = document.data()["name"] as? String, let contactConversation = document.data()["conversation"] as? String {
                        let contactEmail = document.documentID
                        let contact = Contact(username: contactUsername, email: contactEmail, id: contactID, conversationId: contactConversation)
                        self.contacts.append(contact)
                        
                        if self.filter {
                            self.filterContacts(tableView: tableView)
                        }
                        print("Contacts \(self.contacts.count)")
                        print("Filtered Contacts \(self.filteredContacts.count)")
                        print("--------------")
                        print()
                        DispatchQueue.main.async {
                            self.getLatestMessages(tableView: tableView)
                        }
                    }
                }
            }
        }
    }
    
    //Bubble sort function
    func bubble(arr: inout [Contact]) {
            for i in (1..<arr.count).reversed() {
                for j in 0..<i where arr[j].latestMessageDate < arr[j + 1].latestMessageDate {
                    arr.swapAt(j, j + 1)
                    for k in arr {
                        print(k.username," + ", k.latestMessageDate)
                    }
                }
            }
        }
    }
