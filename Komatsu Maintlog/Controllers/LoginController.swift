//
//  LoginController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 5/7/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class LoginController: UIViewController {
    
    // Constants
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_PROD_BASE_URL = "http://10.132.146.48/maintlog/index.php"
    var API_AUTHENTICATE = "/api/authenticate"
    var API_CHECKLIST = "/api/checklist"
    var API_CHECKLISTITEM = "/api/checklistitem"
    var API_EQUIPMENTTYPE = "/api/equipmenttype"
    var API_EQUIPMENTUNIT = "/api/equipmentunit"
    var API_FLUIDTYPE = "/api/fluidtype"
    var API_COMPONENTTYPE = "/api/componenttype"
    var API_USER = "/api/user"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    let loggedInUserId = 0
    
    let networkStatus = NetworkStatus.sharedInstance
    
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var userPin: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func onUserPinChanged(_ sender: Any) {
        loginErrorLabel.isHidden = true
        loginErrorLabel.text = ""
        userPin.layer.borderColor = UIColor.black.cgColor
        userPin.layer.borderWidth = 1
        loginButton.isEnabled = true
    }
    
    @IBAction func onClickLogIn(_ sender: UIButton) {
        let userPinEntered: String = userPin.text!
        var URL = "\(API_PROD_BASE_URL)\(API_AUTHENTICATE)"
        
        ProgressHUD.show()
        
//        if !UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey) && ConnectivityHelper.isConnectedToKomatsuAmerica() {
//            print("Mode: PROD. Connect: OK")
//        } else if !UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey) && !ConnectivityHelper.isConnectedToKomatsuAmerica() {
//            print("Mode: PROD. Connect: NOPE")
//        } else if UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey) && !ConnectivityHelper.isConnectedToDev() {
//            print("Mode: DEV. Connect: OK")
//        } else if UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey) && !ConnectivityHelper.isConnectedToDev() {
//            print("Mode: DEV. Connect: NOPE")
//        }
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            URL = "\(API_DEV_BASE_URL)\(API_AUTHENTICATE)"
        }
        
        URL.append("?user_pin=\(userPinEntered)&api_key=\(API_KEY)")

        loginButton.isEnabled = false
        
        if !isLoggedIn() {
            _ = LoginCoreDataHandler.cleanDelete()
            doAuthCheck(url: URL)
        } else {
            performSegue(withIdentifier: "goToSelectScreen", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPin.text = ""
        
        let countActiveUsers = LoginCoreDataHandler.countActiveUsers()
        if countActiveUsers == 1 {
            let activeUsers = LoginCoreDataHandler.filterData(fieldName: "active", filterType: "equals", queryString: "1")
            
            for activeUser in activeUsers! {
//                print("expiresOn vs Date:")
//                print(activeUser.value(forKey: "expiresOn")!)
//                print(Date())
                if Date() > activeUser.value(forKey: "expiresOn")! as! Date {
                    // Proceed with login
                } else {
                    if isLoggedIn() {
                        allowSessionToContinue()
                    }
                }
            }
        }

        // Do any additional setup after loading the view.
//        if isLoggedIn() {
//            loginErrorLabel.text = "Session active. Click Continue to proceed."
//            loginErrorLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
//            loginErrorLabel.isHidden = false
//            pinLabel.isHidden = true
//            userPin.isHidden = true
//            loginButton.setTitle("Continue", for: .normal)
//        }
    }
    
    func allowSessionToContinue() {
        loginErrorLabel.text = "Session active. Click Continue to proceed."
        loginErrorLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
        loginErrorLabel.isHidden = false
        pinLabel.isHidden = true
        userPin.isHidden = true
        loginButton.setTitle("Continue", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        print(networkStatus.startNetworkReachabilityObserver())
    }
    
    func isLoggedIn() -> Bool {
        let adminCount = LoginCoreDataHandler.filterData(fieldName: "role", filterType: "", queryString: "admin")
        let userCount = LoginCoreDataHandler.filterData(fieldName: "role", filterType: "", queryString: "user")
        
        let loggedInCount = (adminCount?.count)! + (userCount?.count)!
        
        if loggedInCount > 0 {
            return true
        }
        
        return false
    }
    
    func doAuthCheck(url: String) {

//        print("Attempt connecting to: \(url)")
//        print(headers)
        
        // http://ashishkakkad.com/2015/10/how-to-use-alamofire-and-swiftyjson-with-swift/
        // https://stackoverflow.com/questions/35427698/how-to-use-networkreachabilitymanager-in-alamofire
        
//        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//
//            if let responseJSON : JSON = JSON(response.result.value!) {
//                if responseJSON["status"] == true {
//                    let userData = responseJSON["userData"]
////
//                    print(userData)
////
////                    for (_, checklist) in checklists {
////                        let id = checklist["id"].int16!
////                        let equipmentTypeId = checklist["equipmenttype_id"].int16!
////                        let checklistJson = checklist["checklist_json"].string!
////
////                        //                        print(checklistJson)
////                        //
////                        _ = ChecklistCoreDataHandler.saveObject(id: id, equipmentTypeId: equipmentTypeId, checklistJson: checklistJson)
////                    }
//                } else {
//                    let errorMessage = responseJSON["message"].string!
//                }
//            }
//        }
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
//            print(responseData)
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)

                if responseJSON["status"] == true {
                    self.doSuccessfulAuthTasks(responseJSON: responseJSON)
                } else {
                    self.doUnsuccessfulAuthTasks(responseJSON: responseJSON)
                }
            } else {
                ProgressHUD.showError("Unable to connect")
            }
        }
        
//        let sessionManager = SessionManager()
//        sessionManager.delegate.taskDidReceiveChallengeWithCompletion = { (_, _, challenge, completionHandler) -> Void in
//            // Pass test server with self signed certificate
//            if challenge.protectionSpace.host == "10.132.146.48" {
//                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//            } else {
//                completionHandler(.performDefaultHandling, nil)
//            }
//        }
//
//        sessionManager.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseString { (responseData) -> Void in
//                        print(responseData)
////                        if((responseData.result.value) != nil) {
////                            let responseJSON : JSON = JSON(responseData.result.value!)
////
////                            if responseJSON["status"] == true {
////                                self.doSuccessfulAuthTasks(responseJSON: responseJSON)
////                            } else {
////                                self.doUnsuccessfulAuthTasks(responseJSON: responseJSON)
////                            }
////                        } else {
////                            print("Response nil. No connection")
////                        }
//                    }
    }
    
    func doSuccessfulAuthTasks(responseJSON: JSON) {
        let userData = responseJSON["userData"]
        let userId = userData["user_id"].int16!
        let firstName = userData["first_name"].string!
        let lastName = userData["last_name"].string!
        let emailAddress = userData["email_address"].string!
        let role = userData["role"].string!
        let expiresOn = Date().addingTimeInterval(+43200) // TODO: Use to expire
        
        ProgressHUD.dismiss()
        
        _ = LoginCoreDataHandler.saveObject(userId: userId, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role, expiresOn: expiresOn)
        
        deleteItems()
//        deleteInspections()
        addChecklists()
        addChecklistItems()
        addEquipmentTypes()
        addEquipmentUnits()
        addFluidTypes()
        addUsers()
        
        performSegue(withIdentifier: "goToSelectScreen", sender: self)
    }
    
    func doUnsuccessfulAuthTasks(responseJSON: JSON) {
        let loginErrorMessage = responseJSON["message"].string!
        
//        ProgressHUD.dismiss()
        
        ProgressHUD.showError(loginErrorMessage)
        
//        userPin.layer.borderColor = (UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0) as! CGColor)
        userPin.layer.borderWidth = 2
//        loginErrorLabel.text = loginErrorMessage
//        loginErrorLabel.isHidden = false
    }
    
    func addChecklists() {
        var URL = "\(API_PROD_BASE_URL)\(API_CHECKLIST)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            URL = "\(API_DEV_BASE_URL)\(API_CHECKLIST)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
//            .responseJSON { (responseData) -> Void in
//                //            print(responseData)
//                if((responseData.result.value) != nil) {
//                    let responseJSON : JSON = JSON(responseData.result.value!)
//
//                    if responseJSON["status"] == true {
//                        self.doSuccessfulAuthTasks(responseJSON: responseJSON)
//                    } else {
//                        self.doUnsuccessfulAuthTasks(responseJSON: responseJSON)
//                    }
//                } else {
//                    print("Response nil. No connection")
//                }
//        }
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)

                if responseJSON["status"] == true {
                    let checklists = responseJSON["checklists"]

                    for (_, checklist) in checklists {
                        let id = checklist["id"].int16!
                        let equipmentTypeId = checklist["equipmenttype_id"].int16!
                        let checklistJson = checklist["checklist_json"].string!

                        _ = ChecklistCoreDataHandler.saveObject(id: id, equipmentTypeId: equipmentTypeId, checklistJson: checklistJson)
                    }
                } else {
                    self.doUnsuccessfulAuthTasks(responseJSON: responseJSON)
                }
            } else {
                ProgressHUD.showError("Unable to import Checklists")
            }
            
//            if let responseJSON : JSON = JSON(response.result.value!) {
//                if responseJSON["status"] == true {
//                    let checklists = responseJSON["checklists"]
//                    
//                    //                    print(checklists)
//                    
//                    for (_, checklist) in checklists {
//                        let id = checklist["id"].int16!
//                        let equipmentTypeId = checklist["equipmenttype_id"].int16!
//                        let checklistJson = checklist["checklist_json"].string!
//                        
//                        //                        print(checklistJson)
//                        //
//                        _ = ChecklistCoreDataHandler.saveObject(id: id, equipmentTypeId: equipmentTypeId, checklistJson: checklistJson)
//                    }
//                } else {
//                    let errorMessage = responseJSON["message"].string!
//                }
//            }
        }
    }
    
    func addChecklistItems() {
        var URL = "\(API_PROD_BASE_URL)\(API_CHECKLISTITEM)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_CHECKLISTITEM)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let checklistitems = responseJSON["checklistitems"]
                    
                    for (_, checklistitem) in checklistitems {
                        let id = checklistitem["id"].int16!
                        let item = checklistitem["item"].string!
                        
                        _ = ChecklistItemCoreDataHandler.saveObject(id: id, item: item)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Checklist Items")
            }
        }
    }
    
    func addEquipmentTypes() {
        var URL = "\(API_PROD_BASE_URL)\(API_EQUIPMENTTYPE)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_EQUIPMENTTYPE)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let equipmenttypes = responseJSON["equipmenttypes"]
                    
                    //                    print(equipmenttypes)
                    
                    for (_, equipmenttype) in equipmenttypes {
                        let id = equipmenttype["id"].int16!
                        let equipmentType = equipmenttype["equipment_type"].string!
                        
                        _ = EquipmentTypeCoreDataHandler.saveObject(id: id, equipmentType: equipmentType)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Equipment Types")
            }
        }
    }
    
    func addEquipmentUnits() {
        var URL = "\(API_PROD_BASE_URL)\(API_EQUIPMENTUNIT)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_EQUIPMENTUNIT)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let equipmentunits = responseJSON["equipmentunits"]
                    
                    for (_, equipmentunit) in equipmentunits {
                        let id = equipmentunit["equipmentunit_id"].int16!
                        let equipmentTypeId = equipmentunit["equipmenttype_id"].int16
                        let manufacturerName = equipmentunit["manufacturer_name"].stringValue
                        let modelNumber = equipmentunit["model_number"].stringValue
                        let unitNumber = equipmentunit["unit_number"].stringValue
                        let trackType = equipmentunit["track_type"].stringValue
                        let fluidsTracked = equipmentunit["fluids_tracked"].stringValue
                        
                        _ = EquipmentUnitCoreDataHandler.saveObject(id: id, equipmentTypeId: equipmentTypeId!, manufacturerName: manufacturerName, modelNumber: modelNumber, unitNumber: unitNumber, trackType: trackType, fluidsTracked: fluidsTracked)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Equipment Units")
            }
        }
    }
    
    func addFluidTypes() {
        var URL = "\(API_PROD_BASE_URL)\(API_FLUIDTYPE)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_FLUIDTYPE)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let fluidtypes = responseJSON["fluidtypes"]
                    
                    for (_, fluidtype) in fluidtypes {
                        let id = fluidtype["id"].int16!
                        let fluidType = fluidtype["fluid_type"].string!
                        
                        _ = FluidTypeCoreDataHandler.saveObject(id: id, fluidType: fluidType)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Fluid Types")
            }
        }
    }
    
    func addComponentTypes() {
        var URL = "\(API_PROD_BASE_URL)\(API_COMPONENTTYPE)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_COMPONENTTYPE)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let componenttypes = responseJSON["componenttypes"]
                    
                    for (_, componenttype) in componenttypes {
                        let id = componenttype["id"].int16!
                        let componentType = componenttype["component_type"].string!
                        
                        _ = ComponentTypeCoreDataHandler.saveObject(id: id, componentType: componentType)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Component Types")
            }
        }
    }
    
    func addUsers() {
        var URL = "\(API_PROD_BASE_URL)\(API_USER)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            URL = "\(API_DEV_BASE_URL)\(API_USER)"
        }
        
        URL.append("?api_key=\(API_KEY)")
        
        Alamofire.request(URL, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let responseJSON : JSON = JSON(responseData.result.value!)
                
                if responseJSON["status"] == true {
                    let users = responseJSON["users"]
                    
                    for (_, user) in users {
                        let id = user["id"].int16!
                        let firstName = user["first_name"].string!
                        let lastName = user["last_name"].string!
                        let emailAddress = user["email_address"].string!
                        let role = user["role"].string!
                        
                        _ = UserCoreDataHandler.saveObject(id: id, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role)
                    }
                } else {
                    let errorMessage = responseJSON["message"].string!
                }
            } else {
                ProgressHUD.showError("Unable to import Users")
            }
        }
    }
    
    func deleteItems() {
        _ = ChecklistCoreDataHandler.cleanDelete()
        _ = ChecklistItemCoreDataHandler.cleanDelete()
        _ = EquipmentTypeCoreDataHandler.cleanDelete()
        _ = EquipmentUnitCoreDataHandler.cleanDelete()
        _ = FluidTypeCoreDataHandler.cleanDelete()
        _ = UserCoreDataHandler.cleanDelete()
    }
    
    func deleteInspections() {
        _ = InspectionRatingCoreDataHandler.cleanDelete()
        _ = InspectionImageCoreDataHandler.cleanDelete()
    }

}
