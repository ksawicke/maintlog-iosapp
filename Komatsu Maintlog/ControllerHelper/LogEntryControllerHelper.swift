//
//  LogEntryControllerHelper.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/28/18.
//  Copyright © 2018 Kevin Sawicke. All rights reserved.
//

import UIKit
import CoreData

extension LogEntryController {
    
    func loadUsers() {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            let fetchRequest = NSFetchRequest(entityName: "User")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
            
            do {
                messages = try(context.executeFetchRequest(fetchRequest)) as? [User]
            } catch let err {
                print(err)
            }
        }
    }
    
}
