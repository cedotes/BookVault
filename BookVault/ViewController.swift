//
//  ViewController.swift
//  BookVault
//
//  Created by Caroline on 15.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var books = [Book]()
    
    let managedContext:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    func getSortedFetchRequest() -> NSFetchRequest {
        //fetch all objects of entity
        let fetchRequest = NSFetchRequest(entityName:"Book")
        
        let sortDescriptor = NSSortDescriptor(key: "author", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func getFetchResultController() -> NSFetchedResultsController{
        let fetchedResultController = NSFetchedResultsController(fetchRequest: getSortedFetchRequest(), managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultController
    }
    
    func getFetchResultForRow(){
        let fetchRequest = NSFetchRequest(entityName: "Book")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "author", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "1st Item" exactly.
        let predicate = NSPredicate(format: "title == %@", "Titel")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [Book] {
            books = fetchResults
        }
    }
    
    
    func getFetchResults() -> [Book]? {
        //parse fetched data
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(getSortedFetchRequest(), error: &error) as [Book]?
        books = fetchedResults!
        
        return fetchedResults
    }
    
    // Function to prepopulate View
    func loadInitialData(){
        self.saveBook("Test Book", author: "By Me")
        self.saveBook("Another Book", author: "By Someone Else")
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchedResultController = getFetchResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)
        self.getFetchResults()
        
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
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    // Allow for custom cells and define them
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("customTableViewCell", forIndexPath: indexPath) as UITableViewCell
        
        
        let book = books[indexPath.row]
        cell.textLabel?.text = book.valueForKey("title") as String?
        cell.detailTextLabel?.text = book.valueForKey("author") as String?
        
        var imageName = UIImage(named: "cover150x250.jpeg")
        cell.imageView?.image = imageName
        
        return cell
    }
    
    //MARK: NSFetchedResultsController Delegate Functions
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Move:
            break
        case NSFetchedResultsChangeType.Update:
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }

    // define swipe actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // remove the deleted item from the model
            managedContext.deleteObject(books[indexPath.row] as NSManagedObject)
            books.removeAtIndex(indexPath.row)
            managedContext.save(nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
        
    //TODO
    @IBAction func editItemsInTableView(sender: UIBarButtonItem) {
        // dummy function:
        let alertController = UIAlertController(title: "Alert", message:
            "clicked Edit", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // TODO: Extract relevant data for the editViewController from the cell and save it for the next viewController
        if segue.identifier == "editItemSegue" {
            let cell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            
                if let editController:EditItemViewController = segue.destinationViewController as? EditItemViewController{
                    /*
                        *** DEBUG ***
                    
                        habe: angeklickte Zelle (Text 'titel' bekannt), IndexPfad für die Zelle, Controller des zweiten Views.
                        benötige: extrahiere Book Objekt aus der CoreData DB
                    
                        wie? 
                        - mit fetchedResultController? hat objectAtIndexPath Methode. Funktioniert nicht. Rückgabe nil
                        - mit fetchedResults? let fetchedResults = self.getFetchResults()
                    
                    */
                    //let book = fetchedResultController.objectAtIndexPath(indexPath!) as Book <- funktioniert nicht
                    
                    // give Book object info to the secondViewController
                    editController.book = books[indexPath!.row]
                }
            }
    }
    
    func saveBook(title: String, author: String) {
        //create new managed object and insert it into managed object context
        let entity =  NSEntityDescription.entityForName("Book",
            inManagedObjectContext: managedContext)
        
        let book = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext) as Book
        
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
        let fetchedResults = self.getFetchResults()
        
        if (fetchedResults?.count == 0){
            return true
        }else{
            return false
        }
    }
    
    //delete
    func deleteAllBooks(){
        let fetchedResults = self.getFetchResults()!
        
        for item in fetchedResults {
            managedContext.deleteObject(item)
        }
        managedContext.save(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let fetchedResults = self.getFetchResults()

        if let results = fetchedResults {
            books = results
        } else {
            println("Could not fetch results.")
        }
    }
    
    /*
    FINISH: sections for tableView
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if let sections = fetchedResultController.sections as? [NSFetchedResultsSectionInfo] {
        return sections[section].name
        }
        return nil
    }
    */
}

