//
//  EquipmentTypeCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/18/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class EquipmentTypeCoreDataHandler: NSObject {

    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int32, equipmentType: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "EquipmentType", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(equipmentType, forKey: "equipmentType")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [EquipmentType]? {
        let context = getContext()
        let equipmenttype:[EquipmentType]? = nil
        
        do {
            let equipmenttype = try context.fetch(EquipmentType.fetchRequest())
            
            return equipmenttype as? [EquipmentType]
        } catch {
            return equipmenttype
        }
    }
    
    class func deleteObject(equipmenttype: EquipmentType) -> Bool {
        let context = getContext()
        context.delete(equipmenttype)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: EquipmentType.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName:String, filterType:String, queryString:String) -> [EquipmentType]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<EquipmentType> = EquipmentType.fetchRequest()
        var equipmenttype:[EquipmentType]? = nil
        
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
            equipmenttype = try context.fetch(fetchRequest)
            
            return equipmenttype
        } catch {
            return equipmenttype
        }
    }
    
}
