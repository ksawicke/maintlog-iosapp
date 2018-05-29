//
//  NetworkStatus.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 5/29/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import Foundation
import Alamofire

class NetworkStatus {
    
    static let sharedInstance = NetworkStatus()
    
    var isConnected : Bool = false
    
    private init() {}
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "10.132.146.48") // test.rinconmountaintech.com
    
    func startNetworkReachabilityObserver() -> Bool {
        reachabilityManager?.listener = { status in
            
            switch status {
                
                case .notReachable:
                    self.isConnected = false
//                    print("The network is not reachable")
                
                case .unknown :
                    self.isConnected = false
//                    print("It is unknown whether the network is reachable")
                
                case .reachable(.ethernetOrWiFi):
                    self.isConnected = true
//                    print("The network is reachable over the WiFi connection")
                
                case .reachable(.wwan):
                    self.isConnected = true
//                    print("The network is reachable over the WWAN connection")
                
            }
            
            print(self.isConnected)
        }
        reachabilityManager?.startListening()
        
        print(isConnected)
        return isConnected
    }

}
