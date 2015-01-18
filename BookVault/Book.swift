//
//  Book.swift
//  BookVault
//
//  Created by Caroline on 18.01.15.
//  Copyright (c) 2015 David Gollasch, Caroline Rausch. All rights reserved.
//

import Foundation
import CoreData

class Book: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var title: String

}
