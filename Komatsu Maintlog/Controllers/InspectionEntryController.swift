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

class InspectionEntryController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var checklistitemPrestartArray = [[String: String]]()
    var checklistitemPoststartArray = [[String: String]]()
    var imagesTaken = [[String: Any]]()
    var userFormData = [[String: String]]()
    var equipmentTypeSelected : String = ""
    var questionNumber : Int = 0
    var equipmentUnit : String = ""
    var currentSection : String = ""
    var checklistitem:[ChecklistItem]? = nil
    var imagePickerController : UIImagePickerController!
    var progressLabelText : String = ""
    
    //Constants
//    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
//    let APP_ID = "27474384dc09e3a1d2109468edeee08f"

    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    @IBOutlet weak var currentSectionLabel: UILabel!
    @IBOutlet weak var currentInspectionItemLabel: UILabel!
    @IBOutlet weak var inspectionChoiceImage: UIImageView!
    @IBOutlet weak var inspectionGoodButton: UIButton!
    @IBOutlet weak var inspectionBadButton: UIButton!
    @IBOutlet weak var currentInspectionItemBadNoteLabel: UILabel!
    @IBOutlet weak var currentInspectionItemBadNote: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var takePicture1Button: UIButton!
    @IBOutlet weak var takePicture2Button: UIButton!
    @IBOutlet weak var picture1: UIImageView!
    @IBOutlet weak var picture2: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var progressBar: UIView!
    
    @IBAction func onClickTakePicture(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.view.tag = (sender as AnyObject).tag;
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        hideKeyboard()
        currentInspectionItemBadNoteLabel.isHidden = true
        currentInspectionItemBadNote.isHidden = true
        takePicture1Button.isHidden = true
        takePicture2Button.isHidden = true
        picture1.isHidden = true
        picture2.isHidden = true
        nextButton.isHidden = true
        
        appendFormData(rating: "0")
        
        questionNumber += 1
        
        picture1.image = nil
        picture2.image = nil
        
        nextInspectionItem()
    }
    
    @IBAction func onCloseInspectionEntryViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveBadNote(_ sender: Any) {
        
    }
    
    @IBAction func onChooseInspectionValue(_ sender: UIButton) {
        if (sender as AnyObject).tag == 1 && currentInspectionItemBadNote.isHidden == true {
            inspectionGoodButton.setImage(UIImage(named: "icons8-ok"), for: [])
            sender.shake()
            
            appendFormData(rating: "1")
            
            questionNumber += 1
            
            nextInspectionItem()
        } else if (sender as AnyObject).tag == 0 && currentInspectionItemBadNote.isHidden == true {
            inspectionBadButton.setImage(UIImage(named: "icons8-cancel"), for: [])
            sender.shake()
            
            // Unhide UI elements for Bad Notes
            currentInspectionItemBadNoteLabel.isHidden = false
            currentInspectionItemBadNote.isHidden = false
            takePicture1Button.isHidden = false
            takePicture2Button.isHidden = false
            picture1.isHidden = false
            picture2.isHidden = false
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
        
        // TODO 04/19/18: Allow user to pick the Equipment Unit from
        // a previous screen that needs to be created.
        // Allow the user to scan a barcode that will pick the
        // Unit which will dynamically select the equipment type
        // instead of being hard coded.
        equipmentTypeSelected = "2"
        equipmentUnit = "FBFC-3325-BBCD-2222"
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePickerController.dismiss(animated: true, completion: nil)
        
        let pictureTaken = info[UIImagePickerControllerOriginalImage] as? UIImage
 
        if(picker.view.tag == 1) {
            picture1.image = pictureTaken?.imageFlippedForRightToLeftLayoutDirection()
            picture1.isHidden = false
            takePicture1Button.isHidden = true
            takePicture1Button.setImage(UIImage(named: "icons8-camera"), for: [])
            takePicture2Button.isEnabled = true
        } else if (picker.view.tag == 2) {
            picture2.image = pictureTaken?.imageFlippedForRightToLeftLayoutDirection()
            picture2.isHidden = false
            takePicture2Button.isHidden = true
            takePicture1Button.isEnabled = false
            takePicture2Button.isEnabled = false
            takePicture1Button.setImage(UIImage(named: "icons8-camera"), for: [])
        }
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
                // https://www.swiftyninja.com/escaped-string-json-using-swift/
                
                let jsonData = j.checklist_json?.data(using: .utf8)
                
                var dic: [String : Any]?
                
                do {
                    dic = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String : Any]

                    let preStartData = ("\(dic!["preStartData"]!)")
                    let postStartData = ("\(dic!["postStartData"]!)")
                   
                    // https://stackoverflow.com/questions/25678373/swift-split-a-string-into-an-array
                    // https://stackoverflow.com/questions/36594179/remove-all-non-numeric-characters-from-a-string-in-swift
                    let preStartDataArr = (preStartData as AnyObject).components(separatedBy: ",")
                    let postStartDataArr = (postStartData as AnyObject).components(separatedBy: ",")
                    
                    let unsafeChars = CharacterSet.alphanumerics.inverted  // Remove the .inverted to get the opposite result.
                    
                    for index in 0...preStartDataArr.count-1 {
                        let checklistItemId = preStartDataArr[index].components(separatedBy: unsafeChars).joined(separator: "")

                        appendToChecklistItemArray(id: checklistItemId, checklistitem: checklistitem!, appendTo: "preStart")
                    }
                    
                    for index in 0...postStartDataArr.count-1 {
                        let checklistItemId = postStartDataArr[index].components(separatedBy: unsafeChars).joined(separator: "")
                        
                        appendToChecklistItemArray(id: checklistItemId, checklistitem: checklistitem!, appendTo: "postStart")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func appendToChecklistItemArray(id: String, checklistitem: [ChecklistItem], appendTo: String) {
        if (checklistitem != nil) {
            for i in checklistitem {
                let thisChecklistitemId = i.id
                let thisChecklistitemItem = i.item!
                
                if(String(id) == String(thisChecklistitemId)) {
                    let dict = ["id": "\(thisChecklistitemId)", "item": "\(String(describing: thisChecklistitemItem))"]
                    
                    if appendTo=="preStart" {
                        checklistitemPrestartArray.append(dict)
                    } else if appendTo=="postStart" {
                        checklistitemPoststartArray.append(dict)
                    }
                }
            }
        }
    }
    
    func appendFormData(rating: String) {
        let numChecklistItems = Int(checklistitemPrestartArray.count) + Int(checklistitemPoststartArray.count)
        var counter = questionNumber
        
        var saveId : String = "";
        var saveItem : String = "";
        var saveRating : String = "";
        var saveNote : String = "";
        let equipmentUnitId : String = equipmentUnit
        
        if questionNumber <= checklistitemPrestartArray.count-1 {
            counter = questionNumber
            let prevchecklistitem: [String : String] = checklistitemPrestartArray[counter]
            
            for(key, value) in prevchecklistitem {
                if(key=="id") {
                    saveId = value
                }
                if(key=="item") {
                    saveItem = "\(value)"
                }
            }
            
            currentSection = "preStart"
        } else {
            counter = numChecklistItems - questionNumber - 1
            let prevchecklistitem: [String : String] = checklistitemPoststartArray[counter]
            
            for(key, value) in prevchecklistitem {
                if(key=="id") {
                    saveId = value
                }
                if(key=="item") {
                    saveItem = "\(value)"
                }
            }
            
            currentSection = "postStart"
        }
        
        saveNote = currentInspectionItemBadNote.text!
        saveRating = rating

        let saveDict = ["id": "\(saveId)", "equipmentUnitId": "\(equipmentUnitId)", "item": "\(saveItem)", "rating": "\(saveRating)", "note": "\(saveNote)"]
        
        userFormData.append(saveDict)
        
        if picture1.image != nil {
            appendPicture(inspectionID: saveId, photoId: "1", image: picture1.image!)
        }
        
        if picture2.image != nil {
            appendPicture(inspectionID: saveId, photoId: "2", image: picture2.image!)
        }
        
        saveInspectionLocally()
        
//        print(imagesTaken)
//        print(userFormData)
    }
    
    func appendPicture(inspectionID: String, photoId: String, image: UIImage) {
        let imageDict = ["inspectionId": "\(inspectionID)", "photoId": "\(photoId)", "image": image] as [String : Any]
        
        imagesTaken.append(imageDict)
    }
    
    func nextInspectionItem() {
        let numChecklistItems = Int(checklistitemPrestartArray.count) + Int(checklistitemPoststartArray.count)
        var counter = questionNumber
        var sectionLabel : String = ""
        var itemLabel : String = ""
        
        if questionNumber < numChecklistItems {
            // Get next Checklist Item
            
            if questionNumber <= checklistitemPrestartArray.count-1 {
                counter = questionNumber
                let checklistitem: [String : String] = checklistitemPrestartArray[counter]
                
                for(key, value) in checklistitem {
                    if(key=="item") {
                        itemLabel = value
                    }
                }
                
                sectionLabel = "Pre-Start"
            } else {
                counter = numChecklistItems - questionNumber - 1
                let checklistitem: [String : String] = checklistitemPoststartArray[counter]
                
                for(key, value) in checklistitem {
                    if(key=="item") {
                        itemLabel = value
                    }
                }
                
                sectionLabel = "Post-Start"
            }
            
            updateUI(sectionLabel: sectionLabel, itemLabel: itemLabel)
        } else {
            saveInspectionLocally()
            
            let alert = UIAlertController(title: "Awesome", message: "You finished this inspection. Start over?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (action: UIAlertAction!) in
                self.startOver()
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveInspectionLocally() {
//        for (index, item) in userFormData.enumerated() {
//            var id = item["id"]
//            var equipmentUnitId = equipmentUnit
//            var item = item["item"]
//            var rating = item!["rating"]
//            var note = item!["note"]
//            
//            _ = InspectionRatingCoreDataHandler.saveObject(id: id, equipmentUnitId: equipmentUnitId, item: item, rating: rating, note: note)
//            _ = EquipmentTypeCoreDataHandler.saveObject(id: 5, equipment_type: "Loader")
//        }
        
        // userFormData
//        [
//         ["note": "shshsh", "rating": "0", "id": "42", "item": "Suspension"],
//         ["note": "shshshs", "rating": "0", "id": "38", "item": "Tires"],
//         ["note": "", "rating": "1", "id": "30", "item": "Horn/Alarm/Lights"],
//         ["note": "", "rating": "1", "id": "33", "item": "Leak Evidence"],
//         ["note": "", "rating": "1", "id": "47", "item": "Seat Belt"]
//        ]
        
        // imagesTaken
//        [
//         ["photoId": "1", "image": <UIImage: 0x1c02acc60> size {3024, 4032} orientation 3 scale 1.000000, "inspectionId": "42"],
//         ["photoId": "2", "image": <UIImage: 0x1c02a55e0> size {3024, 4032} orientation 3 scale 1.000000, "inspectionId": "38"]
//        ]
    }
    
    func startOver() {
//        loadItems()
        
        questionNumber = 0
        
        nextInspectionItem()
    }
    
    func updateUI(sectionLabel: String, itemLabel: String) {
        let windowWidth = view.frame.size.width
        let numTotalItems = CGFloat(checklistitemPrestartArray.count) + CGFloat(checklistitemPoststartArray.count)
        let piece = CGFloat(CGFloat(windowWidth) / CGFloat(numTotalItems))
        let totalWidth = CGFloat(CGFloat(piece) * CGFloat(questionNumber))
        
        takePicture1Button.setImage(UIImage(named: "icons8-camera-unselected"), for: [])
        takePicture2Button.setImage(UIImage(named: "icons8-camera-unselected"), for: [])

        currentSectionLabel.text = sectionLabel
        currentInspectionItemLabel.text = itemLabel
        currentInspectionItemBadNote.text = ""
        takePicture1Button.isEnabled = true
        takePicture2Button.isEnabled = false
        
        progressBar.frame.size.width = totalWidth
        progressLabel.text = "\(Int(questionNumber)) / \(Int(numTotalItems))"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.inspectionGoodButton.setImage(UIImage(named: "icons8-ok-unselected"), for: [])
            self.inspectionBadButton.setImage(UIImage(named: "icons8-cancel-unselected"), for: [])
        }
    }
    
}
