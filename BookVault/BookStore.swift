//
//  BookStore.swift
//  BookVault
//
//  Created by Caroline on 16.12.14.
//  Copyright (c) 2014 David Gollasch, Caroline Rausch. All rights reserved.
//

class BookStore {
    class var sharedInstance: BookStore {
        struct Static {
            static let instance = BookStore()
        }
        
        return Static.instance
    }
    
    var books: [Book] = []
    
    func add(book: Book) {
        books.append(book)
    }
    
    func replace(book: Book, atIndex index: Int) {
        books[index] = book
    }
    
    func get(index: Int) -> Book {
        return books[index]
    }
    
    func removeBookAtIndex(index: Int) {
        books.removeAtIndex(index)
    }
    
    var count: Int {
        return books.count
    }
}