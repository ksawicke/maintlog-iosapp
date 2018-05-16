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
    
    class func saveObject(inspectionId: Int16, checklistId: Int16, equipmentUnitId: String, rating: Int16, note: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "InspectionRating", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(inspectionId, forKey: "inspectionId")
        managedObject.setValue(checklistId, forKey: "checklistId")
        managedObject.setValue(equipmentUnitId, forKey: "equipmentUnitId")
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
        
        do {
            let inspectionRating = try context.fetch(InspectionRating.fetchRequest())
            
            return inspectionRating as? [InspectionRating]
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
        var inspectionRating:Int? = nil
        var _ = 0
        
        let predicate = NSPredicate(format: "rating == 0 OR rating == 1")
        fetchRequest.predicate = predicate
        
        do {
            inspectionRating = try context.count(for: fetchRequest)
            
            return inspectionRating!
        } catch {
            return inspectionRating!
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
