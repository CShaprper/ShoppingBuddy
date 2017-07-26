//
//  StoresControllerTests.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class StoresControllerTests: XCTestCase {
    var storyboard:UIStoryboard!
    var sut:StoresController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        sut = storyboard.instantiateViewController(withIdentifier: "StoresController") as! StoresController
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(sut.view)
        sut.viewDidLoad()
        sut.didReceiveMemoryWarning()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
}
