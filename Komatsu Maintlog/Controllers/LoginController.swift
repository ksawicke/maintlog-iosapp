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
    
    @IBOutlet weak var userPin: UITextField!
    
    @IBAction func onClickLogIn(_ sender: UIButton) {
//        print("clicked Log In")
//        print("\(String(describing: userPin.text))")
        
//        let params : Parameters = [
//            "user_pin" : "5555",
//            "api_key" : API_KEY
//        ]
        let userPinEntered: String = userPin.text!
        var URL = LOGIN_DEV_URL
        URL.append("?user_pin=\(userPinEntered)&api_key=\(API_KEY)")
        
        print(URL)
        
        doAuthCheck(url: URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doAuthCheck(url: String) {
        
        Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let responseJSON : JSON = JSON(response.result.value!) {
            
                if responseJSON["status"] == true {
    //                print(responseJSON["userData"]["username"])
                    
                    let userData = responseJSON["userData"]

                    print(userData)
                    
                    let userId = userData["user_id"].int32!
                    let userName = userData["username"].string!
                    let firstName = userData["first_name"].string!
                    let lastName = userData["last_name"].string!
                    let emailAddress = userData["email_address"].string!
                    let role = userData["role"].string!
                    
                    _ = LoginCoreDataHandler.saveObject(userId: userId, userName: userName, firstName: firstName, lastName: lastName, emailAddress: emailAddress, role: role)
                    
                } else {
                    let message = responseJSON["message"]
                    print("ERROR: \(message)")
                }
                
            }
//            print(responseJSON)
            
//            if response.result.isSuccess {
//                print("Success! Got the user data")
//
//                let userJSON : JSON = JSON(response.result.value!)
//
//                print(userJSON)
//
////                self.updateUserData(json: userJSON)
//
//            } else {
//                print("ERROR getting user data...") // response.result.error
////                self.cityLabel.text = "Connection Issues"
//            }
//
//
//            print("****")
//
//            if let result = response.result.value {
//                let JSON = result as! NSDictionary
//                print(JSON)
//            }
//
//            print("REQUEST")
//            print(response.request!)    // initial request
////
//            print("RESPONSE")
//            print(response.response!) // response
//
//            print("DATA")
//            print(response.data!)     // server data
//////
//            print("RESULT")
//            print(response.result)   // result of response serialization
//////
//            print("ALL HEADER FIELDS")
//            print(response.response?.allHeaderFields)
////
//            print("STATUS CODE: \(String(describing: response.response?.statusCode))")
//            print("\(String(describing: response.result))")
//            print("****")
//            print("-----")
        }
        
//        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
//
//            switch(response.result) {
//                case.success(let data):
//                    print("success",data)
//
//                case.failure(let error):
//                    print("Not Success",error)
//            }
//
//        }
        
//        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON {
//            response in
//            if response.result.isSuccess {
//                print("Success!")
//
//                let responseJSON : JSON = JSON(response.result.value!)
//
//                print(responseJSON)
//
////                self.updateWeatherData(json: weatherJSON)
//
//            } else {
//                print(response)
//                print("ERROR getting data...") // response.result.error
////                self.cityLabel.text = "Connection Issues"
//            }
//        }
        
    }
    
//    func updateUserData(json : JSON) {
//
//        if let tempResult = json["userData"] {
//
//            print(tempResult["first_name"])
//            print(tempResult["last_name"])
//            print(tempResult["role"])
//
//        } else {
//
//            print("User data unavailable")
//
//        }
//
//    }

}
