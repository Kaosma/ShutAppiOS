//
//  UserFunctions.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-26.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import Firebase

// MARK: Class Declaration
class UserFunctions {
    
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    
    // MARK: Functions
    // Change the current user's username
    func changeUsername(newName name: String, usernameTextField textField: UITextField?) {
        
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            
            changeRequest.displayName = name
            changeRequest.commitChanges { (error) in
                if let e = error {
                    print()
                    print(e)
                    return
                    
                } else{
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
    func setMyUserAsContact(contactEmail email: String, conversationId conversation: String) {
        self.db.collection("users").document(email).collection("contacts").document(currentUser.email)
            .setData(["id" : currentUser.id as String,
                      "name" : currentUser.username as String,
                      "conversation" : conversation as String])
    }
    
    // Send a reset password action to the current logged in user
    func resetPassWord() {
        Auth.auth().sendPasswordReset(withEmail: currentUser.email) { (error) in
            
            if let e = error {
                print()
                print(e)
                return
                
            } else{
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
            if let email = user.email {
                
                let storageRef = Storage.storage().reference()
                storageRef.child("profileImages/\(user.uid)ProfileImage.jpg").delete { error in
                    
                    if let e = error {
                        print()
                        print(e)
                    } else {
                        print()
                        print("Profile Image Successfully Deleted!")
                    }
                }
                self.db.collection("users").document(email).delete { error in
                    
                    if let e = error {
                        print()
                        print(e)
                        
                    } else {
                        user.delete { error in
                            
                            if let e = error {
                                print()
                                print(e)
                                
                            } else {
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
}
