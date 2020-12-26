//
//  SettingsViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    var credential: AuthCredential?
    //@IBOutlet weak var EmailTextField: UITextField!
    let currentUser = CurrentUser()
    let db = Firestore.firestore()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!


    @IBAction func updateButtonPressed(_ sender: UIButton) {
        if let text = nameTextField.text {
            UserFunctions().changeUsername(newName: text, usernameTextField: nameTextField)
        }
    }
    
    @IBAction func editPictureButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    //Delete user Button
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
    
    //Reset password button
    @IBAction func changePasswordButton(_ sender: UIButton) {
            UserFunctions().resetPassWord()
            let alert = UIAlertController(title: "Done", message: "A password reset has been sent!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "signOutBackToLogin", sender: self) }))
            self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        deleteButton.layer.borderWidth = 1.5
        deleteButton.layer.borderColor = UIColor.black.cgColor
        ImageService().getProfileImage(imageView: profileImageView)
        nameTextField.text = currentUser.username
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    
    //Button for sign out user
    @IBAction func signOutButton(_ sender: UIButton) {
        UserFunctions().signOutCurrentUser()
        self.performSegue(withIdentifier: "signOutBackToLogin", sender: self)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            // saveImageToFirebase
            // cacheImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}
