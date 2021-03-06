//
//  SmrUpdateCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 6/19/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class LogEntryCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(uuid: String, jsonData: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "LogEntry", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(uuid, forKey: "uuid")
        managedObject.setValue(jsonData, forKey: "jsonData")
        managedObject.setValue(false, forKey: "uploaded")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func markAsUploaded(uuid: String) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogEntry")
        fetchRequest.predicate = NSPredicate(format: "uuid = '\(uuid)'")
        let result = try? managedObjectContext.fetch(fetchRequest)
        let resultData = result as! [LogEntry]
        for object in resultData {
            print(object.uploaded)
            if object.uploaded == false {
                object.setValue(true, forKey: "uploaded")
            }
        }
        do {
            try managedObjectContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    class func fetchObject() -> [LogEntry]? {
        let context = getContext()
        let logentry:[LogEntry]? = nil
        
        do {
            let logentry = try context.fetch(LogEntry.fetchRequest())
            
            return logentry as? [LogEntry]
        } catch {
            return logentry
        }
    }
    
    class func deleteObject(logentry: LogEntry) -> Bool {
        let context = getContext()
        context.delete(logentry)
        
        do {
            try context.save()
            
            return true
        } catch let error as NSError {
            print("Error saving context after delete \(error.localizedDescription)")
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: LogEntry.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func countData() -> Int {
        let context = getContext()
        let fetchRequest:NSFetchRequest<LogEntry> = LogEntry.fetchRequest()
        var logEntryCount:Int? = 0
        
        let predicate = NSPredicate(format: "uploaded = false")
        fetchRequest.predicate = predicate
        
        do {
            logEntryCount = try context.count(for: fetchRequest)
            
            return logEntryCount!
        } catch {
            return logEntryCount!
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [LogEntry]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<LogEntry> = LogEntry.fetchRequest()
        var logentry:[LogEntry]? = nil
        
        switch(filterType) {
        case "equals":
            let predicate = NSPredicate(format: "\(fieldName) == %@", queryString)
            fetchRequest.predicate = predicate
            
        case "contains":
            let predicate = NSPredicate(format: "\(fieldName) contains[c] %@", queryString)
            fetchRequest.predicate = predicate
            
        default:
            let predicate = NSPredicate(format: "\(fieldName) == %@", queryString)
            fetchRequest.predicate = predicate
        }
        
        do {
            logentry = try context.fetch(fetchRequest)
            
            return logentry
        } catch {
            return logentry
        }
    }
    
}
