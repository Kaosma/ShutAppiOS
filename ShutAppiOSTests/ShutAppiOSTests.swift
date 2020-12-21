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
        let emailTextField = try XCTUnwrap(sut.emailTextField, "Email adress UITextFild is not connected")
        
        XCTAssertEqual(emailTextField.textContentType, UITextContentType.emailAddress, "Email adress UITextField does not have an Email Adress Content Type To set")
    }

}
