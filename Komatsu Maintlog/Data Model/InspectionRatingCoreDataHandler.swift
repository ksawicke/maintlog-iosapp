//
//  InspectionRatingCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/24/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class InspectionRatingCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(inspectionId: String, equipmentUnitId: Int16, checklistItemId: Int16, rating: Int16, note: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "InspectionRating", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(inspectionId, forKey: "inspectionId")
        managedObject.setValue(equipmentUnitId, forKey: "equipmentUnitId")
        managedObject.setValue(checklistItemId, forKey: "checklistItemId")
        managedObject.setValue(rating, forKey: "rating")
        managedObject.setValue(note, forKey: "note")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [InspectionRating]? {
        let context = getContext()
        let inspectionRating:[InspectionRating]? = nil
        let fetchRequest:NSFetchRequest<InspectionRating> = InspectionRating.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false // Critical this stays here to get data out of the call!
        
        do {
            let inspectionRating = try context.fetch(fetchRequest)
            
            return inspectionRating as [InspectionRating]
        } catch {
            return inspectionRating
        }
    }
    
    class func deleteObject(inspectionRating: InspectionRating) -> Bool {
        let context = getContext()
        context.delete(inspectionRating)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: InspectionRating.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func countData() -> Int {
        let context = getContext()
        let fetchRequest:NSFetchRequest<InspectionRating> = InspectionRating.fetchRequest()
        var inspectionRatingCount:Int? = nil
        var _ = 0
        
        let predicate = NSPredicate(format: "rating == 0 OR rating == 1")
        fetchRequest.predicate = predicate
        
        do {
            inspectionRatingCount = try context.count(for: fetchRequest)
            
            return inspectionRatingCount!
        } catch {
            return inspectionRatingCount!
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [InspectionRating]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<InspectionRating> = InspectionRating.fetchRequest()
        var inspectionRating:[InspectionRating]? = nil
        
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
            inspectionRating = try context.fetch(fetchRequest)
            
            return inspectionRating
        } catch {
            return inspectionRating
        }
    }
    
}
