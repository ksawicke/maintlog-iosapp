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
    
    private init() {}
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "10.132.146.48")
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { status in
            
            switch status {
                
                case .notReachable:
                    print("The network is not reachable")
                    
                case .unknown :
                    print("It is unknown whether the network is reachable")
                    
                case .reachable(.ethernetOrWiFi):
                    print("The network is reachable over the WiFi connection")
                    
                case .reachable(.wwan):
                    print("The network is reachable over the WWAN connection")
                
            }
        }
        reachabilityManager?.startListening()
    }

}
