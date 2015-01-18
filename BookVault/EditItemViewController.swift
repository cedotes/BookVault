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
    
    var book: Book? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if book != nil {
            titleField.text = book?.title
            authorField.text = book?.author
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Save input data for storage in ViewController
        if segue.identifier == "dismissAndSave" {
            // Replace entry in CoreData        
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
    

}
