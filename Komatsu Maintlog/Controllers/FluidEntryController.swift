//
//  FluidEntryController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/29/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class FluidEntryController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, InitialSelectionDelegate {

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
    var enteredByInt : Int16 = 0
    var servicedByInt : Int16 = 0
    var subflow : String = ""
    var fluidType1SelectedInt : Int16 = 0
    var fluidType2SelectedInt : Int16 = 0
    var fluidType3SelectedInt : Int16 = 0
    var fluidsTracked : String = ""
    
    var pickerViewFluidType1 = UIPickerView()
    var pickerViewFluidType2 = UIPickerView()
    var pickerViewFluidType3 = UIPickerView()
    
    var fluidType1PickerData = [String]()
    var fluidType1OutputData = [Int16]()
    var fluidType2PickerData = [String]()
    var fluidType2OutputData = [Int16]()
    var fluidType3PickerData = [String]()
    var fluidType3OutputData = [Int16]()
    
    var pickerView = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var fluidEntryFluidType1: UITextField!
    @IBOutlet weak var fluidEntryFluidQuantity1: UITextField!
    @IBOutlet weak var fluidEntryFluidType2: UITextField!
    @IBOutlet weak var fluidEntryFluidQuantity2: UITextField!
    @IBOutlet weak var fluidEntryFluidType3: UITextField!
    @IBOutlet weak var fluidEntryFluidQuantity3: UITextField!
    @IBOutlet weak var fluidEntryPreviousSMR: UITextField!
    @IBOutlet weak var fluidEntryCurrentSMR: UITextField!
    @IBOutlet weak var fluidEntryNotes: UITextField!
    
    @IBAction func onCloseFluidEntryViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickSubmitFluidEntry(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let dateEnteredYMD = DateFormatHelper().getMySQLDateFormat(dateString: dateEntered)! as String
        let jsonData: JSON = [
            "uuid": uuid,
            "date_entered": dateEnteredYMD,
            "entered_by": enteredByInt,
            "unit_number": equipmentUnitIdSelected,
            "serviced_by": servicedByInt,
            "subflow": "flu",
            
            "fluid_added": [
                [ "type": fluidType1SelectedInt,
                  "quantity": fluidEntryFluidQuantity1.text!,
                  "units": "gal" ],
                [ "type": fluidType2SelectedInt,
                  "quantity": fluidEntryFluidQuantity2.text!,
                  "units": "gal"
                ],
                [ "type": fluidType3SelectedInt,
                  "quantity": fluidEntryFluidQuantity3.text!,
                  "units": "gal"
                ]
            ],
            
            "flu_previous_smr": "",
            "flu_current_smr": fluidEntryCurrentSMR.text!,
            "flu_notes": fluidEntryNotes.text!
        ]
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")

        if let selectScreenController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectScreenController") as? SelectScreenController {

            self.present(selectScreenController, animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerViewFluidType1.delegate = self
        pickerViewFluidType1.tag = 0
        pickerViewFluidType2.delegate = self
        pickerViewFluidType2.tag = 1
        pickerViewFluidType3.delegate = self
        pickerViewFluidType3.tag = 2

        fluidEntryFluidType1.inputView = pickerViewFluidType1
        fluidEntryFluidType2.inputView = pickerViewFluidType2
        fluidEntryFluidType3.inputView = pickerViewFluidType3
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FluidEntryController.viewTapped(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        unitNumber.text = barCodeValue
        
        appendFluidTypes()
        fluidEntryPreviousSMR.text = "Unable to load data"
        getPreviousSMR()
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
        
        fluidEntryPreviousSMR.text = "\(String(describing: previousSMR!))"
    }
    
    func userSelectedSubflow(unitNumber: String) {
        //
    }
    
    func appendFluidTypes() {
        let fluids = FluidTypeCoreDataHandler.fetchObject()
        let fluidsTrackedArray = fluidsTracked.components(separatedBy: "|")
        
        fluidType1PickerData.append("Select one:")
        fluidType1OutputData.append(0)
        fluidType2PickerData.append("Select one:")
        fluidType2OutputData.append(0)
        fluidType3PickerData.append("Select one:")
        fluidType3OutputData.append(0)
        
        for fluid in fluids! {
            let fluidType = fluid.value(forKey: "fluidType") as! String
            let id = fluid.value(forKey: "id") as! Int16

            // Append only if the fluids are tracked for the
            // scanned Equipment Unit.
            if fluidsTrackedArray.contains("\(id)") {
                fluidType1PickerData.append("\(fluidType)")
                fluidType1OutputData.append(id)
                fluidType2PickerData.append("\(fluidType)")
                fluidType2OutputData.append(id)
                fluidType3PickerData.append("\(fluidType)")
                fluidType3OutputData.append(id)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 0:
            return fluidType1PickerData.count
            
        case 1:
            return fluidType2PickerData.count
            
        case 2:
            return fluidType3PickerData.count
            
        default:
            return fluidType1PickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return fluidType1PickerData[row]
            
        case 1:
            return fluidType2PickerData[row]
            
        case 2:
            return fluidType3PickerData[row]
            
        default:
            return fluidType1PickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView tag \(pickerView.tag)")
        switch(pickerView.tag) {
        case 0:
            fluidType1SelectedInt = fluidType1OutputData[row]
            fluidEntryFluidType1.text = fluidType1PickerData[row]
            fluidEntryFluidType1.resignFirstResponder()
           
        case 1:
            fluidType2SelectedInt = fluidType2OutputData[row]
            fluidEntryFluidType2.text = fluidType2PickerData[row]
            fluidEntryFluidType2.resignFirstResponder()
            
        case 2:
            fluidType3SelectedInt = fluidType3OutputData[row]
            fluidEntryFluidType3.text = fluidType3PickerData[row]
            fluidEntryFluidType3.resignFirstResponder()
            
        default:
            fluidType1SelectedInt = fluidType1OutputData[row]
            fluidEntryFluidType1.text = fluidType1PickerData[row]
            fluidEntryFluidType1.resignFirstResponder()
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("viewTapped.....")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "M/dd/yyyy"
//        dateEntered.text = dateFormatter.string(from: (datePicker?.date)!)
        view.endEditing(true)
    }
    
    @objc func defaultsChanged(){
        //        if UserDefaults.standard.bool(forKey: "RedThemeKey") {
        //            self.view.backgroundColor = UIColor.red
        
        //        }
        //        else {
        //            self.view.backgroundColor = UIColor.green
        //        }
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        print("dateChanged.....")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        dateEntered.text = dateFormatter.string(from: (datePicker.date))
        view.endEditing(true)
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        // custom actions here
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        
//        print("hide keyboard?")
        
        //        nextButton.isHidden = false
        
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
