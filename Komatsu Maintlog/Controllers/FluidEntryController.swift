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

class FluidEntryController: UIViewController, InitialSelectionDelegate {

    var initialSelectionDelegate : InitialSelectionDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var dateEntered : String = ""
    var enteredBy : String = ""
    var servicedBy : String = ""
    var subflow : String = ""
    
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
            "date_entered": "07/25/2018",
            "entered_by": "21",
            "unit_number": "5",
            "serviced_by": "1",
            
            "subflow": "flu",
            "fluid_added": [
                [ "type": "",
                  "quantity": 4.1,
                  "units": "gal" ],
                [ "type": "",
                  "quantity": 3.2,
                  "units": "gal" ],
            ],
            "flu_previous_smr": "12345",
            "flu_current_smr": "12346",
            "flu_notes": "sdfadfs"
        ]
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")
        
        print("Save Fluid Entry test...")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
