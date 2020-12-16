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

    @IBOutlet weak var logoImage: UIImage!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var contacts : [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadLogoImage()
        //loadImageUsingCacheWithUrlString(String)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUserInfo()
    }
    
    // Authenticating and login the user
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let inputEmail = emailTextField.text, let inputPassword = passwordTextField.text {
            Auth.auth().signIn(withEmail: inputEmail, password: inputPassword) { [weak self] authResult, error in
                if let e = error {
                    print(e)
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
    }
    
        /*
//Downloading image from firebase
        func loadLogoImage() {
            let url = "gs://shutapp-cd2b6.appspot.com/logoImage/baseline_chat_black_18dp.png"
            // Create a reference to the file you want to download
            let storageRef = Storage.storage()
            
            let storage = storageRef.reference(forURL: url)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            storage.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                // Uh-oh, an error occurred!
                    print(error as Any)
              } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.logoImage.image = image
              }
            }
          }
    
    
    func loadImageUsingCacheWithUrlString(_ urlString: String)  {
        let imageCache = NSCache<NSString, UIImage>()

        self.logoImage = nil

    //        checks cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.logoImage = cachedImage
            return
        }

        //download
    
        let storageRef = Storage.storage()
        let storage = storageRef.reference(forURL: "gs://shutapp-cd2b6.appspot.com/logoImage/baseline_chat_black_18dp.png")
        let url = URL(string: "gs://shutapp-cd2b6.appspot.com/logoImage/baseline_chat_black_18dp.png")
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in

            //error handling
            if let error = error {
                print(error)
                return
            }

            DispatchQueue.main.async(execute: {

                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.logoImage = downloadedImage
                }
            })
        }).resume()
    }*/
}
