//
//  DateFormatHelper.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke on 8/2/18.
//  Copyright © 2018 user138461. All rights reserved.
//

import UIKit

class DateFormatHelper: UIViewController {

    static let sharedInstance = DateFormatHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMySQLDateFormat(dateString: String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m/d/yyyy"
        let newFormat = DateFormatter()
        newFormat.dateFormat = "YYYY-mm-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            return newFormat.string(from: date)
        } else {
            return nil
        }
        
    }

}
