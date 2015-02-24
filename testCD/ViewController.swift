//
//  ViewController.swift
//  testCD
//
//  Created by Mercedes Streeter on 2/11/15.
//  Copyright (c) 2015 Mercedes Streeter. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var logItems = [LogItem]()
    
    
 //   var logTableView = UITableView(frame: CGRectZero, style: .Plain)


    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var button: UIBarButtonItem!
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let moc = self.managedObjectContext {
            LogItem.createInManagedObjectContext(moc, title: "first name", text: "text 1")
        }
        //view table cell stuff
        var viewFrame = self.view.frame
        viewFrame.origin.y += 20
        
        
        
        //add button code
        let button = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        button.setTitle("+", forState: .Normal)
        button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        button.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        viewFrame.size.height -= (20 + button.frame.size.height)
        table.frame = viewFrame
        self.view.addSubview(table)
        table.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "LogCell")

        
        table.dataSource = self
        table.delegate = self
        
        fetchLog()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/**
    func presentItemInfo(){
        let fetchRequest = NSFetchRequest(entityName: "LogItem")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LogItem] {
            let alert = UIAlertController(title: fetchResults[0].name,
                message: fetchResults[0].notes,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }*/
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "LogItem")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //predicate filter 
        /**let predicate = NSPredicate(format: "name == %@", "first name")
        
        fetchRequest.predicate = predicate
        */
        
        //combining predicates
       // let firstPredicate = NSPredicate(format: <#String#>, <#args: CVarArgType#>...)
       // let secondPredicate = NSPredicate(format: <#String#>, <#args: CVarArgType#>...)
       // let predicat = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate!, secondPredicate!])
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LogItem] {
            logItems = fetchResults
        }
    }
    
    
    //UITableViewDataSource functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as UITableViewCell
        let logItem = logItems[indexPath.row]
        cell.textLabel?.text = logItem.name
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let logItem = logItems[indexPath.row]
        println(logItem.notes)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete){
            //find the logItem object the user is trying to delete
            let logItemToDelete = logItems[indexPath.row]
            
            //delete it from the managedObjectContext
            managedObjectContext?.deleteObject(logItemToDelete)
            
            //refresh the table view to indicate that its deleted
            self.fetchLog()
            
            //tell the table view to animate out the row
            table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func addNewItem(){
        var titlePrompt = UIAlertController(title: "Enter Name: ",
            message: "Enter text: ",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Title"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.saveNewItem(textField.text)
                }
                }))
        
        self.presentViewController(titlePrompt, animated: true, completion: nil)
    }
    
    func saveNewItem(title: String){
        //create new log item
        var newLogItem = LogItem.createInManagedObjectContext(self.managedObjectContext!, title: title, text: "")
        
        //update the array containing the table view row data
        self.fetchLog()
        
        //animate in the new row, use swift's find() function to figure out the index of the newLogItem
        //after its been added and sorted in our logItems array
        if let newItemIndex = find(logItems, newLogItem) {
            //create an NSIndexPath from the newItemIndex
            let newLogItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            //animate in the insertion of this row
            table.insertRowsAtIndexPaths([newLogItemIndexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func save(){
        var error : NSError?
        if(managedObjectContext!.save(&error))
        {
            println(error?.localizedDescription)
        }
    }
    
}

