//
//  EquipmentUnitCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 5/30/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class EquipmentUnitCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int16, equipmentTypeId: Int16, manufacturerName: String, modelNumber: String, unitNumber: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "EquipmentUnit", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(equipmentTypeId, forKey: "equipmentTypeId")
        managedObject.setValue(manufacturerName, forKey: "manufacturerName")
        managedObject.setValue(modelNumber, forKey: "modelNumber")
        managedObject.setValue(unitNumber, forKey: "unitNumber")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [EquipmentUnit]? {
        let context = getContext()
        let equipmentunit:[EquipmentUnit]? = nil
        
        do {
            let equipmentunit = try context.fetch(EquipmentUnit.fetchRequest())
            
            return equipmentunit as? [EquipmentUnit]
        } catch {
            return equipmentunit
        }
    }
    
    class func deleteObject(equipmentunit: EquipmentUnit) -> Bool {
        let context = getContext()
        context.delete(equipmentunit)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: EquipmentUnit.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterDataByEquipmentTypeId(equipmentTypeId: Int16) -> [EquipmentUnit]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<EquipmentUnit> = EquipmentUnit.fetchRequest()
        var checklist:[EquipmentUnit]? = nil
        
        let predicate = NSPredicate(format: "equipmentTypeId == %@", "\(equipmentTypeId)")
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false // Critical this stays here to get data out of the call!
        
        do {
            checklist = try context.fetch(fetchRequest)
            
            return checklist
        } catch {
            return checklist
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [EquipmentUnit]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<EquipmentUnit> = EquipmentUnit.fetchRequest()
        var equipmentunit:[EquipmentUnit]? = nil
        
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
            equipmentunit = try context.fetch(fetchRequest)
            
            return equipmentunit
        } catch {
            return equipmentunit
        }
    }
    
}
