//
//  StoresController.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 25.07.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit

class StoresController: UIViewController, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet var BackgroundView: DesignableUIView!
    @IBOutlet var StoresTableView: UITableView!
    @IBOutlet var AddStoreButton: UIBarButtonItem!
    //Add Store PopUp
    @IBOutlet var AddStorePopUp: UIView!
    @IBOutlet var txt_AddStore: UITextField!
    @IBOutlet var btn_SaveStore: UIButton!
    
    
    
    //MARK: - Member
    var blurrView:UIVisualEffectView!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //MARK: - Textfield Delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func txt_AddStore_TextChanged(sender: UITextField) -> Void {
        
    }
    
    
    //MARK: - Wired actions
    func BlurrViewTapped(sender: UITapGestureRecognizer) -> Void {
        HideAddStorePopUp()
    }
    @IBAction func AddStoreButton_Pressed(_ sender: Any) {
        ShowAddStorePopUp()
    }
    
    //MARK: - Helper Functions
    func ShowAddStorePopUp() -> Void {
        if blurrView == nil{
            blurrView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurrView.bounds = view.bounds
            blurrView.center = view.center
            view.addSubview(blurrView)
            //BlurrView Target
            let blurrViewTap = UITapGestureRecognizer(target: self, action: #selector(BlurrViewTapped))
            blurrView.addGestureRecognizer(blurrViewTap)
            view.addSubview(AddStorePopUp)
            AddStorePopUp.center = view.center
            AddStorePopUp.HangingEffectBounce(duration: 0.5, delay: 0, spring: 0.3)
        }
    }
    func HideAddStorePopUp() -> Void{
        if blurrView != nil{
            blurrView.removeFromSuperview()
            AddStorePopUp.removeFromSuperview()
            blurrView = nil
        }
    }
    func ConfigureView() -> Void{
        //Set Navigation Bar Title
        navigationItem.title = String.StoresControllerTitle
        
        //Set TabBarItem Title
        self.tabBarController?.navigationItem.title = String.StoresControllerTitle
        
        //AddStore PopUp
        txt_AddStore.layer.borderWidth = 2
        txt_AddStore.layer.borderColor = UIColor.ColorPaletteSecondDarkest().cgColor
        txt_AddStore.textColor = UIColor.ColorPaletteSecondDarkest()
        txt_AddStore.layer.cornerRadius = 10
        txt_AddStore.placeholder = String.txt_AddStore_Placeholder  
        txt_AddStore.addTarget(self, action: #selector(txt_AddStore_TextChanged), for: .editingChanged)
    }
}
extension StoresController: UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return StoresArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.StoreCell_Identifier, for: indexPath) as! StoreCell
        if StoresArray.count > 0{
            let store = StoresArray[indexPath.row]
            cell.ConfigureCell(store: store)
        }        
        return cell
    }
    
    
    /*
     // conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // rearranging the table view.
     func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
