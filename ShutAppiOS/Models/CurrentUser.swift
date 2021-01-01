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
struct CurrentUser {

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
    
    var profileImage : String {
        var url = ""
        if let fetchedImage = Auth.auth().currentUser?.photoURL {
            url = fetchedImage.absoluteString
        }
        return url
    }
}
