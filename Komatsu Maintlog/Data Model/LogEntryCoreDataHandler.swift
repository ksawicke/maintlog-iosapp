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
    
    class func saveObject(uuid: String, equipmentUnitId: Int16, subflow: String, jsonData: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "LogEntry", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(uuid, forKey: "uuid")
        managedObject.setValue(equipmentUnitId, forKey: "equipmentUnitId")
        managedObject.setValue(subflow, forKey: "subflow")
        managedObject.setValue(jsonData, forKey: "jsonData")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
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
        } catch {
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
        
        let predicate = NSPredicate(format: "equipmentUnitId > 0")
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
