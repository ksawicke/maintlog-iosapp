//
//  PMServiceController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 6/29/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit

class PMServiceController: UIViewController, InitialSelectionDelegate {

    var initialSelectionDelegate : InitialSelectionDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var dateEntered : String = ""
    var enteredBy : String = ""
    var servicedBy : String = ""
    var subflow : String = ""
    
    @IBOutlet weak var unitNumber: UITextField!
    @IBOutlet weak var pmServicePmType: UITextField!
    @IBOutlet weak var pmServicePMLevel: UITextField!
    @IBOutlet weak var pmServicePreviousSMR: UITextField!
    @IBOutlet weak var pmServiceCurrentSMR: UITextField!
    @IBOutlet weak var pmServiceNotes: UITextField!
    @IBOutlet weak var pmServiceNotes2: UITextField!
    @IBOutlet weak var pmServiceNotes3: UITextField!
    @IBOutlet weak var pmServiceReminderPMType: UITextField!
    @IBOutlet weak var pmServiceReminderPMLevel: UITextField!
    @IBOutlet weak var pmServiceReminderDue: UITextField!
    @IBOutlet weak var pmServiceReminderNotes: UITextField!
    @IBOutlet weak var pmServiceReminderDueQuantity: UITextField!
    @IBOutlet weak var pmServiceReminderDueUnits: UITextField!
    
    @IBAction func onClosePMServiceViewButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func onClickSubmitPMService(_ sender: Any) {
        
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
