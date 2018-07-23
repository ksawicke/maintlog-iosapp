//
//  LogEntryController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit

protocol InitialSelectionDelegate {
    
    func userSelectedSubflow (unitNumber: String)
    
}

class LogEntryController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, ChangeEquipmentUnitDelegate {
    
    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    var initialSelectionDelegate : InitialSelectionDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var logEntryId : String = ""
    var equipmentTypeSelected : Int16 = 0
    var equipmentUnitIdSelected : Int16 = 0
    var equipmentUnit : String = ""
    var subflowSelected : String = ""
    var enteredByInt : Int16 = 0
    var servicedByInt : Int16 = 0
    
    var pickerViewEnteredBy = UIPickerView()
    var pickerViewServicedBy = UIPickerView()
    var pickerViewSubflow = UIPickerView()
    
    var enteredByPickerData = [String]()
    var enteredByOutputData = [Int16]()
    
    var servicedByPickerData = [String]()
    var servicedByOutputData = [Int16]()
    
    var subflowPickerData = ["Select one:", "SMR Update", "Fluid Entry", "PM Service", "Component Change"]
    var subflowOutputData = ["", "sus", "flu", "pss", "ccs"]
    
    var pickerView = UIPickerView()
    
    private var datePicker: UIDatePicker?
    
    // https://stackoverflow.com/questions/33896261/can-my-uipickerview-output-be-different-that-the-input
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateEntered: UITextField!
    @IBOutlet weak var enteredBy: UITextField!
    @IBOutlet weak var servicedBy: UITextField!
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var subflow: UITextField!
    
    @IBAction func onSelectSubflow(_ sender: Any) {
        
    }
    
    @IBAction func onClickNextLogEntry(_ sender: Any) {
        
    }
    
    @IBAction func onCloseLogEntryViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        print("clicked Next")
        print("@\(subflowSelected)@")
        if(subflowSelected == "SMR Update") {
            jumpToSMRUpdateSubflow()
        }
        if(subflowSelected == "Fluid Entry") {
            jumpToFluidEntrySubflow()
        }
        if(subflowSelected == "PM Service") {
            jumpToPMServiceSubflow()
        }
        if(subflowSelected == "Component Change") {
            jumpToComponentChangeSubflow()
        }
//        switch(subflow.tag) {
//            case 0:
//                enteredBy.text = enteredByPickerData[row]
//                enteredBy.resignFirstResponder()
//
//            case 1:
//                servicedBy.text = servicedByPickerData[row]
//                servicedBy.resignFirstResponder()
//
//            case 2:
//                subflow.text = subflowPickerData[row]
//                subflow.resignFirstResponder()
//                //                print("select subflow 2")
//                //                print("QQQQ: \(subflow.text!)")
//                if(subflow.text! == "SMR Update") {
//                    jumpToSMRUpdateSubflow()
//                }
//                if(subflow.text! == "Fluid Entry") {
//                    jumpToFluidEntrySubflow()
//                }
//                if(subflow.text! == "PM Service") {
//                    jumpToPMServiceSubflow()
//                }
//                if(subflow.text! == "Component Change") {
//                    jumpToComponentChangeSubflow()
//                }
//
//            default:
//                enteredBy.text = enteredByPickerData[row]
//                enteredBy.resignFirstResponder()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        toggleSMRUpdateFields(setTo: true)
//        toggleFluidEntryFields(setTo: true)
        
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale?
        dateFormatter.dateFormat = "M/dd/yyyy"
        let today = dateFormatter.string(from: currentDate as Date)
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        dateEntered.inputView = datePicker
        dateEntered?.addTarget(self, action: #selector(LogEntryController.dateChanged(datePicker:)), for: .valueChanged)
        dateEntered.text = today
        
        pickerViewEnteredBy.delegate = self
        pickerViewServicedBy.delegate = self
        pickerViewSubflow.delegate = self
        self.pickerViewEnteredBy.tag = 0
        self.pickerViewServicedBy.tag = 1
        self.pickerViewSubflow.tag = 2
        
        enteredBy.inputView = pickerViewEnteredBy
        servicedBy.inputView = pickerViewServicedBy
        subflow.inputView = pickerViewSubflow
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LogEntryController.viewTapped(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        
        appendUsers()
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogEntryController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
        
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
                    
//                    barcodeScannedLabel.text = "\(scannedManufacturerName) \(scannedModelNumber) - \(barCodeValue)"
                    unitNumber.text = "\(barCodeValue)"
                    logEntryId = UUID().uuidString
                }
            }
        } else {
            print("HMM?")
        }
        
        equipmentUnit = barCodeValue
        logEntryId = UUID().uuidString
        
//        loadItems()
//
//        nextInspectionItem()
        
//        registerSettingsBundle()
        
//        defaultsChanged()
    }
    
//    func setInitialFieldsHidden() {
//        // SMR Fields
//        currentSMRLabel.isHidden = true
//        currentSMR.isHidden = true
//
//        // Fluid Entry Fields
//        fluidType1Label.isHidden = true
//        fluidType1QuantityLabel.isHidden = true
//        fluidType1Quantity.isHidden = true
//
//        fluidType2Label.isHidden = true
//        fluidType2QuantityLabel.isHidden = true
//        fluidType2Quantity.isHidden = true
//
//        fluidType3Label.isHidden = true
//        fluidType3QuantityLabel.isHidden = true
//        fluidType3Quantity.isHidden = true
//
//        fluidType4Label.isHidden = true
//        fluidType4QuantityLabel.isHidden = true
//        fluidType4Quantity.isHidden = true
//
//        fluidType5Label.isHidden = true
//        fluidType5QuantityLabel.isHidden = true
//        fluidType5Quantity.isHidden = true
//
//        fluidType6Label.isHidden = true
//        fluidType6QuantityLabel.isHidden = true
//        fluidType6Quantity.isHidden = true
//
//        fluidType7Label.isHidden = true
//        fluidType7QuantityLabel.isHidden = true
//        fluidType7Quantity.isHidden = true
//
//        fluidType8Label.isHidden = true
//        fluidType8QuantityLabel.isHidden = true
//        fluidType8Quantity.isHidden = true
//
//        fluidType9Label.isHidden = true
//        fluidType9QuantityLabel.isHidden = true
//        fluidType9Quantity.isHidden = true
//
//        fluidType10Label.isHidden = true
//        fluidType10QuantityLabel.isHidden = true
//        fluidType10Quantity.isHidden = true
//
//        fluidTypeCurrentSMRLabel.isHidden = true
//        fluidTypeCurrentSMR.isHidden = true
//
//        fluidTypeNotesLabel.isHidden = true
//        fluidTypeNotes.isHidden = true
//    }
    
//    func toggleSMRUpdateFields(setTo: Bool) {
//        currentSMRLabel.isHidden = setTo
//        currentSMR.isHidden = setTo
//    }
//
//    func toggleFluidEntryFields(setTo: Bool) {
//        fluidType1Label.isHidden = setTo
//        fluidType1QuantityLabel.isHidden = setTo
//        fluidType1Quantity.isHidden = setTo
//
//        fluidType2Label.isHidden = setTo
//        fluidType2QuantityLabel.isHidden = setTo
//        fluidType2Quantity.isHidden = setTo
//
//        fluidType3Label.isHidden = setTo
//        fluidType3QuantityLabel.isHidden = setTo
//        fluidType3Quantity.isHidden = setTo
//
//        fluidType4Label.isHidden = setTo
//        fluidType4QuantityLabel.isHidden = setTo
//        fluidType4Quantity.isHidden = setTo
//
//        fluidType5Label.isHidden = setTo
//        fluidType5QuantityLabel.isHidden = setTo
//        fluidType5Quantity.isHidden = setTo
//
//        fluidType6Label.isHidden = setTo
//        fluidType6QuantityLabel.isHidden = setTo
//        fluidType6Quantity.isHidden = setTo
//
//        fluidType7Label.isHidden = setTo
//        fluidType7QuantityLabel.isHidden = setTo
//        fluidType7Quantity.isHidden = setTo
//
//        fluidType8Label.isHidden = setTo
//        fluidType8QuantityLabel.isHidden = setTo
//        fluidType8Quantity.isHidden = setTo
//
//        fluidType9Label.isHidden = setTo
//        fluidType9QuantityLabel.isHidden = setTo
//        fluidType9Quantity.isHidden = setTo
//
//        fluidType10Label.isHidden = setTo
//        fluidType10QuantityLabel.isHidden = setTo
//        fluidType10Quantity.isHidden = setTo
//
//        fluidTypeCurrentSMRLabel.isHidden = setTo
//        fluidTypeCurrentSMR.isHidden = setTo
//
//        fluidTypeNotesLabel.isHidden = setTo
//        fluidTypeNotes.isHidden = setTo
//    }
    
    func appendUsers() {
        let users = UserCoreDataHandler.fetchObject()
        
        enteredByPickerData.append("Select one:")
        enteredByOutputData.append(0)
        servicedByPickerData.append("Select one:")
        servicedByOutputData.append(0)
        
        for user in users! {
            let firstName = user.value(forKey: "firstName") as! String
            let lastName = user.value(forKey: "lastName") as! String
            let id = user.value(forKey: "id") as! Int16
            
            print("\(id), \(firstName), \(lastName)")
            
            enteredByPickerData.append("\(lastName), \(firstName)")
            enteredByOutputData.append(id)
            
            servicedByPickerData.append("\(lastName), \(firstName)")
            servicedByOutputData.append(id)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
            case 0:
                return enteredByPickerData.count
            
            case 1:
                return servicedByPickerData.count
            
            case 2:
                return subflowPickerData.count
            
            default:
                return enteredByPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
            case 0:
                return enteredByPickerData[row]
            
            case 1:
                return servicedByPickerData[row]
            
            case 2:
                if subflowPickerData[row]=="SMR Update" {
//                    toggleSMRUpdateFields(setTo: false)
//                    toggleFluidEntryFields(setTo: true)
                }
                if subflowPickerData[row]=="Fluid Entry" {
//                    toggleSMRUpdateFields(setTo: true)
//                    toggleFluidEntryFields(setTo: false)
                }
                return subflowPickerData[row]
            
            default:
                return enteredByPickerData[row]
        }
    }
    
    func jumpToSMRUpdateSubflow() {
        if let smrUpdateVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "smrUpdateVC") as? SMRUpdateController {
            
            smrUpdateVC.barCodeScanned = self.barCodeScanned
            smrUpdateVC.barCodeValue = self.barCodeValue
            smrUpdateVC.equipmentUnitIdSelected = self.equipmentUnitIdSelected
            smrUpdateVC.dateEntered = self.dateEntered.text!
            smrUpdateVC.enteredBy = self.enteredBy.text!
            smrUpdateVC.servicedBy = self.servicedBy.text!
            smrUpdateVC.enteredByInt = self.enteredByInt
            smrUpdateVC.servicedByInt = self.servicedByInt
            smrUpdateVC.subflow = self.subflowSelected
            
            self.present(smrUpdateVC, animated: false, completion: nil)
        }
    }
    
    func jumpToFluidEntrySubflow() {
        if let fluidEntryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "fluidEntryVC") as? FluidEntryController {
            
            fluidEntryVC.barCodeScanned = self.barCodeScanned
            fluidEntryVC.barCodeValue = self.barCodeValue
            fluidEntryVC.dateEntered = dateEntered.text!
            fluidEntryVC.enteredBy = enteredBy.text!
            fluidEntryVC.servicedBy = servicedBy.text!
            fluidEntryVC.subflow = subflowSelected
            
            self.present(fluidEntryVC, animated: false, completion: nil)
        }
    }
    
    func jumpToPMServiceSubflow() {
        if let pmServiceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pmServiceVC") as? PMServiceController {
            
            pmServiceVC.barCodeScanned = self.barCodeScanned
            pmServiceVC.barCodeValue = self.barCodeValue
            pmServiceVC.dateEntered = dateEntered.text!
            pmServiceVC.enteredBy = enteredBy.text!
            pmServiceVC.servicedBy = servicedBy.text!
            pmServiceVC.subflow = subflowSelected
            
            self.present(pmServiceVC, animated: false, completion: nil)
        }
    }
    
    func jumpToComponentChangeSubflow() {
        if let componentChangeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "componentChangeVC") as? ComponentChangeController {
            
            componentChangeVC.barCodeScanned = self.barCodeScanned
            componentChangeVC.barCodeValue = self.barCodeValue
            componentChangeVC.equipmentUnitIdSelected = self.equipmentUnitIdSelected
            componentChangeVC.dateEntered = dateEntered.text!
            componentChangeVC.enteredBy = enteredBy.text!
            componentChangeVC.servicedBy = servicedBy.text!
            componentChangeVC.enteredByInt = enteredByInt
            componentChangeVC.servicedByInt = servicedByInt
            componentChangeVC.subflow = subflowSelected
            
            self.present(componentChangeVC, animated: false, completion: nil)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView tag \(pickerView.tag)")
        switch(pickerView.tag) {
        case 0:
            enteredByInt = enteredByOutputData[row]
            enteredBy.text = enteredByPickerData[row]
            enteredBy.resignFirstResponder()
            
        case 1:
            servicedByInt = servicedByOutputData[row]
            servicedBy.text = servicedByPickerData[row]
            servicedBy.resignFirstResponder()
            
        case 2:
            subflow.text = subflowPickerData[row]
            subflowSelected = subflow.text!
            subflow.resignFirstResponder()
            
        default:
            enteredByInt = enteredByOutputData[row]
            enteredBy.text = enteredByPickerData[row]
            enteredBy.resignFirstResponder()
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("viewTapped.....")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy"
        dateEntered.text = dateFormatter.string(from: (datePicker?.date)!)
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        print("dateChanged.....")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateEntered.text = dateFormatter.string(from: (datePicker.date))
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.userScannedANewBarcode(unitNumber: "")
    }
    
//    deinit {
//        let notificationCenter = NotificationCenter.default
//
//        // Stop listening for keyboard hide/show events
//        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
//    }
    
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
        
        if segue.identifier == "goToLogEntry" {
            //2 If we have a delegate set, call the method userEnteredANewCityName
            // delegate?  means if delegate is set then
            // called Optional Chaining
            //                        delegate?.userScannedANewBarcode(equipmentUnit: "")
            
            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
            //            self.dismiss(animated: true, completion: nil)
            
            let destinationVC = segue.destination as! LogEntryController
            
            destinationVC.delegate = self
        }
        
        if segue.identifier == "goToSMRUpdate" {
            print("prepare for segue -- goToSMRUpdate")
            let destinationVC = segue.destination as! SMRUpdateController
            
//            destinationVC.initialSelectionDelegate = self
            destinationVC.barCodeScanned = self.barCodeScanned
            destinationVC.barCodeValue = self.barCodeValue
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
