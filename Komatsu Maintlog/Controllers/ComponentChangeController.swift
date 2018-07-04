//
//  ComponentChangeController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 7/2/18.
//  Copyright © 2018 Kevin Sawicke. All rights reserved.
//

import UIKit

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
