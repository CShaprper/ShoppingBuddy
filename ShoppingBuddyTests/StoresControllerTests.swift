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
        sut = storyboard.instantiateViewController(withIdentifier: "StoresController") as! StoresController
        
        // Test and Load the View at the Same Time!
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
    
    //StoresTableView
    func test_StoresTableView_Exists(){
        XCTAssertNotNil(sut!.StoresTableView, "StoresTableView should exist")
    }
    func test_StoresTableViewDelegate_isSet() {
        XCTAssertNotNil(sut!.StoresTableView.delegate, "StoresTableView.delegate not set")
    }
    func test_StoresTableViewDatasource_isSet() {
        XCTAssertNotNil(sut!.StoresTableView.dataSource, "StoresTableView.dataSource not set")
    }
    func test_StoresTableViewCell_hasCorrectResuseIdentifier(){
        let cell = sut.StoresTableView.dequeueReusableCell(withIdentifier: String.StoreCell_Identifier) as! StoreCell
        XCTAssertNotNil(cell, "StoresCell should not be nil")
        XCTAssertTrue(cell.reuseIdentifier == String.StoreCell_Identifier, "TabelViewCell reuseIdentifier is \(String(describing: cell.reuseIdentifier)) and should be \(String.StoreCell_Identifier)")
    } 
    
    //AddStorePopUp
    func test_AddStorePopUp_Exists(){
        XCTAssertNotNil(sut!.AddStorePopUp, "AddStorePopUp should exist")
    }
    func test_txt_AddStore_Exists(){
        XCTAssertNotNil(sut!.txt_AddStore, "txt_AddStore should exist")
    }
    func test_txt_AddStore_Placeholder_isNotNil(){
        XCTAssertNotNil(sut!.txt_AddStore.placeholder, "txt_AddStore Placeholder not set")
    }
    func test_txt_AddStore_Placeholder_isSet(){
        XCTAssertTrue(sut!.txt_AddStore.placeholder != "", "txt_AddStore Missing placeholder value")
    }
    func test_txt_AddStoreTextColor_isSet(){
        XCTAssertEqual(sut!.txt_AddStore.textColor, UIColor.ColorPaletteSecondDarkest(), "txt_AddStore.textColor should be set")
    }
    func test_txt_AddStore_Placeholder_ShowsLocalizedString(){
        XCTAssertEqual(sut!.txt_AddStore.placeholder, String.txt_AddStore_Placeholder, "txt_AddStore_Placeholer not localized")
    }
    func test_txt_AddStoreDelegate_isSet() {
        XCTAssertNotNil(sut!.txt_AddStore.delegate, "txt_AddStore.delegate not set")
    }
    func test_txt_AddStore_isWired_ToAction(){
        XCTAssertTrue(ControlTagetTester.checkTargetForOutlet(outlet: sut!.txt_AddStore, actionName: "txt_AddStore_TextChanged", event: .editingChanged, controller: sut! ))
    }
}


