//
//  UserFunctions.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-26.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import Firebase

class UserFunctions {
    
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    
    // Change the current user's username
    func changeUsername(newName name: String, usernameTextField textField: UITextField?) {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.displayName = name
            changeRequest.commitChanges { (error) in
                if let e = error {
                    print()
                    print(e)
                    return
                }else{
                    print()
                    print("Username Successfully Changed!")
                }
            }
        }
    }
    
    // Changing the user's profile image reference
    func changeProfileImage(newURL url: URL) {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.photoURL = url
            changeRequest.commitChanges { (error) in
                if let e = error {
                    print()
                    print(e)
                    return
                } else {
                    print()
                    print("Profile Picture Successfully Changed!")
                }
            }
        }
    }
    // Set my user as contact to the added contact
    func setMyUserAsContact(contactUserEmail contactEmail: String, conversationId conversation: String) {
        self.db.collection("users").document(contactEmail).collection("contacts").document(currentUser.email).setData(["id" : currentUser.id as String,
                      "name" : currentUser.username as String,
                      "conversation" : conversation as String])
    }
    
    // Send a reset password action to the current logged in user
    func resetPassWord() {
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: currentUser.email) { (error) in
            if let e = error {
                print()
                print(e)
                return
            }else{
                print()
                print("Password Successfully Sent!")
            }
            self.signOutCurrentUser()
        }
    }
    
    // Sign out the current logged in user
    func signOutCurrentUser() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print()
            print(error)
        }
    }
    
    // Delete the current logged in user
    func deleteUser() {
        if let user = Auth.auth().currentUser {
            let docRef = self.db.collection("users").document(user.email!)
            docRef.delete { error in
                if let e = error {
                    print()
                    print(e)
                } else {
                    user.delete { error in
                        if let e = error {
                            print()
                            print(e)
                        }
                        else {
                            print()
                            print("User Successfully Deleted!")
                            self.signOutCurrentUser()
                        }
                    }
                }
            }
        }
    }
}

// Extra functions (Not used yet)
extension UserFunctions {
    func UpdateUI(){
        
        test { (data) in
          //data is value return by test function
            DispatchQueue.main.async {
                // Update UI
                //do task what you want.
                // run on the main queue, after the previous code in outer block
            }
        }
    }

    func test (returnCompletion: @escaping (AnyObject) -> () ){

        let url = URL(string: "https://google.com/")
        DispatchQueue.global(qos: .background).async {
            // Background work
            let data = try? Data(contentsOf: url!)
            // convert the data in you formate. here i am using anyobject.
            returnCompletion(data as AnyObject)
        }
    }
}

