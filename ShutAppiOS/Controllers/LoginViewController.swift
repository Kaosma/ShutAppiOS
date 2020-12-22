//
//  LoginViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginErrorLabel: UILabel!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var contacts : [Contact] = []
    var currenUser = CurrentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        ImageService.setImage(imageView: logoImage, imageURL: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUserInfo()
    }
    
    // Authenticating and login the user and display user if input is wrong
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let inputEmail = emailTextField.text, let inputPassword = passwordTextField.text {
            Auth.auth().signIn(withEmail: inputEmail, password: inputPassword) { [weak self] authResult, error in
                if let e = error {
                    self?.loginErrorLabel.text = e.localizedDescription
                } else {
                    self!.performSegue(withIdentifier: "GoToContactsScreen", sender: self)
                }
            }
        }
    }
    
    func checkUserInfo(){
        if ((Auth.auth().currentUser?.uid) != nil) {
            self.performSegue(withIdentifier: "GoToContactsScreen", sender: self)
        }
        if ((Auth.auth().currentUser?.uid) == nil) {
            currenUser.signOutCurrentUser()
        }
    }
    
}
