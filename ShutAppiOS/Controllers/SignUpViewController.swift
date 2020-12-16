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
    
    var contacts : [Contact] = []
    @IBOutlet weak var confirmTermsButton: UIButton!
    
    var confirmButtonSelected = false
    
    // Database initialization
    let db = Firestore.firestore()
   
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
           let confirmPassword = confirmPasswordTextField.text, let userName = usernameTextField.text
          {
            if newPassword == confirmPassword && confirmButtonSelected {
                Auth.auth().createUser(withEmail: newEmail, password: newPassword, completion: { authResult, error in
                    if let e = error {
                        print(e)
                        return
                    }
                    // Adding the user to the "users" collection in the database
                    guard let authResult = authResult else { return }
                    let user = authResult.user
 
                    let values = ["id": user.uid, "name": userName, "terms": self.confirmButtonSelected as Any ] as [String : Any]
                    self.db.collection("users").document(user.email!).setData(values as Any as! [String : Any]) // <------------
                    let alert = UIAlertController(title: "Done", message: "You are now a member of ShutApp!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in self.performSegue(withIdentifier: "loginAfterSignUpSegue", sender: self) }))
                    self.present(alert, animated: true, completion: nil)
                    
            
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
