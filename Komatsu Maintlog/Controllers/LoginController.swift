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
    var LOGIN_DEV_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php/api/check_login"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
    ]
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let loggedInUserId = 0
    
    @IBOutlet weak var userPin: UITextField!
    
    @IBAction func onClickLogIn(_ sender: UIButton) {
        let userPinEntered: String = userPin.text!
        var URL = LOGIN_DEV_URL
        URL.append("?user_pin=\(userPinEntered)&api_key=\(API_KEY)")

        if !isLoggedIn() {
            print("not logged in")
            _ = LoginCoreDataHandler.cleanDelete()
            doAuthCheck(url: URL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isLoggedIn() {
            print("logged in")
            self.performSegue(withIdentifier: "selectScreen", sender: nil)
//            goToPostLoginScreen()
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
                    
                    _ = LoginCoreDataHandler.saveObject(userId: userId, userName: userName, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role)
                    
                    self.goToPostLoginScreen()
                } else {
                    let message = responseJSON["message"]
                    print("ERROR: \(message)")
                }
            }
        }
    }
    
    func goToPostLoginScreen() {
        
    }

}
