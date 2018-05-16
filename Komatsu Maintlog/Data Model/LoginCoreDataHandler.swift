//
//  LoginCoreDataHandler
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 5/8/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class LoginCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(userId: Int16, userName: String, firstName: String, lastName: String, emailAddress: String, role: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Login", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(userId, forKey: "userId")
        managedObject.setValue(userName, forKey: "userName")
        managedObject.setValue(firstName, forKey: "firstName")
        managedObject.setValue(lastName, forKey: "lastName")
        managedObject.setValue(emailAddress, forKey: "emailAddress")
        managedObject.setValue(role, forKey: "role")
        managedObject.setValue(Date(), forKey: "created")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [Login]? {
        let context = getContext()
        let login:[Login]? = nil
        
        do {
            let login = try context.fetch(Login.fetchRequest())
            
            return login as? [Login]
        } catch {
            return login
        }
    }
    
    class func deleteObject(login: Login) -> Bool {
        let context = getContext()
        context.delete(login)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Login.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [Login]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<Login> = Login.fetchRequest()
        var login:[Login]? = nil
        
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
            login = try context.fetch(fetchRequest)
            
            return login
        } catch {
            return login
        }
    }
    
}
