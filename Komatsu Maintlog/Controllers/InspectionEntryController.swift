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
    var inspectionId : String = ""
    var equipmentTypeSelected : Int16 = 0
    var equipmentUnitIdSelected : Int16 = 0
    var questionNumber : Int = 0
    var equipmentUnit : String = ""
    var currentSection : String = ""
    var checklistitem:[ChecklistItem]? = nil
    var imagePickerController : UIImagePickerController!
    var progressLabelText : String = ""
    
    // Constants
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_PROD_BASE_URL = "http://10.132.146.48/maintlog/index.php"
    var API_CHECKLIST = "/api/checklist"
    var API_CHECKLISTITEM = "/api/checklistitem"
    var API_EQUIPMENTTYPE = "/api/equipmenttype"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    @IBOutlet weak var barcodeScannedLabel: UILabel!
    @IBOutlet weak var equipmentUnitLabel: UILabel!
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
        print(equipmentUnitIdSelected)
        
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
        
        print("BAR CODE VALUE: \(barCodeValue)")
        
        currentInspectionItemBadNote.delegate = self
        
        currentInspectionItemBadNote.setLeftPaddingPoints(10)
        currentInspectionItemBadNote.setRightPaddingPoints(10)
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        print("BAR CODE VALUE: \(barCodeValue)")
        
        if barCodeValue != "" {
            // Try matching scanned barcode to equipment loaded into app
            let equipmentUnitScanned = EquipmentUnitCoreDataHandler.filterData(fieldName: "unitNumber", filterType: "equals", queryString: barCodeValue)
            
//            print(equipmentUnitScanned!)
            
            for managedObject in equipmentUnitScanned! {
                if let scannedManufacturerName = managedObject.value(forKey: "manufacturerName"),
                   let scannedModelNumber = managedObject.value(forKey: "modelNumber"),
                   let scannedEquipmentTypeId = managedObject.value(forKey: "equipmentTypeId"),
                    let scannedEquipmentUnitId = managedObject.value(forKey: "id") {
                    
                    equipmentTypeSelected = scannedEquipmentTypeId as! Int16
                    equipmentUnitIdSelected = scannedEquipmentUnitId as! Int16
                    let modelNumber = scannedModelNumber as! String
                    let etid = scannedEquipmentTypeId as! Int16
                    
                    print("equipmentTypeSelected: \(equipmentTypeSelected)")
                    print("modelNumber: \(modelNumber)")
                    print("etid: \(etid)")
                    print("barCodeValue: \(barCodeValue)")
                    
                    barcodeScannedLabel.text = "\(barCodeValue)"
                    equipmentUnitLabel.text = "\(scannedManufacturerName) \(scannedModelNumber)"
                    inspectionId = UUID().uuidString
                }
            }
        } else {
            print("HMM?")
        }
        
        equipmentUnit = barCodeValue
        inspectionId = UUID().uuidString
        
        loadItems()
        
        nextInspectionItem()
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(InspectionEntryController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userScannedANewBarcode(unitNumber: "")
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        
        // Stop listening for keyboard hide/show events
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard() {
        currentInspectionItemBadNote.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
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
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    @objc func defaultsChanged(){
//        if UserDefaults.standard.bool(forKey: "RedThemeKey") {
//            self.view.backgroundColor = UIColor.red
            
//        }
//        else {
//            self.view.backgroundColor = UIColor.green
//        }
    }
    
    func loadItems() {
        let checklist = ChecklistCoreDataHandler.filterDataByEquipmentTypeId(equipmentTypeId: equipmentTypeSelected)
        
        if (checklist != nil) {
            for j in checklist! {
                let id = j.id
                let checklistJson = j.checklistJson!
                
//                // https://www.swiftyninja.com/escaped-string-json-using-swift/
//                // https://stackoverflow.com/questions/25678373/swift-split-a-string-into-an-array
//                // https://stackoverflow.com/questions/36594179/remove-all-non-numeric-characters-from-a-string-in-swift
                let jsonData = checklistJson.data(using: .utf8)
//
                var dic: [String : Any]?
                do {
                    dic = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String : Any]

                    let preStartData = ("\(dic!["preStartData"]!)")
                    let postStartData = ("\(dic!["postStartData"]!)")

                    let preStartDataArr = (preStartData as AnyObject).components(separatedBy: ",")
                    let postStartDataArr = (postStartData as AnyObject).components(separatedBy: ",")
                    let unsafeChars = CharacterSet.alphanumerics.inverted  // Remove the .inverted to get the opposite result.

                    for index in 0...preStartDataArr.count-1 {
                        let checklistItemId: String = preStartDataArr[index].components(separatedBy: unsafeChars).joined(separator: "")
                        let checklistitem = ChecklistItemCoreDataHandler.filterDataById(id: checklistItemId)

                        appendToChecklistItemArray(id: checklistItemId, checklistitem: checklistitem!, appendTo: "preStart")
                    }

                    for index in 0...postStartDataArr.count-1 {
                        let checklistItemId: String = postStartDataArr[index].components(separatedBy: unsafeChars).joined(separator: "")
                        let checklistitem = ChecklistItemCoreDataHandler.filterDataById(id: checklistItemId)

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
        
        var saveId : String = ""
        var saveRating : String = ""
        var saveNote : String = ""
//        let equipmentUnitId : Int16 = equipmentUnitIdSelected
        
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
        
//        print("inspectionId: \(inspectionId)")
////        print(Int16(saveId)!)
//        print("equipmentUnitIdSelected: \(equipmentUnitIdSelected)")
//        print("saveRating: \(saveRating)")
//        print("note: \(saveNote)")
        
        _ = InspectionRatingCoreDataHandler.saveObject(inspectionId: inspectionId, equipmentUnitId: equipmentUnitIdSelected, checklistItemId: Int16(saveId)!, rating: Int16(saveRating)!, note: saveNote)
        
        // Saving the image as Binary Data to the Entity.
        // Using UIImagePNGRepresentation as primary method.
        // TODO: Condider using UIImageJPEGRepresentation as an alternate or fallback method.
        
        if picture1.image != nil {
            let image1Data = UIImagePNGRepresentation(picture1.image!)
            _ = InspectionImageCoreDataHandler.saveObject(inspectionId: inspectionId, photoId: 1, image: image1Data! as NSData, type: "png")
        }
        
        if picture2.image != nil {
            let image2Data = UIImagePNGRepresentation(picture2.image!)
            _ = InspectionImageCoreDataHandler.saveObject(inspectionId: inspectionId, photoId: 2, image: image2Data! as NSData, type: "png")
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
            
            let alert = UIAlertController(title: "Inspection Complete", message: "Return to Main Menu", preferredStyle: .alert)
            
            let restartAction = UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
                self.startOver()
                
                self.userScannedANewBarcode(unitNumber: "")
                
                self.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func startOver() {
//        loadItems()
        
        questionNumber = 0
        barCodeScanned = false
        barCodeValue = ""
        inspectionId = ""
        equipmentUnitIdSelected = 0
        
        nextInspectionItem()
    }
    
    func updateUI(sectionLabel: String, itemLabel: String) {
        let numTotalItems = Int16(checklistitemPrestartArray.count) + Int16(checklistitemPoststartArray.count)
        let newProgressBarWidth = (view.frame.size.width / 17) * CGFloat(questionNumber)
        
        takePicture1Button.setImage(UIImage(named: "icons8-camera-unselected"), for: [])
        takePicture2Button.setImage(UIImage(named: "icons8-camera-unselected"), for: [])

        currentSectionLabel.text = sectionLabel
        currentInspectionItemLabel.text = itemLabel
        currentInspectionItemBadNote.text = ""
        takePicture1Button.isEnabled = true
        takePicture2Button.isEnabled = false
        
        progressLabel.text = "Completed: \(Int(questionNumber)) / \(Int(numTotalItems))"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressBar.frame.size.width = newProgressBarWidth // Keep this call within closure; must be here due to threading
            self.inspectionGoodButton.setImage(UIImage(named: "icons8-ok-unselected"), for: [])
            self.inspectionBadButton.setImage(UIImage(named: "icons8-cancel-unselected"), for: [])
        }
    }
    
    func userScannedANewBarcode(unitNumber: String) {
        if unitNumber != "" {
            barCodeScanned = true
            barCodeValue = unitNumber
            // equipmentUnitIdSelected
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
