//
//  PMServiceController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/29/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PMServiceController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, InitialSelectionDelegate {

    var initialSelectionDelegate : InitialSelectionDelegate?
    
    // Constants
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_PROD_BASE_URL = "http://10.132.146.48/maintlog/index.php"
    var API_SMR = "/api/last_smr"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var equipmentUnitIdSelected : Int16 = 0
    var dateEntered : String = ""
    var enteredBy : String = ""
    var servicedBy : String = ""
    var subflow : String = ""
    var pmTypeSelected : String = ""
    var pmLevelSelected : String = ""
    var pmServiceReminderPMTypeSelected : String = ""
    var pmServiceReminderPMLevelSelected : String = ""
    var pmServiceReminderDueUnitsSelected : String = ""
    
    var pickerViewPmType = UIPickerView()
    var pickerViewPmLevel = UIPickerView()
    var pickerViewPmServiceReminderPMType = UIPickerView()
    var pickerViewPmServiceReminderPMLevel = UIPickerView()
    var pickerViewPmServiceReminderDueUnits = UIPickerView()
    
    var pmTypePickerData = [String]()
    var pmTypeOutputData = [String]()
    
    var pmLevelPickerData = [String]()
    var pmLevelOutputData = [String]()
    
    var pmServiceReminderPMTypePickerData = [String]()
    var pmServiceReminderPMTypeOutputData = [String]()
    
    var pmServiceReminderPMLevelPickerData = [String]()
    var pmServiceReminderPMLevelOutputData = [String]()
    
    var pmServiceReminderDueUnitsPickerData = [String]()
    var pmServiceReminderDueUnitsOutputData = [String]()
    
    var pickerView = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var pmServicePmType: UITextField!
    @IBOutlet weak var pmServicePMLevel: UITextField!
    @IBOutlet weak var pmServicePreviousSMR: UITextField!
    @IBOutlet weak var pmServiceCurrentSMR: UITextField!
    @IBOutlet weak var pmServiceNotes: UITextField!
    @IBOutlet weak var pmServiceNotes2: UITextField!
    @IBOutlet weak var pmServiceNotes3: UITextField!
    @IBOutlet weak var pmServiceReminderPMType: UITextField!
    @IBOutlet weak var pmServiceReminderPMLevel: UITextField!
    @IBOutlet weak var pmServiceReminderDue: UITextField!
    @IBOutlet weak var pmServiceReminderNotes: UITextField!
    @IBOutlet weak var pmServiceReminderDueQuantity: UITextField!
    @IBOutlet weak var pmServiceReminderDueUnits: UITextField!
    
    @IBAction func onClosePMServiceViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
     let pmTypes : [Int:[String:String]] = [
         0: ["value": "SMR based", "key": "smr_based"],
         1: ["value": "Mileage based", "key": "mileage_based"],
         2: ["value": "Time based", "key": "time_based"]
     ]
    
    let pmLevelsSmrBased : [Int:[String:String]] = [
        0: ["value": "250", "key": "250"],
        1: ["value": "500", "key": "500"],
        2: ["value": "1000", "key": "1000"],
        3: ["value": "1500", "key": "1500"],
        4: ["value": "2000", "key": "2000"]
    ]
    
    let pmLevelsMileageBased : [Int:[String:String]] = [
        0: ["value": "1000", "key": "1000"],
        1: ["value": "2000", "key": "2000"],
        2: ["value": "3000", "key": "3000"],
        3: ["value": "4000", "key": "4000"],
        4: ["value": "5000", "key": "5000"]
    ]
    
    let pmLevelsTimeBased : [Int:[String:String]] = [
        0: ["value": "0.2", "key": "0.2"],
        1: ["value": "1.3", "key": "1.3"],
        2: ["value": "3", "key": "3"],
        3: ["value": "6", "key": "6"],
        4: ["value": "10", "key": "10"],
        5: ["value": "15", "key": "15"],
        6: ["value": "30", "key": "30"]
    ]
    
    let dueUnits : [Int:[String:String]] = [
        0: ["value": "SMR", "key": "smr"],
        1: ["value": "Miles", "key": "miles"],
        2: ["value": "Days", "key": "days"]
    ]
    
    @IBAction func onClickSubmitPMService(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let jsonData: JSON = [
            "uuid": uuid,
            "date_entered": "2018-01-01 12:00:01",
            "entered_by": "21",
            "unit_number": equipmentUnitIdSelected,
            "serviced_by": "1",
            
            "subflow": "pss",
            "pss_pm_type": "",
            "pss_smr_based_pm_level": "",
            "pss_smr_based_previous_smr": "",
            "pss_smr_based_current_smr": "",
            "pss_due_units": "",
            "pss_notes": "",
            "pss_smr_based_notes": [
                [ "note": "" ],
                [ "note": "" ],
                [ "note": "" ]
            ],
            "pss_reminder_recipients": [
                [ "email_addresses": "" ]
            ]
        ]
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")
        
        print("Save PM Service test...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print("barCodeValue: \(barCodeValue)")
//        print("dateEntered: \(dateEntered)")
//        print("enteredBy: \(enteredBy)")
//        print("servicedBy: \(servicedBy)")
//        print("subflow: \(subflow)")
        
        pickerViewPmType.delegate = self
        pickerViewPmType.tag = 0
        
        pickerViewPmLevel.delegate = self
        pickerViewPmLevel.tag = 1
        
        pickerViewPmServiceReminderPMType.delegate = self
        pickerViewPmServiceReminderPMType.tag = 2
        
        pickerViewPmServiceReminderPMLevel.delegate = self
        pickerViewPmServiceReminderPMLevel.tag = 3
        
        pickerViewPmServiceReminderDueUnits.delegate = self
        pickerViewPmServiceReminderDueUnits.tag = 4
        
        appendPmTypes()
        appendPmLevels()
        appendPmServiceReminderPmTypes()
        appendPmServiceReminderPmLevels()
        appendPmServiceReminderDueUnits()
        
        pmServicePmType.inputView = pickerViewPmType
        pmServicePMLevel.inputView = pickerViewPmLevel
        pmServiceReminderPMType.inputView = pickerViewPmServiceReminderPMType
        pmServiceReminderPMLevel.inputView = pickerViewPmServiceReminderPMLevel
        pmServiceReminderDueUnits.inputView = pickerViewPmServiceReminderDueUnits
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ComponentChangeController.viewTapped(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(PMServiceController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PMServiceController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PMServiceController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        unitNumber.text = barCodeValue
        pmServicePreviousSMR.text = "Unable to load data"
        getPreviousSMR()
    }

    @objc func defaultsChanged(){
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPreviousSMR() {
        var URL = "\(API_PROD_BASE_URL)\(API_SMR)"
        var previous_smr = ""
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_SMR)"
        }
        
        URL.append("/\(equipmentUnitIdSelected)?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    self.updatePreviousSMR(responseJSON: responseJSON)
                }
            }
        }
    }
    
    func updatePreviousSMR(responseJSON: JSON) {
        let previousSMR = responseJSON["previous_smr"].int16
        
        pmServicePreviousSMR.text = "\(String(describing: previousSMR!))"
    }
    
    func userSelectedSubflow(unitNumber: String) {
        //
    }
    
    func appendPmTypes() {
        pmTypePickerData.append("Select one:")
        pmTypeOutputData.append("")
        
        for pmType in pmTypes {
            let key = pmType.value["key"]
            let value = pmType.value["value"]

            pmTypePickerData.append("\(String(describing: value!))")
            pmTypeOutputData.append(key!)
        }
    }
    
    func appendPmServiceReminderPmTypes() {
        pmServiceReminderPMTypePickerData.append("Select one:")
        pmServiceReminderPMTypeOutputData.append("")
        
        for pmType in pmTypes {
            let key = pmType.value["key"]
            let value = pmType.value["value"]
            
            pmServiceReminderPMTypePickerData.append("\(String(describing: value!))")
            pmServiceReminderPMTypeOutputData.append(key!)
        }
    }
    
    func appendPmLevels() {
        pmLevelPickerData.removeAll()
        pmLevelOutputData.removeAll()
        
        pmLevelPickerData.append("Select one:")
        pmLevelOutputData.append("")
        
        switch(pmTypeSelected) {
            case "smr_based":
                for pmLevel in pmLevelsSmrBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmLevelPickerData.append("\(String(describing: value!))")
                    pmLevelOutputData.append(key!)
                }
            
            case "mileage_based":
                for pmLevel in pmLevelsMileageBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmLevelPickerData.append("\(String(describing: value!))")
                    pmLevelOutputData.append(key!)
                }
            
            case "time_based":
                for pmLevel in pmLevelsTimeBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmLevelPickerData.append("\(String(describing: value!))")
                    pmLevelOutputData.append(key!)
                }
            
            default:
                for pmLevel in pmLevelsSmrBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmLevelPickerData.append("\(String(describing: value!))")
                    pmLevelOutputData.append(key!)
                }
        }
    }
    
    func appendPmServiceReminderPmLevels() {
        pmServiceReminderPMLevelPickerData.removeAll()
        pmServiceReminderPMLevelOutputData.removeAll()
        
        pmServiceReminderPMLevelPickerData.append("Select one:")
        pmServiceReminderPMLevelOutputData.append("")
        
        switch(pmServiceReminderPMTypeSelected) {
            case "smr_based":
                for pmLevel in pmLevelsSmrBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmServiceReminderPMLevelPickerData.append("\(String(describing: value!))")
                    pmServiceReminderPMLevelOutputData.append(key!)
                }
            
            case "mileage_based":
                for pmLevel in pmLevelsMileageBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmServiceReminderPMLevelPickerData.append("\(String(describing: value!))")
                    pmServiceReminderPMLevelOutputData.append(key!)
                }
            
            case "time_based":
                for pmLevel in pmLevelsTimeBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmServiceReminderPMLevelPickerData.append("\(String(describing: value!))")
                    pmServiceReminderPMLevelOutputData.append(key!)
                }
            
            default:
                for pmLevel in pmLevelsSmrBased {
                    let key = pmLevel.value["key"]
                    let value = pmLevel.value["value"]
                    
                    pmServiceReminderPMLevelPickerData.append("\(String(describing: value!))")
                    pmServiceReminderPMLevelOutputData.append(key!)
                }
        }
    }
    
    func appendPmServiceReminderDueUnits() {
        pmServiceReminderDueUnitsPickerData.append("Select one:")
        pmServiceReminderDueUnitsOutputData.append("")
        
        for dueUnit in dueUnits {
            let key = dueUnit.value["key"]
            let value = dueUnit.value["value"]
            
            pmServiceReminderDueUnitsPickerData.append("\(String(describing: value!))")
            pmServiceReminderDueUnitsOutputData.append(key!)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
//        print("viewTapped.....")
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 0:
            return pmTypePickerData.count
            
        case 1:
            return pmLevelPickerData.count
            
        case 2:
            return pmServiceReminderPMTypePickerData.count
            
        case 3:
            return pmServiceReminderPMLevelPickerData.count
            
        case 4:
            return pmServiceReminderDueUnitsPickerData.count
            
        default:
            return pmTypePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return pmTypePickerData[row]
            
        case 1:
            return pmLevelPickerData[row]
            
        case 2:
            return pmServiceReminderPMTypePickerData[row]
            
        case 3:
            return pmServiceReminderPMLevelPickerData[row]
            
        case 4:
            return pmServiceReminderDueUnitsPickerData[row]
            
        default:
            return pmTypePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView.tag) {
        case 0:
            pmTypeSelected = pmTypeOutputData[row]
            appendPmLevels()
            pmServicePmType.text = pmTypePickerData[row]
            pmServicePmType.resignFirstResponder()
            
        case 1:
            pmLevelSelected = pmLevelOutputData[row]
            pmServicePMLevel.text = pmLevelPickerData[row]
            pmServicePMLevel.resignFirstResponder()
            
        case 2:
            pmServiceReminderPMTypeSelected = pmServiceReminderPMTypeOutputData[row]
            appendPmServiceReminderPmLevels()
            pmServiceReminderPMType.text = pmServiceReminderPMTypePickerData[row]
            pmServiceReminderPMType.resignFirstResponder()
            
        case 3:
            pmServiceReminderPMLevelSelected = pmServiceReminderPMLevelOutputData[row]
            pmServiceReminderPMLevel.text = pmServiceReminderPMLevelPickerData[row]
            pmServiceReminderPMLevel.resignFirstResponder()

        case 4:
            pmServiceReminderDueUnitsSelected = pmServiceReminderDueUnitsOutputData[row]
            pmServiceReminderDueUnits.text = pmServiceReminderDueUnitsPickerData[row]
            pmServiceReminderDueUnits.resignFirstResponder()
            
        default:
            pmTypeSelected = pmTypeOutputData[row]
            appendPmLevels()
            pmServicePmType.text = pmTypePickerData[row]
            pmServicePmType.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboard() {
//        print("run hide keyboard")
        //        currentSMR.resignFirstResponder()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }

}
