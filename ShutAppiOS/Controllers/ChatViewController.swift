//
//  ChatViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import MessageInputBar

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageInputBarDelegate, InputBarAccessoryViewDelegate {
    
    let messageController = MyMessages()
    let currentUser = Sender(senderId: CurrentUser().email, displayName: CurrentUser().username, senderEmail: CurrentUser().email)
    var contactUser = Sender(senderId: "", displayName: "", senderEmail: "")

    func currentSender () -> SenderType  {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType{
            return messageController.messages[indexPath.section]
    }
    
    // Return number of cells in MessagesCollectionView -> Size of the chat Array
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageController.messages.count
    }
    
    //Text color on messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            return .white
    }
    
    // Loading all the messages from and to a contact
    func loadMessages(sender: Sender) {
        messageController.getMessagesFromDatabase(collectionView: messagesCollectionView, senderUser: sender)
    }
    
    // Sending a message to a contact
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if let inputText = messageInputBar.inputTextView.text {
            messageController.sendMessage(collectionView: messagesCollectionView, senderUser: contactUser, body: inputText)
            messageInputBar.inputTextView.text = ""
        }
    }
    
    //Send Button style
    func sendButtonItemBar() {
        messageInputBar.sendButton.configure {
            $0.setSize(CGSize(width: 370, height: 36), animated: false)
            $0.isEnabled = false
            $0.title = ""
            $0.image = UIImage(named: "baseline_send_black_18dp")
            $0.tintColor = UIColor.blue
            $0.setTitleColor(UIColor.purple, for: .normal)
            $0.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        }
    }
    
    //Send bar style
    func sendItemBar() {
        self.messageInputBar.inputTextView.placeholder = " Aa"
        self.messageInputBar.inputTextView.textColor = UIColor.white
        self.messageInputBar.inputTextView.beginFloatingCursor(at: CGPoint(x:20,y:20))
        self.messageInputBar.inputTextView.tintColor = UIColor.systemPurple
        self.messageInputBar.inputTextView.placeholderTextColor = UIColor(white: 1, alpha: 0.5)
        self.messageInputBar.inputTextView.backgroundColor = UIColor.lightGray
        self.messageInputBar.inputTextView.layer.cornerRadius = 20
        self.messageInputBar.inputTextView.layer.borderWidth = 2.0
        self.messageInputBar.inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.messageInputBar.backgroundView.layer.backgroundColor = UIColor.white.cgColor
        self.messageInputBar.layer.masksToBounds = true
        self.messageInputBar.backgroundView.layer.borderColor = UIColor.white.cgColor
        self.messagesCollectionView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        let bgImage = UIImageView();
            bgImage.image = UIImage(named: "megaphone");
        bgImage.contentMode = .scaleToFill
        self.messagesCollectionView.backgroundView = bgImage
    }
    
    //Background color för message bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            return isFromCurrentSender(message: message) ? UIColor.purple : UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        loadMessages(sender: contactUser)
        sendItemBar()
  
        sendButtonItemBar()
    }
    
}
