//
//  ComponentCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 7/17/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class ComponentCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int16, component: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Component", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(component, forKey: "component")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [Component]? {
        let context = getContext()
        let component:[Component]? = nil
        
        do {
            let component = try context.fetch(Component.fetchRequest())
            
            return component as? [Component]
        } catch {
            return component
        }
    }
    
    class func deleteObject(component: Component) -> Bool {
        let context = getContext()
        context.delete(component)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Component.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [Component]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<Component> = Component.fetchRequest()
        var component:[Component]? = nil
        
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
            component = try context.fetch(fetchRequest)
            
            return component
        } catch {
            return component
        }
    }
    
}
