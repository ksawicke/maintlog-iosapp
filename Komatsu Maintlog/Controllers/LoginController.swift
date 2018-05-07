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

    //Constants
    let LOGIN_DEV_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php/auth/check"
    let APP_ID = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [ "content-type": "x-www-form-urlencoded"]
    
    @IBOutlet weak var userPin: UITextField!
    
    @IBAction func onClickLogIn(_ sender: UIButton) {
//        print("clicked Log In")
//        print("\(String(describing: userPin.text))")
        
        let params : [String : String] = [
            "pin" : String(describing: userPin.text),
//            "appid" : APP_ID
        ]
        
        doAuthCheck(url: LOGIN_DEV_URL, parameters: params)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doAuthCheck(url: String, parameters: [String : String]) {

//        let headers = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//        let parameters = [
//
//        ]
        
        print("****")
        print(url)
        print(parameters)
        
        let params2 : Dictionary = ["pin" : "1234"]
        
        
        
        Alamofire.request(url, method: .post, parameters: params2, encoding: JSONEncoding.default).responseJSON { response in
            print(response.request!)    // initial request
            print (response.response!) // response
            print(response.data!)     // server data
            print(response.result)   // result of response serialization
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

}
