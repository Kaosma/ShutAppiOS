//
//  SignUpViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

//
//  SignUpViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import UIKit
import Firebase

// MARK: Class Declaration
class SignUpViewController: UIViewController {
    
    // MARK: Constants and Variables
    let db = Firestore.firestore()
    var imagePicker: UIImagePickerController!
    var contacts = [Contact]()
    var confirmButtonSelected = false
    
    // MARK: IBOutlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tapTochangeeProfileImage: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var confirmTermsButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: IBActions
    // Shows the terms of ShutApp
    @IBAction func viewTermsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ViewTermsSegue", sender: self)
    }
    
    // Allows checking a box to accept the terms of ShutApp
    @IBAction func confirmTermsButtonAction(_ sender: UIButton) {
        
        if confirmButtonSelected {
            confirmTermsButton.setImage( UIImage(named: "check_box_outline_blank-24px"), for: .normal)
            confirmButtonSelected = false
        } else {
            confirmTermsButton.setImage( UIImage(named: "check_box-24px"), for: .normal)
            confirmButtonSelected = true
        }
    }
    
    // Creates a user with email, password, username and profilePictureURL
    @IBAction func signUpButton(_ sender: UIButton) {
        
        if let newEmail = emailTextField.text, let newPassword = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text, let userName = usernameTextField.text,
           let image = profileImageView.image {
            
            if newPassword == confirmPassword && confirmButtonSelected {
                
                Auth.auth().createUser(withEmail: newEmail, password: newPassword, completion: { authResult, error in
                    if let e = error {
                        print(e)
                        self.errorLabel.text = e.localizedDescription

                        return
                    }
                    
                    // Upload the profile picture to firebase Storage and save important user information
                    guard let authResult = authResult else { return }
                    let user = authResult.user
                    let changeRequest = user.createProfileChangeRequest()
                    let id = user.uid
                    guard let email = user.email else { return }
                    changeRequest.displayName = userName
                    changeRequest.photoURL =
                        NSURL(string: "profileImages/\(id)ProfileImage.jpg") as URL?
                    
                    changeRequest.commitChanges { (error) in
                        if let e = error {
                            print()
                            print(e)
                        }
                        ImageService.uploadProfileImageToStorage(selectedImage: image, userId: id)
                    }
                    
                    // Save the user to Firebase
                    let values = ["id": user.uid, "terms": self.confirmButtonSelected as Any ] as [String : Any]
                    self.db.collection("users").document(email).setData(values as Any as! [String : Any])
                    
                    // Alerting the user that they are now a member of ShutApp
                    let alert = UIAlertController(title: "Done", message: "You are now a member of ShutApp!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "loginAfterSignUpSegue", sender: self) }))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    // Open image picker
    @objc func openImagePicker(sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Main Program
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        ImageService.cacheImage(imageView: logoImage, urlString: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08") { (name, image, error)  in
        }
        
        /*ImageService.setImage(imageView: logoImage, imageURL: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08")*/
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        tapTochangeeProfileImage.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    }
}

// MARK: Class Extensions
// Handling the UIImagePicker
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
