//
//  ChecklistItemCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/18/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class ChecklistItemCoreDataHandler: NSObject {

    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int32, item: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ChecklistItem", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(item, forKey: "item")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [ChecklistItem]? {
        let context = getContext()
        let checklistitem:[ChecklistItem]? = nil
        
        do {
            let checklistitem = try context.fetch(ChecklistItem.fetchRequest())
            
            return checklistitem as? [ChecklistItem]
        } catch {
            return checklistitem
        }
    }
    
    class func deleteObject(checklistitem: ChecklistItem) -> Bool {
        let context = getContext()
        context.delete(checklistitem)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: ChecklistItem.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName:String, filterType:String, queryString:String) -> [ChecklistItem]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<ChecklistItem> = ChecklistItem.fetchRequest()
        var checklistitem:[ChecklistItem]? = nil
        
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
            checklistitem = try context.fetch(fetchRequest)
            
            return checklistitem
        } catch {
            return checklistitem
        }
    }
    
}
