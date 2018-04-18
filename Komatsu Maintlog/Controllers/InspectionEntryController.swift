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
    var equipmentTypeSelected : String = ""
    var questionNumber : Int = 0
    
    var checklistitem:[ChecklistItem]? = nil
    
    //Constants
//    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
//    let APP_ID = "27474384dc09e3a1d2109468edeee08f"

    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    @IBOutlet weak var currentInspectionItemLabel: UILabel!
    @IBOutlet weak var inspectionChoiceImage: UIImageView!
    @IBOutlet weak var currentInspectionItemBadNoteLabel: UILabel!
    @IBOutlet weak var currentInspectionItemBadNote: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var progressBar: UIView!
    
    @IBAction func onClickNext(_ sender: Any) {
        hideKeyboard()
        currentInspectionItemBadNoteLabel.isHidden = true
        currentInspectionItemBadNote.isHidden = true
        nextButton.isHidden = true
        
        appendFormData(rating: "0")
        
        questionNumber += 1
        
        nextInspectionItem()
    }
    
    @IBAction func onCloseInspectionEntryViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveBadNote(_ sender: Any) {
        
    }
    
    @IBAction func onChooseInspectionValue(_ sender: UIButton) {
        if (sender as AnyObject).tag == 1 && currentInspectionItemBadNote.isHidden == true {
            sender.shake()
            
            appendFormData(rating: "1")
            
            questionNumber += 1
            
            nextInspectionItem()
        } else if (sender as AnyObject).tag == 0 && currentInspectionItemBadNote.isHidden == true {
            sender.shake()
            
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
        
        deleteItems()
        
        addEquipmentTypes()
        addChecklists()
        addChecklistItems()
        
        equipmentTypeSelected = "2"
        
        loadItems()
        
        nextInspectionItem()
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
    
//    func getWeatherData(url: String, parameters: [String : String]) {
//
//        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
//            response in
//            if response.result.isSuccess {
//                print("Success! Got the weather data")
//
//                let weatherJSON : JSON = JSON(response.result.value!)
//                self.updateWeatherData(json: weatherJSON)
//
//            } else {
//                print("ERROR getting weather data...") // response.result.error
//                self.cityLabel.text = "Connection Issues"
//            }
//        }
//
//    }
    
//    func parseChecklistJson(checklist_json : JSON) {
    
//        if let preStartData = checklist_json["preStart"] {
        
//            weatherDataModel.condition = json["weather"][0]["id"].intValue
//            weatherDataModel.city = json["name"].stringValue
//            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
//
//            updateUIWithWeatherData()
            
//        } else {
    
//            cityLabel.text = "Weather Unavailable"
            
//        }
    
//    }
    
    func addChecklists() {
        _ = ChecklistCoreDataHandler.saveObject(id: 2, equipmenttype_id: 8, checklist_json: "{\"preStartData\":[\"42\",\"38\",\"30\",\"33\",\"47\",\"29\",\"39\",\"31\",\"44\",\"35\",\"37\"],\"postStartData\":[\"50\",\"46\",\"40\",\"41\",\"48\",\"49\"]}")
    }
    
    func addChecklistItems() {
        _ = ChecklistItemCoreDataHandler.saveObject(id: 28, item: "Secured Cargo")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 29, item: "Mirrors")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 30, item: "Horn/Alarm/Lights")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 31, item: "Test Instruments")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 32, item: "Handrails")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 33, item: "Leak Evidence")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 34, item: "Operators Manual")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 35, item: "First Aid Kit")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 36, item: "Blade/Bucket/Tool")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 37, item: "Visibility Flag Whip")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 38, item: "Tires")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 39, item: "Windows/Wipers")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 40, item: "Seat Controls")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 41, item: "Air Conditioner")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 42, item: "Suspension")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 43, item: "Seat Belt/Suspension")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 44, item: "Doors & Latches")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 45, item: "Brakes/Retard")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 46, item: "Brakes")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 47, item: "Seat Belt")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 48, item: "Dash Controls")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 49, item: "Displays/Gauges")
        _ = ChecklistItemCoreDataHandler.saveObject(id: 50, item: "Steering")
    }
    
    func addEquipmentTypes() {
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 5, equipment_type: "Loader")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 6, equipment_type: "Fork Lift")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 7, equipment_type: "Other")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 8, equipment_type: "Light Vehicle")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 9, equipment_type: "Generators")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 10, equipment_type: "Welders")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 11, equipment_type: "Rental Equipment")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 13, equipment_type: "Backhoe Loader")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 14, equipment_type: "Manlift")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 16, equipment_type: "Sweeper")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 17, equipment_type: "Sweeper Mop")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 19, equipment_type: "Haul Truck")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 20, equipment_type: "Dozer")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 21, equipment_type: "Motor Grader")
        _ = EquipmentTypeCoreDataHandler.saveObject(id: 22, equipment_type: "Drill")
    }
    
    func deleteItems() {
        _ = EquipmentTypeCoreDataHandler.cleanDelete()
        _ = ChecklistCoreDataHandler.cleanDelete()
        _ = ChecklistItemCoreDataHandler.cleanDelete()
    }
    
    func loadItems() {
        let checklist = ChecklistCoreDataHandler.filterData(fieldName: "id", filterType: "equals", queryString: equipmentTypeSelected)
        let checklistitem = ChecklistItemCoreDataHandler.fetchObject()
        
        
        
        if (checklist != nil) {
            for j in checklist! {
                let id = j.id
                let equipmenttype_id = j.equipmenttype_id
//                let checklist_json = j.checklist_json
                
//                let checklist_json: [String: [String:Any]] = j.checklist_json
                
                print(id)
                print(equipmenttype_id)
//                print(checklist_json)
                
                // https://www.swiftyninja.com/escaped-string-json-using-swift/
                
                let jsonData = j.checklist_json?.data(using: .utf8)
                
//                print(j.checklist_json)
//                print("&&&")
//
//                print("\(jsonData)")
//                print("##")
                
                var dic: [String : Any]?
                
                do {
                    dic = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String : Any]

                    let preStartData = ("\(dic!["preStartData"]!)")
                   
                    // https://stackoverflow.com/questions/25678373/swift-split-a-string-into-an-array
                    // https://stackoverflow.com/questions/36594179/remove-all-non-numeric-characters-from-a-string-in-swift
                    let preStartDataArr = (preStartData as AnyObject).components(separatedBy: ",")
//                    let postStartDataArr = (postStartData as AnyObject).components(separatedBy: ",")
                    
                    let unsafeChars = CharacterSet.alphanumerics.inverted  // Remove the .inverted to get the opposite result.
                    
                    let blah = preStartDataArr[0].components(separatedBy: unsafeChars).joined(separator: "")

                    
                    print("@\(blah)@")
//                    print("@\(blah1)@")
                } catch {
                    print(error.localizedDescription)
                }
                
//                parseChecklistJson(checklist_json : JSON)
            }
        }
        
        if (checklistitem != nil) {
            for i in checklistitem! {
                let id = i.id
                let item = i.item!
                
                let dict = ["id": "\(id)", "item": "\(String(describing: item))"]
                
                checklistitemArray.append(dict)
            }
        } else {
            print("Error fetching checklistitems")
        }
    }
    
    func appendFormData(rating: String) {
        // Add entered stuff to array
        var saveId : String = "";
        var saveItem : String = "";
        var saveRating : String = "";
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
        saveRating = rating
        
        let saveDict = ["id": "\(saveId)", "item": "\(saveItem)", "rating": "\(saveRating)", "note": "\(saveNote)"]
        
        userFormData.append(saveDict)
        
//        print(userFormData)
    }
    
    func nextInspectionItem() {
        let numChecklistItems = Int(checklistitemArray.count)
        
//        print(questionNumber)
//        print(numChecklistItems)
        
        if questionNumber < numChecklistItems {
            // Get next Checklist Item
            
            let checklistitem: [String : String] = checklistitemArray[questionNumber]
            
            for(key, value) in checklistitem {
                if(key=="item") {
                    currentInspectionItemLabel.text = value
                }
            }
            
            updateUI()
            
        } else {
            
            let alert = UIAlertController(title: "Awesome", message: "You finished this inspection. Start over?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (action: UIAlertAction!) in
                self.startOver()
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func startOver() {
        loadItems()
        
        questionNumber = 0
        
        nextInspectionItem()
    }
    
    func updateUI() {
        let windowWidth = view.frame.size.width
        let piece = (windowWidth - 10) / CGFloat(checklistitemArray.count)
        let totalWidth = piece * CGFloat(questionNumber)
        
        currentInspectionItemBadNote.text = ""
        
        progressBar.frame.size.width = totalWidth + 10
    }
    
}
