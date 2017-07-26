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
    
    func test_BackgroundView_Exists(){
        XCTAssertNotNil(sut!.BackgroundView, "BackgroundView should exist")
    }
    func test_StoresTableView_Exists(){
        XCTAssertNotNil(sut!.StoresTableView, "StoresTableView should exist")
    }
    func test_StoresTableViewDelegate_isSet() {
        XCTAssertNotNil(sut!.StoresTableView.delegate, "StoresTableView.delegate not set")
    }
    func test_StoresTableViewDatasource_isSet() {
        XCTAssertNotNil(sut!.StoresTableView.dataSource, "StoresTableView.dataSource not set")
    }
}
