//
//  ShutAppiOSUITests.swift
//  ShutAppiOSUITests
//
//  Created by Erik Ugarte on 2020-12-16.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import XCTest

class when_the_user_types_email_and_press_send_button: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func teestValidLoginSuccess(){
        
       
        let app = XCUIApplication()
         
          let typeSomthingTextField = app.textFields[" Email"]
          typeSomthingTextField.tap()
          
          let textToType = "something diffrent"
          for c in textToType{
              typeSomthingTextField.typeText("\(c)")
          }
          
          let textFieldText = typeSomthingTextField.value as! String
          XCTAssertEqual(textFieldText, textToType)

          app.buttons["Log in"].tap()
          app.staticTexts[textToType].tap()
          
          let textFieldTextAfterTapButton = typeSomthingTextField.value as! String?
          XCTAssertEqual(textFieldTextAfterTapButton, " fffffEmail")
          
    }
    

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
            
            
        }
    }
}

