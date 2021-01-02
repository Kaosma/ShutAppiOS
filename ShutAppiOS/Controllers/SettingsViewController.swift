//
//  SettingsViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import UIKit
import Firebase

// MARK: Class Declaration
class SettingsViewController: UIViewController {

    var credential: AuthCredential?
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    let currentUser = CurrentUser()
    let imagePicker = UIImagePickerController()
    
    // MARK: IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: IBActions
    // Updating the username for the currently logged in user
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        if let text = nameTextField.text {
            UserFunctions().changeUsername(newName: text, usernameTextField: nameTextField)
        }
    }
    
    // Allow changing profile picture for the currently logged in user
    @IBAction func editPictureButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Deleting the currently logged in user using an alert
    @IBAction func pressedDeleteButton(_ sender: UIButton) {
        
        let deleteUserAlert = UIAlertController(title: "Refresh", message: "Are you really sure want delete your profile?", preferredStyle: UIAlertController.Style.alert)
        
        deleteUserAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            UserFunctions().deleteUser()
            self.performSegue(withIdentifier: "signOutBackToLogin", sender: self)
        }))
        
        deleteUserAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(deleteUserAlert, animated: true, completion: nil)
    }
    
    // Reseting the currently logged in user's password using an alert
    @IBAction func changePasswordButton(_ sender: UIButton) {
            UserFunctions().resetPassWord()
            let alert = UIAlertController(title: "Done", message: "A password reset has been sent!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "signOutBackToLogin", sender: self) }))
            self.present(alert, animated: true, completion: nil)
    }

    // Signing out the currently logged in user
    @IBAction func signOutButton(_ sender: UIButton) {
        UserFunctions().signOutCurrentUser()
        self.performSegue(withIdentifier: "signOutBackToLogin", sender: self)
    }
    
    // MARK: Main Program
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        deleteButton.layer.borderWidth = 1.5
        deleteButton.layer.borderColor = UIColor.black.cgColor
        nameTextField.text = currentUser.username
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        ImageService.getProfileImage(imageView: profileImageView)
    }
}

// MARK: Class Extensions
// Handling the UIImagePicker
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            ImageService.uploadProfileImageToStorage(selectedImage: editedImage, userId: currentUser.id)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
