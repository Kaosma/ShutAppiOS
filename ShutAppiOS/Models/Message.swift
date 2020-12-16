//
//  Message.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender : SenderType
    var messageId : String
    var sentDate : Date
    var kind : MessageKind
}
