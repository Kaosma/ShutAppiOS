//
//  Message.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import MessageKit

// MARK: Struct Declaration
struct Message: MessageType {
    var sender : SenderType
    var messageId : String
    var sentDate : Date
    var kind : MessageKind
}
