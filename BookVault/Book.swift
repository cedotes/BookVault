//
//  BookVault.swift
//  BookVault
//
//  Created by Caroline on 24.01.15.
//  Copyright (c) 2015 David Gollasch, Caroline Rausch. All rights reserved.
//

import Foundation
import CoreData

class Book: NSManagedObject {

    @NSManaged var author: String?
    @NSManaged var title: String?
    @NSManaged var owned: NSNumber?

}
