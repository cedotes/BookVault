//
//  ViewController.swift
//  BookVault
//
//  Created by Caroline on 15.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    var books = [NSManagedObject]()
    
    // Function to prepopulate View
    func loadInitialData(){
        self.saveBook("Test Book", author: "By Me")
        self.saveBook("Another Book", author: "By Someone Else")
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // ONLY FOR DEVELOPMENT: if core data is too much populated, easily restore to just dummy data
        //  HOW TO USE: uncomment, run, comment, run again
        //self.deleteAllBooks()
        if (self.isEmpty()){
            loadInitialData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // set the correct number of rows for number of items in BookStore
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    // Allow for custom cells and define them
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("customTableViewCell") as UITableViewCell
        
        
        let book = books[indexPath.row]
        cell.textLabel?.text = book.valueForKey("title") as String?
        cell.detailTextLabel?.text = book.valueForKey("author") as String?
        
        var imageName = UIImage(named: "cover150x250.jpeg")
        cell.imageView?.image = imageName
        
        return cell
    }
    
    // define swipe actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            BookStore.sharedInstance.removeBookAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
        

    @IBAction func editItemsInTableView(sender: UIBarButtonItem) {
        
        // dummy function:
        let alertController = UIAlertController(title: "Alert", message:
            "clicked Edit", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Extract relevant data for the editViewController from the cell and save it for the next viewController
    }
    
    func saveBook(title: String, author: String) {
        //get NSManagedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //create new managed object and insert it into managed object context
        let entity =  NSEntityDescription.entityForName("Book",
            inManagedObjectContext: managedContext)
        
        let book = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //Key-Value-Coding for attributes
        book.setValue(title, forKey: "title")
        book.setValue(author, forKey: "author")
        
        //commit changes by saving + error handling
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        //insert into table to show up
        books.append(book)
    }
    
    
    //TODO: complete function
    func containsBook(title: String, author: String) -> Bool{
        return true
    }
    
    //check if CoreData entity is empty
    func isEmpty() -> Bool{
        //get NSManagedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //fetch all objects of entity
        let fetchRequest = NSFetchRequest(entityName:"Book")
        
        //parse fetched data
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if (fetchedResults?.count == 0){
            return true
        }else{
            return false
        }
    }
    
    //delete
    func deleteAllBooks(){
        //get NSManagedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //fetch all objects of entity
        let fetchRequest = NSFetchRequest(entityName:"Book")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]!
        
        for item in fetchedResults {
            managedContext.deleteObject(item)
        }
        
        managedContext.save(nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //get NSManagedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //fetch all objects of entity
        let fetchRequest = NSFetchRequest(entityName:"Book")
        
        //parse fetched data
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            books = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
}

