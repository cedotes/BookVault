//
//  ViewController.swift
//  BookVault
//
//  Created by Caroline on 15.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var books = [Book]()
    
    @IBOutlet private var editBarButtonItem: UIBarButtonItem!
    @IBOutlet private var doneBarButtonItem: UIBarButtonItem!


    let managedContext:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    // ========================================
    // MARK: Core Data Functions
    // ========================================
    private func configureCell(cell: UITableViewCell, book: Book) {
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.valueForKey("author") as String?
        
        var imageName = UIImage(named: "cover150x250.jpeg")
        cell.imageView?.image = imageName
    }
    
    private lazy var fetchControllerDelegate: FetchControllerDelegate = {        
        let delegate = FetchControllerDelegate(tableView: self.tableView)
        delegate.onUpdate = {
            (cell: UITableViewCell, object: AnyObject) in
            self.configureCell(cell, book: object as Book)
        }
        
        return delegate
        }()
    
    func getSortedFetchRequest() -> NSFetchRequest {
        //fetch all objects of entity
        let fetchRequest = NSFetchRequest(entityName:"Book")
        
        let sortDescriptorForAuthor = NSSortDescriptor(key: "author", ascending: true)
        let sortDescriptorForOwnedStatus = NSSortDescriptor(key: "owned", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorForOwnedStatus, sortDescriptorForAuthor]
        
        return fetchRequest
    }
    
    func getFetchResultController() -> NSFetchedResultsController{
        let fetchedResultController = NSFetchedResultsController(fetchRequest: getSortedFetchRequest(), managedObjectContext: managedContext, sectionNameKeyPath: "owned", cacheName: nil)
        return fetchedResultController
    }

    func getFetchResults() -> [Book]? {
        //parse fetched data
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(getSortedFetchRequest(), error: &error) as [Book]?
        books = fetchedResults!
        
        return fetchedResults
    }
    
    // ========================================
    // MARK: View methods
    // ========================================
    
    // MARK: View lifecycle
    
    override func setEditing(editing: Bool, animated: Bool)  {
        super.setEditing(editing, animated: animated)
        
        self.numberOfSectionsInTableView(tableView)
        
        navigationItem.leftBarButtonItem = editing ? doneBarButtonItem : editBarButtonItem
    }
    
    // MARK: User interaction
    
    @IBAction func toggleEditing() {
        setEditing(!editing, animated: true)
        
        if ((doneBarButtonItem) != nil){
            tableView.reloadData()
        }
    }
    
    // Function to prepopulate View
    func loadInitialData(){
        self.saveBook("Test Book", author: "By Me", owned: true)
        self.saveBook("Another Book", author: "By Someone Else", owned: false)
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = getFetchResultController()
        fetchedResultController.delegate = self.fetchControllerDelegate
        fetchedResultController.performFetch(nil)
        self.getFetchResults()
        
        if (self.isEmpty()){
            loadInitialData()
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    // Set the correct number of rows for number of items
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects

        return numberOfRowsInSection!
    }
    
    // Allow for custom cells and define them
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("customTableViewCell", forIndexPath: indexPath) as UITableViewCell
        
        let book = fetchedResultController.objectAtIndexPath(indexPath) as Book
        cell.textLabel?.text = book.valueForKey("title") as String?
        cell.detailTextLabel?.text = book.valueForKey("author") as String?
        
        var imageName = UIImage(named: "cover150x250.jpeg")
        cell.imageView?.image = imageName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if let sections = fetchedResultController.sections as? [NSFetchedResultsSectionInfo] {
            if (sections[section].name == "0"){
                return "Wishlist"
            }else if (sections[section].name == "1"){
                return "Owned books"
            }else{
                return "sectionName"
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }
        
        fetchControllerDelegate.ignoreNextUpdates = true
        let book = fetchedResultController.objectAtIndexPath(sourceIndexPath) as Book
        
        if sourceIndexPath.section != destinationIndexPath.section {
            
            if (destinationIndexPath.section == 1){
                book.owned = true
            } else{
                book.owned = false
            }
            
            // Update cell
            NSOperationQueue.mainQueue().addOperationWithBlock { // Table view is in inconsistent state, gotta wait
                if let cell = tableView.cellForRowAtIndexPath(destinationIndexPath) {
                    self.configureCell(cell, book: book)
                }
            }
        }
        
        // Save
        book.managedObjectContext!.save(nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editItemSegue" {
            let cell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            
            if let editController:EditItemViewController = segue.destinationViewController as? EditItemViewController{
                
                editController.book = fetchedResultController.objectAtIndexPath(indexPath!) as? Book
            }
        }
        else if segue.identifier == "newItemSegue" {
            let newItemController:AddNewItemViewController = segue.destinationViewController as AddNewItemViewController
            newItemController.managedContextOfNewItemVC = managedContext
        }
    }

    
    // ========================================
    //MARK: NSFetchedResultsController Delegate Functions
    // ========================================

    // define swipe actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // remove the deleted item from the model
            let fetchedObject = fetchedResultController.objectAtIndexPath(indexPath) as Book
            managedContext.deleteObject(fetchedObject as NSManagedObject)
            books.removeAtIndex(indexPath.row)
            managedContext.save(nil)
        }
    }
    
    // ========================================
    // MARK: Custom methods
    // ========================================
    
    func saveBook(title: String, author: String, owned: Bool) {
        //create new managed object and insert it into managed object context
        let entity =  NSEntityDescription.entityForName("Book",
            inManagedObjectContext: managedContext)
        
        let book = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext) as Book
        
        //Key-Value-Coding for attributes
        book.setValue(title, forKey: "title")
        book.setValue(author, forKey: "author")
        book.setValue(owned, forKey: "owned")
        
        //commit changes by saving + error handling
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        //insert into table to show up
        books.append(book)
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
}

