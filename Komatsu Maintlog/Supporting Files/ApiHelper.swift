//
//  ApiHelper.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 8/2/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiHelper: UIViewController {

    static let sharedInstance = ApiHelper()
    
    // Constants
    let previousSMRDefault = "Unable to load data"
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_PROD_BASE_URL = "http://10.132.146.48/maintlog/index.php"
    var API_SMR = "/api/last_smr"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPreviousSMR(equipmentUnitIdSelected: Int16) -> String {
        var URL = "\(API_PROD_BASE_URL)\(API_SMR)"
        var previousSMR = previousSMRDefault
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_SMR)"
        }
        
        URL.append("/\(equipmentUnitIdSelected)?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { responseData in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    previousSMR = self.getPreviousSMR(responseJSON: responseJSON)
                }
            }
        }
        
        return previousSMR
    }
    
    func getPreviousSMR(responseJSON: JSON) -> String {
        let previousSMR = responseJSON["previous_smr"].string
        
        return "\(String(describing: previousSMR!))"
    }

}
