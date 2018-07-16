//
//  ComponentTypeCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 7/16/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class ComponentTypeCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int16, componentType: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ComponentType", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(componentType, forKey: "componentType")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [ComponentType]? {
        let context = getContext()
        let componenttype:[ComponentType]? = nil
        
        do {
            let componenttype = try context.fetch(ComponentType.fetchRequest())
            
            return componenttype as? [ComponentType]
        } catch {
            return componenttype
        }
    }
    
    class func deleteObject(componenttype: ComponentType) -> Bool {
        let context = getContext()
        context.delete(componenttype)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: ComponentType.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [ComponentType]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<ComponentType> = ComponentType.fetchRequest()
        var componenttype:[ComponentType]? = nil
        
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
            componenttype = try context.fetch(fetchRequest)
            
            return componenttype
        } catch {
            return componenttype
        }
    }
    
}
