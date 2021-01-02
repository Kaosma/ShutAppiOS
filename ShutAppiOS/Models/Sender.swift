//
//  Sender.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import MessageKit

// MARK: Struct Declaration
struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var senderEmail: String
}
