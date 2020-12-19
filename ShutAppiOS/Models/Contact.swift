//
//  Contact.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation

// Contact object
struct Contact {
    let username : String
    let email : String
    let id : String
    let conversationId : String
    var latestMessageDate : Double = 0
}
