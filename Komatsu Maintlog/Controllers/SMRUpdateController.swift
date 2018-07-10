//
//  SMRUpdateController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/29/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit
import SwiftyJSON

class SMRUpdateController: UIViewController, InitialSelectionDelegate {

    var initialSelectionDelegate : InitialSelectionDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var dateEntered : String = ""
    var enteredBy : String = ""
    var servicedBy : String = ""
    var subflow : String = ""
    
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var smrUpdatePreviousSMR: UIStackView!
    @IBOutlet weak var smrUpdateCurrentSMR: UITextField!
    
    @IBAction func onCloseSMRUpdateViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickSubmitSMRUpdate(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let jsonData: JSON = [
            "date_entered": "2018-01-01 12:00:01",
            "entered_by": "21",
            "unit_number": "5",
            "serviced_by": "1",
            
            "subflow": "sus",
            "sus_previous_smr": "12345",
            "sus_current_smr": "12346"
        ]
        
        debugPrint(jsonData)
        print("**")
        print(jsonData)
        
        /**
         $servicelog = R::dispense('servicelog');
         //        $servicelog->date_entered = date('Y-m-d', strtotime($post['date_entered']));
         //        $servicelog->entered_by = $post['entered_by'];
         //        $servicelog->unit_number = $post['unit_number'];
         //        $servicelog->created = $now;
         //        $servicelog_id = R::store($servicelog);
         //
         //        $servicedBys = explode("|", $post['serviced_by']);
         //        foreach($servicedBys as $ctr => $serviceByUserId) {
         //            $servicelog_servicedby = R::dispense('servicelogservicedby');
         //            $servicelog_servicedby->servicelog_id = $servicelog_id;
         //            $servicelog_servicedby->user_id = $serviceByUserId;
         //            $servicelog_servicedby_id = R::store($servicelog_servicedby);
         //        }
         //
         //        switch($post['subflow']) {
         //            case 'sus':
         //                $smrupdate = R::dispense('smrupdate');
         //                $smrupdate->servicelog_id = $servicelog_id;
         //                $smrupdate->previous_smr = $post['sus_previous_smr'];
         //                $smrupdate->smr = $post['sus_current_smr'];
         **/
        
//        _ = LogEntryCoreDataHandler.saveObject(uuid: "test", equipmentUnitId: 21, subflow: "SMR Update", jsonData: "[{\"sample\":\"123\"}]")
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(jsonData)")
        
        print("Save SMR Update test...")
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
    
    //Write the PrepareForSegue Method here
    // STEP 4: Set the second VC's delegate as the current VC, meaning this VC will receive the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSMRUpdate" {
            //2 If we have a delegate set, call the method userEnteredANewCityName
            // delegate?  means if delegate is set then
            // called Optional Chaining
            //                        delegate?.userScannedANewBarcode(equipmentUnit: "")
                        print("QQQQ")
            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
            //            self.dismiss(animated: true, completion: nil)
            
            //            let destinationVC = segue.destination as! SMRUpdateController
            //
            //            destinationVC.initialSelectionDelegate = self as! InitialSelectionDelegate
        }
        
    }

}
