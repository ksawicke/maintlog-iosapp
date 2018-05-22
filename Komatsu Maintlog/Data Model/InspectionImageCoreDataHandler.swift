//
//  InspectionImageCoreDataHandler.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/24/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class InspectionImageCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(inspectionId: Int16, photoId: Int16, image: NSData) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "InspectionImage", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObject.setValue(inspectionId, forKey: "inspectionId")
        managedObject.setValue(photoId, forKey: "photoId")
        managedObject.setValue(image, forKey: "image")
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func fetchObject() -> [InspectionImage]? {
        let context = getContext()
        let inspectionImage:[InspectionImage]? = nil
        let fetchRequest:NSFetchRequest<InspectionImage> = InspectionImage.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false // Critical this stays here to get data out of the call!
        fetchRequest.fetchLimit = 1
        
        do {
            let inspectionImage = try context.fetch(fetchRequest)
            
            return inspectionImage as [InspectionImage]
        } catch {
            return inspectionImage
        }
    }
    
    class func deleteObject(inspectionImage: InspectionImage) -> Bool {
        let context = getContext()
        context.delete(inspectionImage)
        
        do {
            try context.save()
            
            return true
        } catch {
            return false
        }
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: InspectionImage.fetchRequest())
        
        do {
            try context.execute(delete)
            
            return true
        } catch {
            return false
        }
    }
    
    class func countData() -> Int {
        let context = getContext()
        let fetchRequest:NSFetchRequest<InspectionImage> = InspectionImage.fetchRequest()
        var inspectionImageCount:Int? = nil
        var _ = 0
        
        let predicate = NSPredicate(format: "inspectionId <> 0")
        fetchRequest.predicate = predicate
        
        do {
            inspectionImageCount = try context.count(for: fetchRequest)
            
            return inspectionImageCount!
        } catch {
            return inspectionImageCount!
        }
    }
    
    class func filterData(fieldName: String, filterType: String, queryString: String) -> [InspectionImage]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<InspectionImage> = InspectionImage.fetchRequest()
        var inspectionImage:[InspectionImage]? = nil
        
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
            inspectionImage = try context.fetch(fetchRequest)
            
            return inspectionImage
        } catch {
            return inspectionImage
        }
    }
    
}
