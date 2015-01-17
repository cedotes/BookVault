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
    
    // DUPLICATE FUNCTION
    // TODO: check how to access function in root viewController
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
    }

        
}
