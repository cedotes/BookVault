//
//  AddNewItemViewController.swift
//  BookVault
//
//  Created by Caroline on 15.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit
import CoreData

class AddNewItemViewController: UIViewController {
    
    @IBOutlet weak var newTitle: UITextField!
    @IBOutlet weak var newAuthor: UITextField!
    
    var managedContextOfNewItemVC:NSManagedObjectContext? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Save input data for storage in ViewController
        if segue.identifier == "dismissAndSave" {
            self.saveBook(newTitle.text, author: newAuthor.text)
        }
    }
    
    @IBAction func checkForEntries(sender: UIBarButtonItem) {
        // NOT FUNCTIONAL
       if (newTitle == ""){
            newTitle.backgroundColor = UIColor.redColor()
        }
        else {
            // perform Segue with Identifier "addNewItemSegue" if title is set
            performSegueWithIdentifier("addNewItemSegue", sender: self)
        }
        
    }
    
    @IBAction func showFurtherInformation(sender: UIButton) {
        let alertController = UIAlertController(title: "Alert", message:
            "clicked show", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveBook(title: String, author: String) {
        // if textFields are empty -> alert
        if(newTitle.text != "" && newAuthor.text != "") {
            //TODO: check if entry already exists
            // first test for title, then for author; if not existent, create new entry
            var books = [Book]()
            if (self.containsBook(newTitle.text, author: newAuthor.text)){
                let alertController = UIAlertController(title: "Alert", message:
                    "Book entry with identical title and author already exits", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }else{
                //create new managed object and insert it into managed object context
                let entity =  NSEntityDescription.entityForName("Book",
                    inManagedObjectContext: managedContextOfNewItemVC)
                
                let book = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContextOfNewItemVC)
                
                //Key-Value-Coding for attributes
                book.setValue(title, forKey: "title")
                book.setValue(author, forKey: "author")
                
                //commit changes by saving + error handling
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
            }
        }else{
            var msg = ""
            if (newTitle.text == ""){
                msg = "Title field is empty. Please enter a title."
            }else{
                msg = "Author field is empty. Please enter an author."
            }
            let alertController = UIAlertController(title: "Alert", message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)

            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func containsBook(title: String, author: String) -> Bool{
        var fetchRequest = NSFetchRequest(entityName: "Book")
        fetchRequest.predicate = NSPredicate(format: "title = %@", newTitle.text!)
        
        let countOfDuplicateItemsWithSameTitle = managedContextOfNewItemVC!.countForFetchRequest(fetchRequest, error: nil)
        
        if(countOfDuplicateItemsWithSameTitle > 0){
            fetchRequest.predicate = NSPredicate(format: "author = %@", newAuthor.text!)
            
            let countOfDuplicateItemsWithSameAuthor = managedContextOfNewItemVC!.countForFetchRequest(fetchRequest, error: nil)
            if(countOfDuplicateItemsWithSameAuthor > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }        
}
