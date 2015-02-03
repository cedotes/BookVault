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
    @IBOutlet weak var newIsbn: UITextField!
    @IBOutlet weak var newYear: UITextField!
    @IBOutlet weak var newImage: UIImageView!
    
    @IBOutlet weak var bookIsOwned: UISwitch!
    
    var managedContextOfNewItemVC:NSManagedObjectContext? = nil
    var publicVolumes : GTLBooksVolumes! = nil
    var publicVolumesFetchError : NSError! = nil
    var publicVolumesTicket : GTLServiceTicket! = nil
    var service : GTLServiceBooks! = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Save input data for storage in ViewController
        if segue.identifier == "dismissAndSave" {
            self.saveBook(newTitle.text, author: newAuthor.text, owned: bookIsOwned.on)
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
    
    @IBAction func fetchInformationByIsbn(sender: UIButton) {
        let text = newIsbn.text;
        
        // cancel fetching if no isbn has been entered
        if(text == "") {
            // give an alert
            let warning = "Please enter an ISBN first!"
            let alertController = UIAlertController(title: "Alert ISBN", message:
                warning, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

            return;
        }
        
        self.publicVolumes = nil;
        self.publicVolumesFetchError = nil;
        
        let query = GTLQueryBooks.queryForVolumesListWithQ(text) as GTLQueryBooks;
        query.shouldSkipAuthorization = true;
        
        service = GTLServiceBooks();
        service.authorizer = nil;
        //service.APIKey = "AIzaSyBIQ9S92Xzym2Guv11HhbSTN5XO55imRV8";
        
        publicVolumesTicket = self.service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            self.publicVolumes = object as? GTLBooksVolumes
            self.publicVolumesFetchError = error
            self.publicVolumesTicket = nil
            
            self.updateFetchedDetails()
        })
        
        updateFetchedDetails()
        
        /*
        if(self.publicVolumes == nil) {
            
            if(newIsbn.text == "3833833351") {
                newTitle.text = "Weber's Burger: Die besten Grillrezepte mit und ohne Fleisch (GU Weber Grillen)";
                newAuthor.text = "Jamie Purviance";
                newYear.text = "2013";
                
                let fileURL = NSBundle.mainBundle().URLForResource("cover1", withExtension: "jpg");
                let beginImage = CIImage(contentsOfURL: fileURL);
                let endImage = UIImage(CIImage: beginImage);
                newImage.image = endImage;
                
                return;
            }
            
            // give an alert
            let warning = "The book cannot be found!"
            let alertController = UIAlertController(title: "Sorry!", message:
                warning, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return;
        }
        
        var NumberOfResults = self.publicVolumes.totalItems
        
        // give an alert
        let warning = "Google Books found " + NumberOfResults.description + " results."
        let alertController = UIAlertController(title: "Success!", message:
            warning, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
*/
    }
    
    func updateFetchedDetails() {
        if(self.publicVolumes != nil) {
            var publicVolume : GTLBooksVolume = self.publicVolumes.itemAtIndex(0) as GTLBooksVolume;
            var publicVolumeInfo : GTLBooksVolumeVolumeInfo = publicVolume.volumeInfo;
            
            if(!publicVolumeInfo.title.isEmpty) {
                self.newTitle.text = publicVolumeInfo.title;
            }
            
            if(!publicVolumeInfo.publishedDate.isEmpty) {
                self.newYear.text = publicVolumeInfo.publishedDate;
            }
            
            if(!publicVolumeInfo.authors.isEmpty) {
                self.newAuthor.text = publicVolumeInfo.authors.description;
            }
            
            if(!publicVolumeInfo.imageLinks.thumbnail.isEmpty) {
                var coverUrl = publicVolumeInfo.imageLinks.thumbnail
                let url = NSURL(string: coverUrl)
                let data = NSData(contentsOfURL: url!)
                newImage.image = UIImage(data: data!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveBook(title: String, author: String, owned: Bool) {
        // if textFields are empty -> alert
        if(newTitle.text != "" && newAuthor.text != "") {
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
                    inManagedObjectContext: managedContextOfNewItemVC!)
                
                let book = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContextOfNewItemVC)
                
                //Key-Value-Coding for attributes
                book.setValue(title, forKey: "title")
                book.setValue(author, forKey: "author")
                book.setValue(owned, forKey: "owned")
                
                //commit changes by saving + error handling
                var error: NSError?
                if !managedContextOfNewItemVC!.save(&error) {
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
