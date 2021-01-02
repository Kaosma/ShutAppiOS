//
//  TermsViewController.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import UIKit

// MARK: Class Declaration
class TermsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Terms Pop-up
    @IBAction func closeTermsPopUp(_ sender: UIButton) {
        dismiss (animated: true, completion: nil)
    }
}
