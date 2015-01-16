//
//  AddNewItemViewController.swift
//  BookVault
//
//  Created by Caroline on 15.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

import UIKit

class AddNewItemViewController: UIViewController {
    
    @IBOutlet weak var newTitle: UITextField!
    @IBOutlet weak var newAuthor: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Save input data for storage in ViewController
        if segue.identifier == "dismissAndSave" {
            let book = Book(title: newTitle.text, author: newAuthor.text)
            BookStore.sharedInstance.add(book)
        }
    }
    
    @IBAction func checkForEntries(sender: UIBarButtonItem) {
        if (newTitle == ""){
            newTitle.backgroundColor = UIColor.redColor()
        }
        else {
            // perform Segue with Idetifier "addNewItemSegue" if title is set
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
        
}
