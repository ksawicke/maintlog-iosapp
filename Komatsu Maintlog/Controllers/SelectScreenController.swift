//
//  SelectScreenController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData

class SelectScreenController: UIViewController {
    
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
        
        barcodeSelectedLabel.text = "Click Scan Barcode to continue"
        barcodeSelectedLabel.isHidden = false
        scanBarcodeButton.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
