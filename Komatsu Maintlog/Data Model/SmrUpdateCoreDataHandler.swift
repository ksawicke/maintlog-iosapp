//
//  SmrUpdateCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 6/19/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class SmrUpdateCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(inspectionId: String, equipmentUnitId: Int16, smr: String, userId: Int16) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "SmrUpdate", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(inspectionId, forKey: "inspectionId")
        managedObject.setValue(equipmentUnitId, forKey: "equipmentUnitId")
        managedObject.setValue(smr, forKey: "smr")
        managedObject.setValue(userId, forKey: "userId")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [SmrUpdate]? {
        let context = getContext()
        let smrupdate:[SmrUpdate]? = nil
        
        do {
            let smrupdate = try context.fetch(SmrUpdate.fetchRequest())
            
            return smrupdate as? [SmrUpdate]
        } catch {
            return smrupdate
        }
    }
    
    class func deleteObject(smrupdate: SmrUpdate) -> Bool {
        let context = getContext()
        context.delete(smrupdate)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: SmrUpdate.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func countData() -> Int {
        let context = getContext()
        let fetchRequest:NSFetchRequest<SmrUpdate> = SmrUpdate.fetchRequest()
        var smrUpdateCount:Int? = 0
        
        let predicate = NSPredicate(format: "userId != 99999")
        fetchRequest.predicate = predicate
        
        do {
            smrUpdateCount = try context.count(for: fetchRequest)
            
            return smrUpdateCount!
        } catch {
            return smrUpdateCount!
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [SmrUpdate]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<SmrUpdate> = SmrUpdate.fetchRequest()
        var smrupdate:[SmrUpdate]? = nil
        
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
            smrupdate = try context.fetch(fetchRequest)
            
            return smrupdate
        } catch {
            return smrupdate
        }
    }
    
}
