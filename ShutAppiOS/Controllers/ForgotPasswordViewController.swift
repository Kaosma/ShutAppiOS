//
//  ForgotPasswordViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import UIKit
import Firebase

// MARK: Class Declaration
class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Constants and Variables
    let currentUser = CurrentUser()
    
    // MARK: IBOutlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var emailForgotPasswordTextField: UITextField!
    
    // MARK: IBActions
    // Handling a forgot password using an alert to communicate with the user
    @IBAction func forgotPasswordButton(_ sender: UIButton)  {
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: emailForgotPasswordTextField.text!) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Done", message: "A password reset has been sent!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "backToLoginPageSegue", sender: self) }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Main Program
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageService.cacheImage(imageView: logoImage, urlString: "https://firebasestorage.googleapis.com/v0/b/shutappios.appspot.com/o/LogoImage%2FShutAppLogo.jpg?alt=media&token=13216931-418f-486a-9702-2985b262ab08") { (name, image, error)  in
            print("done")
        }
        self.emailForgotPasswordTextField.delegate = self
    }
}

