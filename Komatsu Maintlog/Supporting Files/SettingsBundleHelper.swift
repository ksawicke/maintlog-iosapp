//
//  SettingsBundleHelper.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 5/23/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    
    struct SettingsBundleKeys {
        static let Reset = "RESET_APP_KEY"
        static let FilesizePreferenceKey = "filesize_preference"
        static let DevModeKey = "dev_mode"
        static let AppVersionKey = "version_preference"
    }
    
    class func checkAndExecuteSettings() {
        // Reset app
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.Reset) {
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.Reset)
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            // reset userDefaults..
            // CoreDataDataModel().deleteAllData()
            // delete all other user data here..
            
            _ = EquipmentTypeCoreDataHandler.cleanDelete()
            _ = ChecklistCoreDataHandler.cleanDelete()
            _ = ChecklistItemCoreDataHandler.cleanDelete()
        }
        
        // Use development environment
    }
    
    class func setVersionAndBuildNumber() {
//        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
//        UserDefaults.standard.set(version, forKey: "version_preference")
//        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
//        UserDefaults.standard.set(build, forKey: "build_preference")
    }
}
