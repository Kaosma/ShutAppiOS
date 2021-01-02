//
//  ContactsViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import UIKit
import Firebase
import SwipeCellKit

// MARK: Class Declaration
class ContactsViewController: UIViewController {
    
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    var contactController = MyContacts()
    let chatSegueId = "segueToChatViewController"
    
    // MARK: IBOutlets
    @IBOutlet weak var contactTableView: UITableView!
    
    // MARK: IBActions
    // Adding another user to contacts
    @IBAction func addContactButtonPressed(_ sender: UIBarButtonItem) {
        var emailTextField = UITextField()
        var nameTextField = UITextField()
        let alert = UIAlertController(title: "Add New Contact", message: "Enter the contact's e-mail and the contact's username", preferredStyle: .alert)
        
        // Creating an alert that allows the user to pass in a new contact's e-mail
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if !emailTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty && !nameTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty{
                let contactEmail = emailTextField.text!
                let contactUsername = nameTextField.text!
                
                if contactEmail != self.currentUser.email {
                    let docRef = self.db.collection("users").document(contactEmail)
                    docRef.getDocument { (document, error) in
                        
                        // If the new contact's email exists -> Add the contact
                        if let document = document, document.exists {
                            self.contactController.addContact(document: document, contactEmail: contactEmail, contactUsername: contactUsername, table: self.contactTableView)
                            let dismissAlert = UIAlertController(title: "Contact Added!", message: "", preferredStyle: .alert)
                            dismissAlert.addAction(UIAlertAction(title: "OK",
                                                                 style: .cancel, handler: nil))
                            self.present(dismissAlert, animated: true, completion: nil)
                            
                        // If the new contact's email doesn't exist -> Let the user know with an alert
                        } else {
                            let dismissAlert = UIAlertController(title: "User not found", message: "", preferredStyle: .alert)
                            
                            dismissAlert.addAction(UIAlertAction(title: "OK",
                                                                 style: .cancel, handler: nil))

                            self.present(dismissAlert, animated: true, completion: nil)
                        }
                    }
                } else {
                    let dismissAlert = UIAlertController(title: "User not found", message: "", preferredStyle: .alert)
                    
                    dismissAlert.addAction(UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil))

                    self.present(dismissAlert, animated: true, completion: nil)
                }
            } else {}
        }
        
        // Styling the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "john@doe.com"
            emailTextField = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "John Doe"
            nameTextField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Segue to settings
    @IBAction func goToSettingsButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoToSettings", sender: self)
    }
    
    // MARK: Other Functions
    // Load the user's contacts into the TableView
    func loadContacts(willFilter: Bool){
        contactController.filter = true
        contactController.getContactsFromDatabase(table: contactTableView)
    }
    

    
    // MARK: Main Program
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts(willFilter:true)
        
    }
}

// MARK: Class Extensions
// Handling a SwipeTableViewCell
extension ContactsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.contactController.deleteContact(indexPath: indexPath, table: self.contactTableView)
        }
        let changeContactNameAction = SwipeAction(style: .default , title: "Change Name") { (action, indexPath) in
            
            // Creating an alert that allows the user to pass in a new contact's e-mail
            var textField = UITextField()
            let email = self.contactController.filteredContacts[indexPath.row].email
            let alert = UIAlertController(title: "Change Contact Name", message: "Enter new name or nickname.", preferredStyle: .alert)
            
            // Creating an alert that allows the user to pass in a new contact's e-mail
            let action = UIAlertAction(title: "Done", style: .default) { (action) in
                if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    if let contactName = textField.text {
                        let updateReference = self.db.collection("users").document(self.currentUser.email).collection("contacts").document(email)
                        updateReference.getDocument { (document, err) in
                            if let err = err {
                                print(err.localizedDescription)
                            }
                            else {
                                document?.reference.updateData([ "name": contactName ])
                                let dismissAlert = UIAlertController(title: "Contact name changed", message: "", preferredStyle: .alert)
                                
                                dismissAlert.addAction(UIAlertAction(title: "OK",
                                                                     style: .cancel, handler: nil))
                            }
                        }
                    }
                    
                } else {}
            }
            // Styling the alert
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Name/Nickname"
                textField = alertTextField
            }
            
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        return [deleteAction, changeContactNameAction]
    }
}

// Handling the ContactsTableView
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Return number of cells in tableview -> Size of the contacts Array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.contactController.filteredContacts.count
    }
    
    // Creating each TableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let contact = self.contactController.filteredContacts[indexPath.row]
        let name = cell.contentView.viewWithTag(1) as! UILabel
        let content = cell.contentView.viewWithTag(2) as! UILabel
        name.text = contact.username
        if let latestMessage = contactController.latestMessages[contact.email] {
            content.text = latestMessage
        } else {
            content.text = "No messages yet"
        }
        return cell
    }
    
    // Handling a selected TableViewCell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = self.contactController.filteredContacts[indexPath.row]
        let vc = ChatViewController()
        vc.contactUser = Sender(senderId: contact.conversationId, displayName: contact.username, senderEmail: contact.email)
        vc.title = contact.username
        navigationController?.pushViewController(vc, animated: true)
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

// Handling the UISearchBar
extension ContactsViewController: UISearchBarDelegate {

    // Searchbar will always control when it's being interracted with
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        contactController.filteredContacts = []
        
        // If the searchbarText contains an empty string the filtered data will only be the contacts array
        if searchText == "" {
            contactController.filterContacts()
            
        // Else check if the array has elements that contains the searchbarText and display them as a filtered list
        } else {
            for data in contactController.contacts {
                if data.username.lowercased().contains(searchText.lowercased()) {
                    contactController.filteredContacts.append(data)
                }
            }
        }
        contactTableView.reloadData()
    }
}
