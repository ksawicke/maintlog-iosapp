//
//  ComponentChangeController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 7/2/18.
//  Copyright © 2018 Kevin Sawicke. All rights reserved.
//

import UIKit
import SwiftyJSON

class ComponentChangeController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, InitialSelectionDelegate {

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
    var componentChangeComponentTypeSelected : Int16 = 0
    var componentChangeComponentSelected : Int16 = 0
    
    var pickerViewComponentType = UIPickerView()
    var pickerViewComponent = UIPickerView()
    
    var componentTypePickerData = [String]()
    var componentTypeOutputData = [Int16]()
    
    var componentPickerData = [String]()
    var componentOutputData = [Int16]()
    
    var pickerView = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
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
            "entered_by": enteredByInt,
            "unit_number": equipmentUnitIdSelected,
            "serviced_by": servicedByInt,

            "subflow": "ccs",
            "ccs_component_type": componentChangeComponentTypeSelected,
            "ccs_component": componentChangeComponentSelected,
            "ccs_component_data": componentChangeComponentData.text!,
            "ccs_notes": componentChangeNotes.text!,
            "ccs_previous_smr": componentChangePreviousSMR.text!,
            "ccs_current_smr": componentChangeCurrentSMR.text!
        ]
        
        print("JSON DATA - Component Change")
        debugPrint(jsonData)
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")
        
        if let selectScreenController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectScreenController") as? SelectScreenController {
            
            self.present(selectScreenController, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("barCodeValue: \(barCodeValue)")
        print("dateEntered: \(dateEntered)")
        print("enteredBy: \(enteredBy)")
        print("servicedBy: \(servicedBy)")
        print("subflow: \(subflow)")
        
        pickerViewComponentType.delegate = self
        self.pickerViewComponentType.tag = 0
        
        pickerViewComponent.delegate = self
        self.pickerViewComponent.tag = 1
        
        appendComponentTypes()
        appendComponents()
        
        componentChangeComponentType.inputView = pickerViewComponentType
        componentChangeComponent.inputView = pickerViewComponent
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ComponentChangeController.viewTapped(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(ComponentChangeController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ComponentChangeController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ComponentChangeController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        unitNumber.text = barCodeValue
    }
    
    @objc func defaultsChanged(){
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSelectedSubflow(unitNumber: String) {
        //
    }
    
    func appendComponentTypes() {
        let componenttypes = ComponentTypeCoreDataHandler.fetchObject()
        
        componentTypePickerData.append("Select one:")
        componentTypeOutputData.append(0)
        
        for componenttype in componenttypes! {
            let componentType = componenttype.value(forKey: "componentType") as! String
            let id = componenttype.value(forKey: "id") as! Int16

            print("\(id), \(componentType)")

            componentTypePickerData.append("\(componentType)")
            componentTypeOutputData.append(id)
        }
    }
    
    func appendComponents() {
        let components = ComponentCoreDataHandler.fetchObject()
        
        componentPickerData.append("Select one:")
        componentOutputData.append(0)
        
        for component in components! {
            let componentitem = component.value(forKey: "component") as! String
            let id = component.value(forKey: "id") as! Int16
            
            print("\(id), \(componentitem)")
            
            componentPickerData.append("\(componentitem)")
            componentOutputData.append(id)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("viewTapped.....")
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 0:
            return componentTypePickerData.count
            
        case 1:
            return componentPickerData.count
            
        default:
            return componentTypePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return componentTypePickerData[row]
            
        case 1:
            return componentPickerData[row]

        default:
            return componentTypePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView tag \(pickerView.tag)")
        switch(pickerView.tag) {
        case 0:
            componentChangeComponentTypeSelected = componentTypeOutputData[row]
            componentChangeComponentType.text = componentTypePickerData[row]
            componentChangeComponentType.resignFirstResponder()
 
        case 1:
            componentChangeComponentSelected = componentOutputData[row]
            componentChangeComponent.text = componentPickerData[row]
            componentChangeComponent.resignFirstResponder()
            
        default:
            componentChangeComponentTypeSelected = componentTypeOutputData[row]
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
