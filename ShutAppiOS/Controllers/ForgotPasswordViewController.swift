//
//  ForgotPasswordViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailForgotPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // Handling a forgot password using an alert to communicate with the user
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
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
}
