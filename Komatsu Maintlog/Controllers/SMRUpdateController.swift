//
//  SMRUpdateController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/29/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class SMRUpdateController: UIViewController, InitialSelectionDelegate {

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
    
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var smrUpdatePreviousSMR: UITextField!
    @IBOutlet weak var smrUpdateCurrentSMR: UITextField!
    
    @IBAction func onCloseSMRUpdateViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickSubmitSMRUpdate(_ sender: Any) {
        let uuid: String = UUID().uuidString
        let dateEnteredYMD = DateFormatHelper().getMySQLDateFormat(dateString: dateEntered)! as String
        let jsonData: [String: Any] = [
            "uuid": uuid,
            "date_entered": dateEnteredYMD,
            "entered_by": enteredByInt,
            "unit_number": equipmentUnitIdSelected,
            "serviced_by": servicedByInt,
            "subflow": "sus",
            
            "sus_previous_smr": "",
            "sus_current_smr": smrUpdateCurrentSMR.text!
        ]
        
        _ = LogEntryCoreDataHandler.saveObject(uuid: uuid, jsonData: "\(JSON(jsonData))")

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
        
        unitNumber.text = barCodeValue
        
        smrUpdatePreviousSMR.text = "Unable to load data"
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
        
        smrUpdatePreviousSMR.text = "\(String(describing: previousSMR!))"
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
