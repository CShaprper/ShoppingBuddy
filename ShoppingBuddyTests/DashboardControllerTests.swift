//
//  DashboardControllerTests.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 24.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class DashboardControllerTests: XCTestCase {
    var storyboard:UIStoryboard!
    var sut:DashboardController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "DashboardController") as! DashboardController
        
        // Test and Load the View at the Same Time! 
        XCTAssertNotNil(sut.view)
        sut.viewDidLoad()
        sut.didReceiveMemoryWarning()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_MenuContainer_Exists(){
        XCTAssertNotNil(sut!.MenuContainer, "MenuContainer should exist")
    }
    func test_RoundMenu_Exists(){
        XCTAssertNotNil(sut!.RoundMenu, "RoundMenu should exist")
    }
    //Button Store
    func test_btn_Stores_Exists(){
        XCTAssertNotNil(sut!.btn_Stores, "btn_Stores should exist")
    }
    func test_btn_StoresTintColor_isSetToSecondDarkest(){
        XCTAssertEqual(sut.btn_Stores.tintColor, UIColor.ColorPaletteSecondDarkest(), "btn_Stores tintColor should be second darkest color")
    }
    func test_btn_ShoppingList_Exists(){
        XCTAssertNotNil(sut!.btn_ShoppingList, "btn_ShoppingList should exist")
    }
    func test_btn_ShoppingListTintColor_isSetToSecondDarkest(){
        XCTAssertEqual(sut.btn_ShoppingList.tintColor, UIColor.ColorPaletteSecondDarkest(), "btn_ShoppingList tintColor should be second darkest color")
    }
}
