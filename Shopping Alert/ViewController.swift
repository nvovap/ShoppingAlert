//
//  ViewController.swift
//  Shopping Alert
//
//  Created by Gabriel Theodoropoulos on 12/11/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var txtAddItem: UITextField!
    
    @IBOutlet weak var tblShoppingList: UITableView!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    var shoppingList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tblShoppingList.delegate = self
        self.tblShoppingList.dataSource = self
        
        self.txtAddItem.delegate = self
        
        datePicker.hidden = true
        
        
        loadShoppingList()
    }
    
    
    @IBAction func sheduleReminder(sender: UIButton) {
        if datePicker.hidden {
            animateMyViews(tblShoppingList, viewToShow: datePicker)
        } else {
            animateMyViews(datePicker, viewToShow: tblShoppingList)
        }
        
        txtAddItem.enabled = !txtAddItem.enabled
    }
    
    
    // MARK: - Implementation notification 
    func setupNotificationSetting() {
        
        var justInformAction = UIMutableUserNotificationAction()
        justInformAction.identifier = "justInform"
        justInformAction.title = "OK, got it"
        justInformAction.activationMode = UIUserNotificationActivationMode.Background
        justInformAction.destructive = false
        justInformAction.authenticationRequired = false
        
        
        var modifyListAction = UIMutableUserNotificationAction()
        modifyListAction.identifier = "editList"
        modifyListAction.title = "Edit list"
        modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
        modifyListAction.destructive = false
        modifyListAction.authenticationRequired = true
        
        
        var trashAction = UIMutableUserNotificationAction()
        trashAction.identifier = "trashAction"
        trashAction.title = "Delete list"
        trashAction.activationMode = UIUserNotificationActivationMode.Foreground
        trashAction.destructive = false
        trashAction.authenticationRequired = true
        
        let actionsArray = [justInformAction, modifyListAction, trashAction]
        let actionsArrayMinimal = [trashAction, modifyListAction]
        
        
        var shoppingListReminderCategory = UIMutableUserNotificationCategory()
        shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
        shoppingListReminderCategory.setActions(actionsArray, forContext: UIUserNotificationActionContext.Default)
        shoppingListReminderCategory.setActions(actionsArrayMinimal, forContext: UIUserNotificationActionContext.Minimal)

    }
    

    // MARK: - Animate Transaction
    
    func animateMyViews(viewToHide: UIView, viewToShow: UIView) {
        let animationDuration = 0.35
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            viewToHide.transform = CGAffineTransformScale(viewToHide.transform, 0.001, 0.001)
            
            }) { (completion: Bool) -> Void in
                
                viewToHide.hidden = true
                viewToShow.hidden = false
                
                viewToShow.transform = CGAffineTransformScale(viewToShow.transform, 0.001, 0.001)
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    viewToShow.transform = CGAffineTransformIdentity
                })
        }
    }
    
    
    // MARK: - Save and load data on disk
    func loadShoppingList() {
        let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = pathsArray[0]
        
        print(documentsDirectory)
        
        let loadPath = documentsDirectory.stringByAppendingString("/shopping_list")
        
        if NSFileManager.defaultManager().fileExistsAtPath(loadPath) {
            shoppingList = NSMutableArray(contentsOfFile: loadPath)
            tblShoppingList.reloadData()
        }
        
       
        
    }
    
    func saveShoppingList() {
        let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = pathsArray[0]
        
        print(documentsDirectory)
        
        let savePath = documentsDirectory.stringByAppendingString("/shopping_list")
        
        shoppingList.writeToFile(savePath, atomically: true)
        
    }

    
    
    // MARK: Implement UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if shoppingList == nil {
            shoppingList = NSMutableArray()
        }
        
        shoppingList.addObject(textField.text!)
        
        tblShoppingList.reloadData()
        
        txtAddItem.text = ""
        txtAddItem.resignFirstResponder()
        
        saveShoppingList()
        
        return true
    }
    

    // MARK: IBAction method implementation

    @IBAction func scheduleReminder(sender: AnyObject) {
        
    }
    
    
    // MARK: UITableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let list = shoppingList {
            rows = list.count
        }
        
        return rows
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        
        cell.textLabel?.text = shoppingList[indexPath.row] as? String
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            remoteItemAtIndex(indexPath.row)
        }
    }
    
    func remoteItemAtIndex(index: Int) {
        shoppingList.removeObjectAtIndex(index)
        
        saveShoppingList()
        
        tblShoppingList.reloadData()
    }
    
}

