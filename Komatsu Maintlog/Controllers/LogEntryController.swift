//
//  LogEntryController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit

class LogEntryController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, ChangeEquipmentUnitDelegate {
    
    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var logEntryId : String = ""
    var equipmentTypeSelected : Int16 = 0
    var equipmentUnitIdSelected : Int16 = 0
    var equipmentUnit : String = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var currentSMR: UITextField!
    
    @IBAction func onCloseLogEntryViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        registerSettingsBundle()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LogEntryController.adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogEntryController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        defaultsChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        currentSMR.resignFirstResponder()
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
