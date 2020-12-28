//
//  SignUpViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tapTochangeeProfileImage: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    var contacts : [Contact] = []
    @IBOutlet weak var confirmTermsButton: UIButton!
    
    var confirmButtonSelected = false
    var profileImageService: ImageService!
    
    var imagePicker: UIImagePickerController!
    
    // Database initialization
    let db = Firestore.firestore()
   
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func viewTermsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ViewTermsSegue", sender: self)

    }
    
    //Confirm ShutApps Terms by press a button
    @IBAction func confirmTermsButtonAction(_ sender: UIButton) {
        
        if confirmButtonSelected
        {
            confirmTermsButton.setImage( UIImage(named: "check_box_outline_blank-24px"), for: .normal)
            confirmButtonSelected = false
           
        }else {
            confirmTermsButton.setImage( UIImage(named: "check_box-24px"), for: .normal)
            confirmButtonSelected = true
        }
    }
    
    // Signing up a user with e-mail and password
    @IBAction func signUpButton(_ sender: UIButton) {
      
        if let newEmail = emailTextField.text, let newPassword = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text, let userName = usernameTextField.text,
           let image = profileImageView.image
          {
            if newPassword == confirmPassword && confirmButtonSelected {
                Auth.auth().createUser(withEmail: newEmail, password: newPassword, completion: { authResult, error in
                    if let e = error {
                        print(e)
                        self.errorLabel.text = e.localizedDescription

                        return
                    }
                    
                    //Uppload the profile to firebase Storage
           
                        guard let authResult = authResult else { return }
                        let user = authResult.user
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = userName
                        changeRequest.photoURL =
                            NSURL(string: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08") as URL?
    
                       // self.profileImageService.saveImage(profileImageURL: url!) { success in
                        //}
                        
                        changeRequest.commitChanges { (error) in
                            if let e = error {
                                print()
                                print(e)

                            }
                        }
                        
                        
                        let values = ["id": user.uid, "terms": self.confirmButtonSelected as Any ] as [String : Any]
                        self.db.collection("users").document(user.email!).setData(values as Any as! [String : Any]) // <------------
                   
                    //Save the data to firestore
                    
           
                    
                    let alert = UIAlertController(title: "Done", message: "You are now a member of ShutApp!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "loginAfterSignUpSegue", sender: self) }))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    //open Image picker
    @objc func openImagePicker(sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        ImageService.setImage(imageView: logoImage, imageURL: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08")
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        tapTochangeeProfileImage.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info [UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
