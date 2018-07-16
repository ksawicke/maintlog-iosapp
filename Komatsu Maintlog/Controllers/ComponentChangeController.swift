//
//  ComponentChangeController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 7/2/18.
//  Copyright © 2018 Kevin Sawicke. All rights reserved.
//

import UIKit
import SwiftyJSON

class ComponentChangeController: UIViewController, InitialSelectionDelegate {

    var initialSelectionDelegate : InitialSelectionDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var dateEntered : String = ""
    var enteredBy : String = ""
    var servicedBy : String = ""
    var subflow : String = ""
    
    var pickerViewComponentType = UIPickerView()
    
    var componentTypePickerData = ["Select one:", "Engine", "Final Drive", "Suspension", "Software", "Tires", "Windshield", "Brakes", "Cab", "Hydraulics", "Steering", "Electrical", "Motor Grader Cutting Edges"]
    var componentTypeOutputData = ["", "sus", "flu", "pss", "ccs"]
    
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var componentChangeComponentType: UITextField!
    @IBOutlet weak var componentChangeComponent: UITextField!
    @IBOutlet weak var componentChangeComponentData: UITextField!
    @IBOutlet weak var componentChangeNotes: UITextField!
    @IBOutlet weak var componentChangePreviousSMR: UITextField!
    @IBOutlet weak var componentChangeCurrentSMR: UITextField!
    
    @IBAction func onCloseComponentChangeEntryViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickSubmitComponentChange(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let jsonData: JSON = [
            "date_entered": dateEntered,
            "entered_by": enteredBy,
            "unit_number": barCodeValue,
            "serviced_by": servicedBy,
            
            "subflow": "ccs",
            "ccs_component_type": componentChangeComponentType,
            "ccs_component": componentChangeComponent,
            "ccs_component_data": componentChangeComponentData,
            "ccs_notes": componentChangeNotes,
            "ccs_previous_smr": componentChangePreviousSMR,
            "ccs_current_smr": componentChangeCurrentSMR
        ]
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")
        
        print("Save Component Change test...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("barCodeValue: \(barCodeValue)")
        print("dateEntered: \(dateEntered)")
        print("enteredBy: \(enteredBy)")
        print("servicedBy: \(servicedBy)")
        print("subflow: \(subflow)")
        
        unitNumber.text = barCodeValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSelectedSubflow(unitNumber: String) {
        //
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 0:
            return componentTypePickerData.count
            
        default:
            return componentTypePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return componentTypePickerData[row]

        default:
            return componentTypePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView tag \(pickerView.tag)")
        switch(pickerView.tag) {
        case 0:
            componentChangeComponentType.text = componentTypePickerData[row]
            componentChangeComponentType.resignFirstResponder()
 
        default:
            componentChangeComponentType.text = componentTypePickerData[row]
            componentChangeComponentType.resignFirstResponder()
        }
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
