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
    var API_AUTHENTICATE = "/api/authenticate"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let loggedInUserId = 0
    
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
        var URL = "\(API_DEV_BASE_URL)\(API_AUTHENTICATE)"
        URL.append("?user_pin=\(userPinEntered)&api_key=\(API_KEY)")

        loginButton.isEnabled = false
        
        if !isLoggedIn() {
            print("not logged in")
            _ = LoginCoreDataHandler.cleanDelete()
            doAuthCheck(url: URL)
        } else {
            performSegue(withIdentifier: "goToSelectScreen", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isLoggedIn() {
            loginErrorLabel.text = "Session active. Click Continue to proceed."
            loginErrorLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
            loginErrorLabel.isHidden = false
            pinLabel.isHidden = true
            userPin.isHidden = true
            loginButton.setTitle("Continue", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let responseJSON : JSON = JSON(response.result.value!) {
                if responseJSON["status"] == true {
                    let userData = responseJSON["userData"]
                    let userId = userData["user_id"].int32!
                    let userName = userData["username"].string!
                    let firstName = userData["first_name"].string!
                    let lastName = userData["last_name"].string!
                    let emailAddress = userData["email_address"].string!
                    let role = userData["role"].string!
                    // let twelveHoursFromNow = Date().addingTimeInterval(+43200) // TODO: Use to expire

                    _ = LoginCoreDataHandler.saveObject(userId: userId, userName: userName, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role)

                    self.performSegue(withIdentifier: "goToSelectScreen", sender: self)
                } else {
                    let loginErrorMessage = responseJSON["message"].string!

                    print(loginErrorMessage)

                    self.userPin.layer.borderColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0) as! CGColor
                    self.userPin.layer.borderWidth = 2
                    self.loginErrorLabel.text = loginErrorMessage
                    self.loginErrorLabel.isHidden = false
                }
            }
            
        }
    }

}
