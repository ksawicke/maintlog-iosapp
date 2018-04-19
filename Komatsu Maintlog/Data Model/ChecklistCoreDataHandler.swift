//
//  ChecklistCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/18/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class ChecklistCoreDataHandler: NSObject {

    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int32, equipmenttype_id: Int32, checklist_json: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Checklist", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(equipmenttype_id, forKey: "equipmenttype_id")
        managedObject.setValue(checklist_json, forKey: "checklist_json")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [Checklist]? {
        let context = getContext()
        let checklist:[Checklist]? = nil
        
        do {
            let checklist = try context.fetch(Checklist.fetchRequest())
            
            return checklist as? [Checklist]
        } catch {
            return checklist
        }
    }
    
    class func deleteObject(checklist: Checklist) -> Bool {
        let context = getContext()
        context.delete(checklist)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Checklist.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName:String, filterType:String, queryString:String) -> [Checklist]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<Checklist> = Checklist.fetchRequest()
        var checklist:[Checklist]? = nil
        
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
            checklist = try context.fetch(fetchRequest)
            
            return checklist
        } catch {
            return checklist
        }
    }
    
}