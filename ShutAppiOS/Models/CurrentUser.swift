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
        if let fetchedId = Auth.auth().currentUser?.uid {
            userId = fetchedId
        }
        return userId
    }
    
    // Initiate the username
    var username : String {
        var userName = ""
        if let fetchedName = Auth.auth().currentUser?.displayName {
            userName = fetchedName
        }
        return userName
    }
    
    // Initiate the photo
    var profileImage : String = ""
    
    func getProfileImage(imageView image: UIImageView) {
        let docRef = db.collection("users").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let dataDescription = document.data() {
                    if let url = dataDescription["imageUrl"] as? String {
                        self.profileImage = url
                        
                        DispatchQueue.main.async {
                            ImageService.setImage(imageView: image, imageURL: url)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    func changeUsername(newName name: String, usernameTextField textField: UITextField?) {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.displayName = name
            changeRequest.commitChanges { (error) in
                // User Not Updated Alert
                // User Not Updated Alert
            }
        }
    }
    // Add contact to the user's contacts in the database
    func setAsContact(contactUserEmail contactEmail: String, conversationId conversation: String) {
        let docRef = db.collection("users").document(Auth.auth().currentUser!.email!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let dataDescription = document.data() {
                    if let userName = dataDescription["name"] as? String {
                        DispatchQueue.main.async {
                            let contactsCollection = self.db.collection("users").document(contactEmail).collection("contacts")
                            contactsCollection.document(self.email).setData(["id" : self.id as String,
                                                                             "name" : self.username as String,
                                                                        "conversation" : conversation as String])
                        }
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
        
    //Upload image to firebase Storage 
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        let storageRef = Storage.storage().reference().child(id)

        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {

                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                    
                }
                } else {
                    // failed
                    completion(nil)
                }
            }
    }
    
    
    
    
    
    
    
    
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
