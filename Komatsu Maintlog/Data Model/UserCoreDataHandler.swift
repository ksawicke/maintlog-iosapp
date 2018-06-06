//
//  EquipmentTypeCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 6/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class UserCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(id: Int16, firstName: String, lastName: String, emailAddress: String, role: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(firstName, forKey: "firstName")
        managedObject.setValue(lastName, forKey: "lastName")
        managedObject.setValue(emailAddress, forKey: "emailAddress")
        managedObject.setValue(role, forKey: "role")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [User]? {
        let context = getContext()
        let user:[User]? = nil
        
        do {
            let user = try context.fetch(User.fetchRequest())
            
            return user as? [User]
        } catch {
            return user
        }
    }
    
    class func deleteObject(user: User) -> Bool {
        let context = getContext()
        context.delete(user)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: User.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [User]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        var user:[User]? = nil
        
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
            user = try context.fetch(fetchRequest)
            
            return user
        } catch {
            return user
        }
    }
    
}
