//
//  EquipmentTypeCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/18/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class FluidTypeCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int16, equipmentType: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "FluidType", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(equipmentType, forKey: "fluidType")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [FluidType]? {
        let context = getContext()
        let fluidtype:[FluidType]? = nil
        
        do {
            let fluidtype = try context.fetch(FluidType.fetchRequest())
            
            return fluidtype as? [FluidType]
        } catch {
            return fluidtype
        }
    }
    
    class func deleteObject(fluidtype: FluidType) -> Bool {
        let context = getContext()
        context.delete(fluidtype)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: FluidType.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [FluidType]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<FluidType> = FluidType.fetchRequest()
        var fluidtype:[FluidType]? = nil
        
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
            fluidtype = try context.fetch(fetchRequest)
            
            return fluidtype
        } catch {
            return fluidtype
        }
    }
    
}
