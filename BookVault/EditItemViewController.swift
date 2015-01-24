//
//  EditItemViewController.swift
//  BookVault
//
//  Created by Caroline on 18.01.15.
//  Copyright (c) 2015 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit
import CoreData

class EditItemViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var bookIsOwned: UISwitch!
    
    var book: Book? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if book != nil {
            titleField.text = book?.title
            authorField.text = book?.author
            bookIsOwned.on = book?.owned as Bool
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Save input data for storage in ViewController
        if segue.identifier == "dismissAndSave" {
            // Replace entry in CoreData
            self.saveChangedBook(titleField.text, author: authorField.text, owned: bookIsOwned.on)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFurtherInformation(sender: UIButton) {
        let alertController = UIAlertController(title: "Alert", message:
            "clicked show", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveChangedBook(title: String, author: String, owned: Bool) {
        //get NSManagedObjectContext
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //create new managed object and insert it into managed object context
        let entity =  NSEntityDescription.entityForName("Book",
            inManagedObjectContext: managedContext)
        
        //check if Book already exists
        if book != nil {
            book?.setValue(titleField.text as String, forKey: "title")
            book?.setValue(authorField.text as String, forKey: "author")
            book?.setValue(bookIsOwned.on, forKey: "owned")
        }else{

            let newBook = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
        
            //Key-Value-Coding for attributes
            newBook.setValue(title, forKey: "title")
            newBook.setValue(author, forKey: "author")
            newBook.setValue(owned, forKey: "owned")
        
            //commit changes by saving + error handling
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
    }

    

}
