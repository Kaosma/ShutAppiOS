//
//  CurrentUser.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import Firebase

// CurrentUser object
class CurrentUser {

    let db = Firestore.firestore()

    var email : String {
        var userEmail = ""
        if let fetchedEmail = Auth.auth().currentUser?.email {
            userEmail = fetchedEmail
        }
        return userEmail
    }
    
    var id : String {
        var userId = ""
        let fetchedId = Auth.auth().currentUser!.uid
        userId = fetchedId
        return userId

    }
    
    // Initiate the username

    var username : String = ""
    
    func setName(contactUserEmail: String, conversation: String) {
        let docRef = db.collection("users").document(Auth.auth().currentUser!.email!)
        var name = ""
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let dataDescription = document.data() {
                    if let userName = dataDescription["name"] as? String {
                        name = userName
                    }
                    DispatchQueue.main.async {
                        // Add contact to the user's contacts in the database
                        let contactsCollection = self.db.collection("users").document(contactUserEmail).collection("contacts")
                        contactsCollection.document(self.email).setData(["id" : self.id as String,
                                                                                "name" : name as String,
                                                                    "conversation" : conversation as String])
                        print(name)
                    }
                }
            }
        }
    }
    
    //deleting Current User Auth
    func deleteUser() {

        
        //deleting current user from users Collection
        let docRef = self.db.collection("users").document(self.email)
        docRef.delete { error in
            if let error = error {
                print(error)            }
            else {
                
                let user = Auth.auth().currentUser
                user?.delete { error in
                    if let error = error {
                        print(error)          }
                    else {
                        print("User was successfully deleted")
                        self.signOutCurrentUser()
                    }
                    
                }
                
            }
            
        }
    }
    //SignOUt Current User
    func signOutCurrentUser() {
        do {
            try Auth.auth().signOut()
            } catch let err {
                print(err)
        }
    }
    
    //Reset CurrentUser Input
    func resetPassWordCurrentUser() {
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: Auth.auth().currentUser!.email!) { (error) in
            if let error = error {
                print(error)
                return
            }else{
                print("Password was sent successfully")
            }
            self.signOutCurrentUser()
        }
    }

}
