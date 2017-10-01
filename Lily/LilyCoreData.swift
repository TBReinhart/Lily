//
//  LilyCoreData.swift
//  Lily
//
//  Created by Tom Reinhart on 12/28/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class LilyCoreData {
    // loads first entity
    static func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LilyUser")
        fetchRequest.fetchLimit = 1

        do {
            let user = try managedContext.fetch(fetchRequest)
            print("PRINTING USER IN LOAD")
            debugPrint(user)
            for item in user {
                print(item.objectID)
                for key in item.entity.attributesByName.keys{
                    let _: Any? = item.value(forKey: key)
                    //print("\(key) = \(value)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }


    // updates the user with a key value pair. if none exists, then will create.
    // can be used instead of save
    // TODO: should take a list of key value pairs to save time.
    static func update(key: String, value: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let users = fetchRecordsForEntity()
        var user: NSManagedObject? = nil
        
        if let userRecord = users.first {
            user = userRecord
        } else if let userRecord = createRecordForEntity() {
            user = userRecord
        }
        if let user = user {
            print(user.value(forKey: key) ?? "NO \(key)")
            user.setValue(value, forKey: key)

        }
        print("number of users: \(users.count)")
        print("--")
        print(user ?? "NONE")
        
        do {
            // Save Managed Object Context
            try managedContext.save()
            
        } catch {
            print("Unable to save managed object context.")
        }
    }
    
    
    static func save(keyPath: String, value: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LilyUser",
                                                in: managedContext)!
        
        let user = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        // example: user.setValue("Tom Reinhart", forKeypath: "fullName")
        user.setValue(value, forKeyPath: keyPath)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    
    // helper to create
    static func createRecordForEntity() -> NSManagedObject? {
        var result: NSManagedObject? = nil

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return result
        }
        let entity = "LilyUser"
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        
        return result
    }
    
    
    // helper to fetch
    static func fetchRecordsForEntity() -> [NSManagedObject] {
        // Create Fetch Request
        let entity = "LilyUser"
        var result = [NSManagedObject]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return result
        }
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    /**
     
        PLEASE DO NOT USE THIS FUNCTION UNLESS YOU ARE CERTAIN WE NEED TO WIPE THE USER FROM THE SYSTEM
     
     */
    static func deleteAllUsers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LilyUser")
        
        do {
            let user = try managedContext.fetch(fetchRequest)
            print("PRINTING USER IN LOAD")
            debugPrint(user)
            for item in user {
               managedContext.delete(item)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        do {
            // Save Managed Object Context
            try managedContext.save()
            
        } catch {
            print("Unable to save managed object context.")
        }
        
    }

        
    

}
