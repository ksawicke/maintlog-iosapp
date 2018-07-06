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
        _ = LogEntryCoreDataHandler.saveObject(uuid: "test2", equipmentUnitId: 55, subflow: "Fluid Entry", jsonData: "[{\"sample\":\"342434242424\"}]")
        print("Save Fluid Entry test...")
        
//        let logEntries = LogEntryCoreDataHandler.fetchObject()
//        var params: Any = []
//        
//        for logEntry in logEntries! {
//            let uuid = "\(logEntry.uuid)"
//            let equipmentUnitId = "\(logEntry.equipmentUnitId)"
//            let subflow = "\(logEntry.subflow!)"
//            let jsonData = "\(logEntry.jsonData!)"
//            
//            let logEntryItem: [String: Any] = [
//                "uuid": uuid,
//                "equipmentUnitId": equipmentUnitId,
//                "subflow": subflow,
//                "jsonData": jsonData
//            ]
//            
//            // Append Item
//            params = (params as? [Any] ?? []) + [logEntryItem]
//        }
//        
//        Alamofire.request(url, method: .post, parameters: ["logentries": params], encoding: JSONEncoding.default, headers: headersWWWForm).responseString {
//            response in
//            
//            switch response.result {
//            case .success:
//                //                for smrUpdate in smrUpdates! {
//                //                    _ = SmrUpdateCoreDataHandler.deleteObject(smrupdate: smrUpdate)
//                //                }
//                
//                break
//            case .failure(let error):
//                
//                print(error)
//            }
//        }
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
