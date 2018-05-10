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

class InspectionEntryController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ChangeEquipmentUnitDelegate {

    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
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
    
    // Constants
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_CHECKLIST = "/api/checklist"
    var API_CHECKLISTITEM = "/api/checklistitem"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    @IBOutlet weak var barcodeScannedLabel: UILabel!
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
        
        
        if barCodeValue != "" {
            equipmentTypeSelected = "2"
            equipmentUnit = barCodeValue
        
//        print("BAR CODE SCANNED?: \(barCodeScanned)")
//        print("BAR CODE NUMBER: \(barCodeValue)")
        
            barcodeScannedLabel.text = "Equipment Unit: \(equipmentUnit)"
        }
        
        loadItems()
        
//        print(dataFilePath)
        
        nextInspectionItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userScannedANewBarcode(equipmentUnit: "")
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
        var URL = "\(API_DEV_BASE_URL)\(API_CHECKLIST)"
        URL.append("?api_key=\(API_KEY)")
        
        print("Connecting to \(URL)")
        
        Alamofire.request("https://test.rinconmountaintech.com/sites/komatsuna/index.php/api/checklist?api_key=2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let responseJSON : JSON = JSON(response.result.value!) {
                if responseJSON["status"] == true {
                    let checklists = responseJSON["checklists"]
//
                    print("CHECKLIST CHECK")
                    print(checklists)
//                    let userId = userData["user_id"].int32!
//                    let userName = userData["username"].string!
//                    let firstName = userData["first_name"].string!
//                    let lastName = userData["last_name"].string!
//                    let emailAddress = userData["email_address"].string!
//                    let role = userData["role"].string!
                    
//                    _ = LoginCoreDataHandler.saveObject(userId: userId, userName: userName, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role)
                } else {
                    let errorMessage = responseJSON["message"].string!
//
                    print(errorMessage)
                }
            }
            
        }
        
//        _ = ChecklistCoreDataHandler.saveObject(id: 2, equipmenttype_id: 8, checklist_json: "{\"preStartData\":[\"42\",\"38\",\"30\",\"33\",\"47\",\"29\",\"39\",\"31\",\"44\",\"35\",\"37\"],\"postStartData\":[\"50\",\"46\",\"40\",\"41\",\"48\",\"49\"]}")
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
//        if (checklistitem != nil) {
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
//        }
    }
    
    func appendFormData(rating: String) {
        let numChecklistItems = Int(checklistitemPrestartArray.count) + Int(checklistitemPoststartArray.count)
        var counter = questionNumber
        
        var saveId : String = "";
        var saveRating : String = "";
        var saveNote : String = "";
        let equipmentUnitId : String = equipmentUnit
        let inspectionId : Int32 = 100
        
        if questionNumber <= checklistitemPrestartArray.count-1 {
            counter = questionNumber
            let prevchecklistitem: [String : String] = checklistitemPrestartArray[counter]
            
            for(key, value) in prevchecklistitem {
                if(key=="id") {
                    saveId = value
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
            }
            
            currentSection = "postStart"
        }
        
        saveNote = currentInspectionItemBadNote.text!
        saveRating = rating
        
        _ = InspectionRatingCoreDataHandler.saveObject(inspectionId: Int32(inspectionId), checklistId: Int32(saveId)!, equipmentUnitId: equipmentUnitId, rating: Int32(saveRating)!, note:saveNote)
        
        if picture1.image != nil {
            let image1Data = UIImagePNGRepresentation(picture1.image!)
            _ = InspectionImageCoreDataHandler.saveObject(inspectionId: inspectionId, photoId: 1, image: image1Data! as NSData)
        }
        
        if picture2.image != nil {
            let image2Data = UIImagePNGRepresentation(picture2.image!)
            _ = InspectionImageCoreDataHandler.saveObject(inspectionId: inspectionId, photoId: 2, image: image2Data! as NSData)
        }
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
//            saveInspectionLocally()
            
            let alert = UIAlertController(title: "Inspection Complete", message: "Return to Main Menu", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
                self.startOver()
                
                print("Q 1")
                
                self.userScannedANewBarcode(equipmentUnit: "")
                
                self.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveInspectionLocally() {
        print("----")
        print(userFormData)
        for (_, item) in userFormData.enumerated() {
            let checklistId = item["checklistId"]
            let equipmentUnitId = equipmentUnit
            let thisItem = item["item"]
            let rating = item["rating"]
            let note = item["note"]
            
//            print("\(id)")
//            print("\(equipmentUnitId)")
//            print("\(thisItem)")
//            print("\(rating)")
//            print("\(note)")
//            print("=========")
//
//            _ = InspectionRatingCoreDataHandler.saveObject(checklistId: Int32(checklistId!)!, equipmentUnitId: equipmentUnitId, item: thisItem!, rating: Int32(rating!)!, note: note!)
        }
        
//        for (_, item) in imagesTaken.enumerated() {
//            let inspectionId = item["inspectionId"]
//            let photoId = item["photoId"]
//            let image = item["image"]
        
//            print(inspectionId)
//            print(photoId)
//            print(image)
            
//            _ = InspectionImageCoreDataHandler.saveObject(inspectionId: inspectionId as! Int32, photoId: photoId as! Int32, image: image as! UIImage)
//        }
        
//        let imageDict = ["inspectionId": "\(inspectionID)", "photoId": "\(photoId)", "image": image] as [String : Any]
//
//        imagesTaken.append(imageDict)
        
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
        barCodeScanned = false
        barCodeValue = ""
        
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
        
//        progressBar.frame.size.width = totalWidth
        progressLabel.text = "\(Int(questionNumber)) / \(Int(numTotalItems))"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.inspectionGoodButton.setImage(UIImage(named: "icons8-ok-unselected"), for: [])
            self.inspectionBadButton.setImage(UIImage(named: "icons8-cancel-unselected"), for: [])
        }
    }
    
    func userScannedANewBarcode(equipmentUnit: String) {
        if equipmentUnit != "" {
            barCodeScanned = true
            barCodeValue = equipmentUnit
        }
    }
    
    //Write the PrepareForSegue Method here
    // STEP 4: Set the second VC's delegate as the current VC, meaning this VC will receive the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToInspectionEntry" {
            //2 If we have a delegate set, call the method userEnteredANewCityName
            // delegate?  means if delegate is set then
            // called Optional Chaining
//                        delegate?.userScannedANewBarcode(equipmentUnit: "")
            
            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
            //            self.dismiss(animated: true, completion: nil)
            
            let destinationVC = segue.destination as! InspectionEntryController
            
            destinationVC.delegate = self
        }
        
    }
    
}
