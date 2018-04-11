//
//  InspectionEntryController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class InspectionEntryController: UIViewController {
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func onCloseInspectionEntryViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let newItem = Item(entity: <#T##NSEntityDescription#>, insertInto: <#T##NSManagedObjectContext?#>)
//        newItem.title = "Wake Up"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.title = "Make Breakfast"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "Eat Breakfast"
//        itemArray.append(newItem3)
        
        
        
        let newItem = Item(context: context)
        newItem.title = "Eat Breakfast"
        newItem.done = false
        
        itemArray.append(newItem)
        
        let newItem2 = Item(context: context)
        newItem2.title = "Wash Hands"
        newItem2.done = true
        
        itemArray.append(newItem2)
        
        saveItems()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
}
