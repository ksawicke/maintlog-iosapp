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

class InspectionEntryController: UIViewController, UITextFieldDelegate {

    var checklistitemArray = [[String: String]]() //[ChecklistItem]()
    var userFormData = [[String: String]]()
    var questionNumber : Int = 0
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var currentInspectionItemLabel: UILabel!
    @IBOutlet weak var inspectionChoiceImage: UIImageView!
    @IBOutlet weak var currentInspectionItemBadNoteLabel: UILabel!
    @IBOutlet weak var currentInspectionItemBadNote: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var badNoteBottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var slidingView: UIView!
    
    @IBAction func onClickNext(_ sender: Any) {
        hideKeyboard()
        currentInspectionItemBadNoteLabel.isHidden = true
        currentInspectionItemBadNote.isHidden = true
        nextButton.isHidden = true
        
        appendFormData()
        
        questionNumber += 1
        
        nextInspectionItem()
    }
    
    @IBAction func onCloseInspectionEntryViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveBadNote(_ sender: Any) {
        
    }
    
    @IBAction func onChooseInspectionValue(_ sender: UIButton) {
        if (sender as AnyObject).tag == 1 {
            sender.pulsate()
            
            appendFormData()
            
            questionNumber += 1
            
            nextInspectionItem()
        } else if (sender as AnyObject).tag == 0 {
            // Unhide UI elements for Bad Notes
            currentInspectionItemBadNoteLabel.isHidden = false
            currentInspectionItemBadNote.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentInspectionItemBadNote.delegate = self
        
        currentInspectionItemBadNote.setLeftPaddingPoints(10)
        currentInspectionItemBadNote.setRightPaddingPoints(10)
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // Manually add items to ChecklistItem entity
        // Done 04/11/18
        addChecklistItems()

        // Manually add items to EquipmentType entity
        // Done 04/11/18
        addEquipmentTypes()
        
        loadItems()
        
        nextInspectionItem()

        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        // Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard() {
        currentInspectionItemBadNote.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
//        print("Keyboard will show: \(notification.name.rawValue)")
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height // Change keyboard Y position, must be below 0
        } else {
            view.frame.origin.y = 0 // Move keyboard back to bottom of screen
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("Return pressed")
        
        hideKeyboard()
        
        nextButton.isHidden = false
        
        return true
    }
    
    func addChecklistItems() {
        //        let checklistItem = ChecklistItem(context: context)
        //        checklistItem.id = 28
        //        checklistItem.item = "Secured Cargo"
        //
        //        let checklistItem2 = ChecklistItem(context: context)
        //        checklistItem2.id = 29
        //        checklistItem2.item = "Mirrors"
        //
        //        let checklistItem3 = ChecklistItem(context: context)
        //        checklistItem3.id = 30
        //        checklistItem3.item = "Horn/Alarm/Lights"
        //
        //        let checklistItem4 = ChecklistItem(context: context)
        //        checklistItem4.id = 31
        //        checklistItem4.item = "Test Instruments"
        //
        //        let checklistItem5 = ChecklistItem(context: context)
        //        checklistItem5.id = 32
        //        checklistItem5.item = "Handrails"
        //
        //        let checklistItem6 = ChecklistItem(context: context)
        //        checklistItem6.id = 33
        //        checklistItem6.item = "Leak Evidence"
        //
        //        let checklistItem7 = ChecklistItem(context: context)
        //        checklistItem7.id = 34
        //        checklistItem7.item = "Operators Manual"
        //
        //        let checklistItem8 = ChecklistItem(context: context)
        //        checklistItem8.id = 35
        //        checklistItem8.item = "First Aid Kit"
        //
        //        let checklistItem9 = ChecklistItem(context: context)
        //        checklistItem9.id = 36
        //        checklistItem9.item = "Blade/Bucket/Tool"
        //
        //        let checklistItem10 = ChecklistItem(context: context)
        //        checklistItem10.id = 37
        //        checklistItem10.item = "Visibility Flag Whip"
        //
        //        let checklistItem11 = ChecklistItem(context: context)
        //        checklistItem11.id = 38
        //        checklistItem11.item = "Tires"
        //
        //        let checklistItem12 = ChecklistItem(context: context)
        //        checklistItem12.id = 39
        //        checklistItem12.item = "Windows/Wipers"
        //
        //        let checklistItem13 = ChecklistItem(context: context)
        //        checklistItem13.id = 40
        //        checklistItem13.item = "Seat Controls"
        //
        //        let checklistItem14 = ChecklistItem(context: context)
        //        checklistItem14.id = 41
        //        checklistItem14.item = "Air Conditioner"
        //
        //        let checklistItem15 = ChecklistItem(context: context)
        //        checklistItem15.id = 42
        //        checklistItem15.item = "Suspension"
        //
        //        let checklistItem16 = ChecklistItem(context: context)
        //        checklistItem16.id = 43
        //        checklistItem16.item = "Seat Belt/Suspension"
        //
        //        let checklistItem17 = ChecklistItem(context: context)
        //        checklistItem17.id = 44
        //        checklistItem17.item = "Doors & Latches"
        //
        //        let checklistItem18 = ChecklistItem(context: context)
        //        checklistItem18.id = 45
        //        checklistItem18.item = "Brakes/Retard"
        //
        //        let checklistItem19 = ChecklistItem(context: context)
        //        checklistItem19.id = 46
        //        checklistItem19.item = "Brakes"
        //
        //        let checklistItem20 = ChecklistItem(context: context)
        //        checklistItem20.id = 47
        //        checklistItem20.item = "Seat Belt"
        //
        //        let checklistItem21 = ChecklistItem(context: context)
        //        checklistItem21.id = 48
        //        checklistItem21.item = "Dash Controls"
        //
        //        let checklistItem22 = ChecklistItem(context: context)
        //        checklistItem22.id = 49
        //        checklistItem22.item = "Displays/Gauges"
        //
        //        let checklistItem23 = ChecklistItem(context: context)
        //        checklistItem23.id = 50
        //        checklistItem23.item = "Steering"
        //
        // saveItems()
    }
    
    func addEquipmentTypes() {
        //        let equipmentType = EquipmentType(context: context)
        //        equipmentType.id = 5
        //        equipmentType.equipment_type = "Loader"
        //
        //        let equipmentType2 = EquipmentType(context: context)
        //        equipmentType2.id = 6
        //        equipmentType2.equipment_type = "Fork Lift"
        //
        //        let equipmentType3 = EquipmentType(context: context)
        //        equipmentType3.id = 7
        //        equipmentType3.equipment_type = "Other"
        //
        //        let equipmentType4 = EquipmentType(context: context)
        //        equipmentType4.id = 8
        //        equipmentType4.equipment_type = "Light Vehicle"
        //
        //        let equipmentType5 = EquipmentType(context: context)
        //        equipmentType5.id = 9
        //        equipmentType5.equipment_type = "Generators"
        //
        //        let equipmentType6 = EquipmentType(context: context)
        //        equipmentType6.id = 10
        //        equipmentType6.equipment_type = "Welders"
        //
        //        let equipmentType7 = EquipmentType(context: context)
        //        equipmentType7.id = 11
        //        equipmentType7.equipment_type = "Rental Equipment"
        //
        //        let equipmentType8 = EquipmentType(context: context)
        //        equipmentType8.id = 13
        //        equipmentType8.equipment_type = "Backhoe Loader"
        //
        //        let equipmentType9 = EquipmentType(context: context)
        //        equipmentType9.id = 14
        //        equipmentType9.equipment_type = "Manlift"
        //
        //        let equipmentType10 = EquipmentType(context: context)
        //        equipmentType10.id = 16
        //        equipmentType10.equipment_type = "Sweeper"
        //
        //        let equipmentType11 = EquipmentType(context: context)
        //        equipmentType11.id = 17
        //        equipmentType11.equipment_type = "Sweeper Mop"
        //
        //        let equipmentType12 = EquipmentType(context: context)
        //        equipmentType12.id = 19
        //        equipmentType12.equipment_type = "Haul Truck"
        //
        //        let equipmentType13 = EquipmentType(context: context)
        //        equipmentType13.id = 20
        //        equipmentType13.equipment_type = "Dozer"
        //
        //        let equipmentType14 = EquipmentType(context: context)
        //        equipmentType14.id = 21
        //        equipmentType14.equipment_type = "Motor Grader"
        //
        //        let b15 = EquipmentType(context: context)
        //        b15.id = 22
        //        b15.equipment_type = "Drill"
        //
        // saveItems()
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadItems() {
        let request : NSFetchRequest<ChecklistItem> = ChecklistItem.fetchRequest()
//        let results = []
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results {
                    let id = result.id
                    let item = result.item
                    
//                    print(item!)
                    
                    let dict = ["id": "\(id)", "item": "\(String(describing: item!))"]
                    
                    checklistitemArray.append(dict)
                }
            }
            
//            checklistitemArray = try context.fetch(request)
//            print(checklistitemArray)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func appendFormData() {
        // Add entered stuff to array
        var saveId : String = "";
        var saveItem : String = "";
        var saveNote : String = "";
        
        let prevchecklistitem: [String : String] = checklistitemArray[questionNumber]
        
        for(key, value) in prevchecklistitem {
            if(key=="id") {
                saveId = value
            }
            if(key=="item") {
                saveItem = "\(value)"
            }
        }
        
        saveNote = currentInspectionItemBadNote.text!
        
        let saveDict = ["id": "\(saveId)", "item": "\(saveItem)", "note": "\(saveNote)"]
        
        userFormData.append(saveDict)
        
        print(userFormData)
    }
    
    func nextInspectionItem() {
        if questionNumber <= 10 {
            // Get next Checklist Item
            
            let checklistitem: [String : String] = checklistitemArray[questionNumber]
            
            for(key, value) in checklistitem {
//                print("\(key) \(value)")
                if(key=="item") {
                    currentInspectionItemLabel.text = value
                }
            }
            
            currentInspectionItemBadNote.text = ""
            
            // Change icon to grey
            
//            inspectionItemBadNote.text = "\(nextLabelText)"
//            currentInspectionItemLabel.text = "Test \(questionNumber)"
            
//            updateUI()
            
//            questionLabel.text = allQuestions.list[questionNumber].questionText
//            updateUI()
            
        } else {
            
            let alert = UIAlertController(title: "Awesome", message: "You finished this inspection. Start over?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (action: UIAlertAction!) in
//                self.startOver()
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUI() {
        
    }
    
}
