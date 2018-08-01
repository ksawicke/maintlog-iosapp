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
    var fluidsTracked : String = ""
    
    var pickerViewFluidType1 = UIPickerView()
    
    var fluidType1PickerData = [String]()
    var fluidType1OutputData = [Int16]()
    
    var pickerView = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var fluidEntryFluidType1: UITextField!
    @IBOutlet weak var fluidEntryFluidQuantity1: UITextField!
    @IBOutlet weak var fluidEntryPreviousSMR: UITextField!
    @IBOutlet weak var fluidEntryCurrentSMR: UITextField!
    @IBOutlet weak var fluidEntryNotes: UITextField!
    
    @IBAction func onCloseFluidEntryViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    
    @IBAction func onClickSubmitFluidEntry(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let jsonData: JSON = [
            "uuid": uuid,
            "date_entered": dateEntered,
            "entered_by": enteredByInt,
            "unit_number": equipmentUnitIdSelected,
            "serviced_by": servicedByInt,
            "subflow": "flu",
            
            // 07/25/18 Need to change to actual values entered
            "fluid_added": [
                [ "type": fluidType1SelectedInt,
                  "quantity": fluidEntryFluidQuantity1.text!,
                  "units": "gal" ],
//                [ "type": 3,
//                  "quantity": 3.2,
//                  "units": "gal" ],
            ],
            "flu_previous_smr": fluidEntryPreviousSMR.text!,
            "flu_current_smr": fluidEntryCurrentSMR.text!,
            "flu_notes": fluidEntryNotes.text!
        ]
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")

        if let selectScreenController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectScreenController") as? SelectScreenController {

            self.present(selectScreenController, animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("barCodeValue: \(barCodeValue)")
        print("dateEntered: \(dateEntered)")
        print("enteredBy: \(enteredBy)")
        print("servicedBy: \(servicedBy)")
        print("subflow: \(subflow)")
        
        pickerViewFluidType1.delegate = self
        self.pickerViewFluidType1.tag = 0
        
        fluidEntryFluidType1.inputView = pickerViewFluidType1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FluidEntryController.viewTapped(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FluidEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        unitNumber.text = barCodeValue
        
        appendFluidTypes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSelectedSubflow(unitNumber: String) {
        //
    }
    
    func appendFluidTypes() {
        let fluids = FluidTypeCoreDataHandler.fetchObject()
        
        let fluidsTrackedArray = fluidsTracked.components(separatedBy: "|")
        
        debugPrint(fluidsTrackedArray)
        
        fluidType1PickerData.append("Select one:")
        fluidType1OutputData.append(0)
        
        for fluid in fluids! {
            let fluidType = fluid.value(forKey: "fluidType") as! String
            let id = fluid.value(forKey: "id") as! Int16

            print("\(id), \(fluidType)")

            // Append only if the fluids are tracked for the
            // scanned Equipment Unit
            if fluidsTrackedArray.contains("\(id)") {
                fluidType1PickerData.append("\(fluidType)")
                fluidType1OutputData.append(id)
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
            
        default:
            return fluidType1PickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return fluidType1PickerData[row]
            
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
        
        print("hide keyboard?")
        
        //        nextButton.isHidden = false
        
        return true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboard() {
        print("run hide keyboard")
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
