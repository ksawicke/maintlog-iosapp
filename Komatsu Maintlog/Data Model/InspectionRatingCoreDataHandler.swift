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
    
    class func saveObject(id: Int32, equipmentUnitId: Int32, item: String, rating: Int32, note: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "InspectionImage", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(equipmentUnitId, forKey: "equipmentUnitId")
        managedObject.setValue(item, forKey: "item")
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
    
    class func filterData(fieldName:String, filterType:String, queryString:String) -> [InspectionRating]? {
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
