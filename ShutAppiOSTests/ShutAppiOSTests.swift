//
//  ShutAppiOSTests.swift
//  ShutAppiOSTests
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import XCTest
@testable import ShutAppiOS

class ShutAppiOSTest: XCTestCase {

    var sut: LoginViewController!
    
    override func setUpWithError() throws {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        sut = storyBoard.instantiateViewController(identifier: "LoginViewController") as?
        LoginViewController
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testEmailTextFeild_WhenUserLoggedIn() throws {
        let emailTextField = try XCTUnwrap(sut.emailTextField, "Email adress UITextField is not connected")
        
        XCTAssertEqual(emailTextField.textContentType, UITextContentType.emailAddress, "Email adress UITextField does not have an Email Adress Content Type To set")
    }
    
    func testPassWordTextfield_WhenUserLoggedIn() throws {

        let passwordTextField = try XCTUnwrap(sut.passwordTextField, "Password UITextField is not connected")

        

        XCTAssertEqual(passwordTextField.textContentType, UITextContentType.password, "Password UITextField does not have a Password Content Type To set")

    }

}
