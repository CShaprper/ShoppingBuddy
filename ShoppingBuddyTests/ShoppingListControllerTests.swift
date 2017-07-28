//
//  ShoppingListController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 28.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import XCTest
@testable import ShoppingBuddy

class ShoppingListControllerTests: XCTestCase {
    var storyboard:UIStoryboard!
    var sut:ShoppingListController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "ShoppingListController") as! ShoppingListController
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(sut.view)
        sut.viewDidLoad()
        sut.didReceiveMemoryWarning()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_ListDetailView_Exists(){
        XCTAssertNotNil(sut!.ListDetailView, "ListDetailView should exist")
    }
    func test_ListDetailBackgroundImage_Exists(){
        XCTAssertNotNil(sut!.ListDetailBackgroundImage, "ListDetailBackgroundImage should exist")
    }
    func test_ListDetailTableView_Exists(){
        XCTAssertNotNil(sut!.ListDetailTableView, "ListDetailTableView should exist")
    }
    func test_ListDetailTableViewDelegate_isSet() {
        XCTAssertNotNil(sut!.ListDetailTableView.delegate, "ListDetailTableView.delegate not set")
    }
    func test_ListDetailTableViewDatasource_isSet() {
        XCTAssertNotNil(sut!.ListDetailTableView.dataSource, "ListDetailTableView.dataSource not set")
    }
    func test_ListDetailTableViewCell_hasCorrectResuseIdentifier(){
        let cell = sut.ListDetailTableView.dequeueReusableCell(withIdentifier: String.ShoppingListItemTableViewCell_Identifier) as! ShoppingListItemTableViewCell
        XCTAssertNotNil(cell, "ShoppingListItemTableViewCell_Identifier should not be nil")
        XCTAssertTrue(cell.reuseIdentifier == String.ShoppingListItemTableViewCell_Identifier, "TabelViewCell reuseIdentifier is \(String(describing: cell.reuseIdentifier)) and should be \(String.ShoppingListItemTableViewCell_Identifier)")
    }
}
