//
//  SelectScreenController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

// STEP 2: In the View Controller that will receive data, conform to the protocol defined in step 1;
// Then implement the required method (see below, func userEnteredANewCityName)
// This is where we do something with the data that is received from the other View Controller, in this case
// ChangeCityViewController
class SelectScreenController: UIViewController, ChangeEquipmentUnitDelegate {
    
    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    
    @IBOutlet weak var barcodeSelectedLabel: UILabel!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var inspectionEntryButton: UIButton!

    @IBAction func onClickLogOut(_ sender: UIButton) {
    
        _ = LoginCoreDataHandler.cleanDelete()
        performSegue(withIdentifier: "goToLoginScreen", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barcodeSelectedLabel.text = "You must first scan an Equipment Unit"
        barcodeSelectedLabel.isHidden = false
        scanBarcodeButton.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userScannedANewBarcode(equipmentUnit: String) {
        barCodeScanned = true
        barCodeValue = equipmentUnit
        
        barcodeSelectedLabel.text = "Equipment Unit: \(barCodeValue)"
        barcodeSelectedLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
        scanBarcodeButton.setTitle("Scan Another Barcode", for: .normal)
        inspectionEntryButton.isHidden = false
    }
    
    //Write the PrepareForSegue Method here
    // STEP 4: Set the second VC's delegate as the current VC, meaning this VC will receive the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToScanBarcode" {
            
            let destinationVC = segue.destination as! BarCodeScannerController
            
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "goToInspectionEntry" {
            
            print("YO YO YO YO YO")
            
            //2 If we have a delegate set, call the method userEnteredANewCityName
            // delegate?  means if delegate is set then
            // called Optional Chaining
//            delegate?.userScannedANewBarcode(equipmentUnit: barCodeValue)
            
            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
//            self.dismiss(animated: true, completion: nil)
            
            let destinationVC = segue.destination as! InspectionEntryController

            destinationVC.delegate = self
            destinationVC.barCodeScanned = self.barCodeScanned
            destinationVC.barCodeValue = self.barCodeValue
            
        }
        
    }

}
