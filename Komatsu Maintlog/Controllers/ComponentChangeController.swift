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
    
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var componentChangeComponentType: UITextField!
    @IBOutlet weak var componentChangeComponent: UITextField!
    @IBOutlet weak var componentChangeComponentData: UITextField!
    @IBOutlet weak var componentChangeNotes: UITextField!
    
    @IBAction func onCloseComponentChangeEntryViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickSubmitComponentChange(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let jsonData: JSON = [
            "date_entered": "2018-01-01 12:00:01",
            "entered_by": "21",
            "unit_number": "5",
            "serviced_by": "1",
            
            "subflow": "ccs",
            "ccs_component_type": "",
            "ccs_component": "",
            "ccs_component_data": "",
            "ccs_notes": "",
            "ccs_previous_smr": "",
            "ccs_current_smr": ""
        ]
        /*
         $componentchange = R::dispense('componentchange');
         $componentchange->servicelog_id = $servicelog_id;
         $componentchange->component_type = $post['ccs_component_type'];
         $componentchange->component = $post['ccs_component'];
         $componentchange->component_data = $post['ccs_component_data'];
         $componentchange->notes = $post['ccs_notes'];
         R::store($componentchange);
         
         $componentchangesmrupdate = R::dispense('componentchangesmrupdate');
         $componentchangesmrupdate->servicelog_id = $servicelog_id;
         $componentchangesmrupdate->previous_smr = $post['ccs_previous_smr'];
         $componentchangesmrupdate->smr = $post['ccs_current_smr'];
         R::store($componentchangesmrupdate);*/
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
//        _ = LogEntryCoreDataHandler.saveObject(uuid: "test", equipmentUnitId: 665, subflow: "Component Change", jsonData: "[{\"sample\":\"555555\"}]")
        
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

}
