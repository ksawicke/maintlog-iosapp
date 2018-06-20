//
//  SelectScreenController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/6/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

// STEP 2: In the View Controller that will receive data, conform to the protocol defined in step 1;
// Then implement the required method (see below, func userEnteredANewCityName)
// This is where we do something with the data that is received from the other View Controller, in this case
// ChangeCityViewController
class SelectScreenController: UIViewController, ChangeEquipmentUnitDelegate {
    
    // Constants
    var API_DEV_BASE_URL = "https://test.rinconmountaintech.com/sites/komatsuna/index.php"
    var API_PROD_BASE_URL = "http://10.132.146.48/maintlog/index.php"
    var API_UPLOAD_INSPECTION_RATINGS = "/api/upload_inspection_ratings"
    var API_UPLOAD_INSPECTION_SMR_UPDATES = "/api/upload_inspection_smrupdates"
    var API_UPLOAD_INSPECTION_IMAGES = "/api/upload_inspection_images"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headersWWWForm: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    let headersMultipart: HTTPHeaders = [
        "Content-type": "multipart/form-data"
    ]
    
    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    
    var barCodeScanned : Bool = false
    var barCodeValue : String = ""
    var equipmentUnitId : Int16 = 0
    
    @IBOutlet weak var barcodeSelectedLabel: UILabel!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var inspectionEntryButton: UIButton!
    @IBOutlet weak var logEntryButton: UIButton!
    @IBOutlet weak var uploadInspectionButton: UIButton!
    @IBOutlet weak var uploadProgressBar: UIView!
    
    @IBAction func onClickUploadInspections(_ sender: UIButton) {
//        var UPLOAD_INSPECTION_IMAGES_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
//        
//        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
//            // USE DEV URL
//            UPLOAD_INSPECTION_IMAGES_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
//        }
//        
//        UPLOAD_INSPECTION_IMAGES_URL.append("?&api_key=\(API_KEY)")
//        
//        var UPLOAD_INSPECTION_RATINGS_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
//        
//        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
//            // USE DEV URL
//            UPLOAD_INSPECTION_RATINGS_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
//        }
//        
//        UPLOAD_INSPECTION_RATINGS_URL.append("?&api_key=\(API_KEY)")
//        
//        uploadImages(url: UPLOAD_INSPECTION_IMAGES_URL)
//        
//        uploadRatings(url: UPLOAD_INSPECTION_RATINGS_URL)
        
        
//        let params = getUploadInspectionParams() as [String: Any]
//        print(params["images"]!)
//        print(type(of: params["images"]!))
        
//        var arrayTest: [[(String, Int)]] = []
//        arrayTest.append([("Hello", 2)])
//        arrayTest.append([("Hello", 2)])
//        arrayTest.append([("Hello", 2)])
//
//        print(arrayTest)
        
        
//        let points: [[Int]] = [[10, 20], [30, 40]]
        
//        print(params)
        
//        let blah = type(of: params["ratings"])
//        print("'\(blah)'")
        
//        let typed = type(of: params["images"]) as! Any
//        print("'\(typed)'")
        
//        uploadRatings(parameters: params["ratings"]!)
//        uploadImages(parameters: params["images"]!)
    }
    
    @IBAction func onClickLogOut(_ sender: UIButton) {
    
        _ = LoginCoreDataHandler.cleanDelete()
        performSegue(withIdentifier: "goToLoginScreen", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        resetDefaultValues()
        
        ProgressHUD.dismiss()

//        let countInspectionRating = InspectionRatingCoreDataHandler.countData()
//        let countInspectionImage = InspectionImageCoreDataHandler.countData()
//
//        print(countInspectionRating)
//        print(countInspectionImage)
//
//        let totalUploads = countInspectionRating + countInspectionImage
//
//        if totalUploads > 0 {
////        if countInspectionRating > 0 || countInspectionImage > 0 {
//            enableUploadButton(totalUploads: totalUploads)
//        } else {
//            disableUploadButton()
//        }
        
        countInspectionsToUpload()
        updateItemsPendingMessage()
        attemptInspectionDataUploads()
        attemptInspectionSmrUploads()
        attemptInspectionImageUploads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableUploadButton(totalUploads: Int) {
        uploadInspectionButton.setTitle("Upload Inspections (\(totalUploads))", for: .normal)
        
        uploadInspectionButton.isEnabled = true
        uploadInspectionButton.isHidden = false
    }
    
    func disableUploadButton() {
        uploadInspectionButton.isEnabled = false
        uploadInspectionButton.isHidden = true
    }
    
    func resetDefaultValues() {
        barcodeSelectedLabel.text = "Equipment Unit QR Code not scanned"
        barcodeSelectedLabel.isHidden = false
        scanBarcodeButton.isHidden = false
//        uploadInspectionButton.isEnabled = false
    }
    
    func userScannedANewBarcode(unitNumber: String) {
        if unitNumber != "" {
            barCodeScanned = true
            barCodeValue = unitNumber
            
            barcodeSelectedLabel.text = "Unit Number: \(barCodeValue)"
            barcodeSelectedLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
            scanBarcodeButton.setTitle("Scan Another Barcode", for: .normal)
            inspectionEntryButton.isHidden = false
            logEntryButton.isHidden = false
        } else {
            barCodeScanned = false
            barCodeValue = ""
            
            barcodeSelectedLabel.text = "Equipment Unit QR Code not scanned"
            barcodeSelectedLabel.backgroundColor = UIColor(red: 205/255, green: 68/255, blue: 74/255, alpha: 1.0)
            inspectionEntryButton.isHidden = true
            logEntryButton.isHidden = true
        }
    }
    
    //Write the PrepareForSegue Method here
    // STEP 4: Set the second VC's delegate as the current VC, meaning this VC will receive the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch(segue.identifier) {
            case "goToScanBarcode":
                let destinationVC = segue.destination as! BarCodeScannerController
            
                destinationVC.delegate = self
            
            case "goToInspectionEntry":
                let destinationVC = segue.destination as! InspectionEntryController
            
                destinationVC.delegate = self
                destinationVC.barCodeScanned = self.barCodeScanned
                destinationVC.barCodeValue = self.barCodeValue
            
            case "goToLogEntry":
                let destinationVC = segue.destination as! LogEntryController
            
                destinationVC.delegate = self
                destinationVC.barCodeScanned = self.barCodeScanned
                destinationVC.barCodeValue = self.barCodeValue
            
            default:
                print(".")
        }
        
//        if segue.identifier == "goToScanBarcode" {
//
//            let destinationVC = segue.destination as! BarCodeScannerController
//
//            destinationVC.delegate = self
//
//        }
//
//        if segue.identifier == "goToInspectionEntry" {
//
//            //2 If we have a delegate set, call the method userEnteredANewCityName
//            // delegate?  means if delegate is set then
//            // called Optional Chaining
////            delegate?.userScannedANewBarcode(equipmentUnit: barCodeValue)
//
//            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
//            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
////            self.dismiss(animated: true, completion: nil)
//
//            let destinationVC = segue.destination as! InspectionEntryController
//
//            destinationVC.delegate = self
//            destinationVC.barCodeScanned = self.barCodeScanned
//            destinationVC.barCodeValue = self.barCodeValue
//
//        }
//
//        if segue.identifier == "goToLogEntry" {
//
//        }
        
    }
    
    func updateItemsPendingMessage() {
        Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(SelectScreenController.countInspectionsToUpload), userInfo: nil, repeats: true)
    }
    
    func attemptInspectionDataUploads() {
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(SelectScreenController.uploadInspectionData), userInfo: nil, repeats: true)
    }
    
    func attemptInspectionSmrUploads() {
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(SelectScreenController.uploadSmrUpdateData), userInfo: nil, repeats: true)
    }
    
    func attemptInspectionImageUploads() {
        Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(SelectScreenController.uploadInspectionImageData), userInfo: nil, repeats: true)
    }
    
    func checkIfSessionExpired() {
        Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(SelectScreenController.checkSession), userInfo: nil, repeats: true)
    }
    
    @objc func countInspectionsToUpload() {
        let countInspectionRating = InspectionRatingCoreDataHandler.countData()
        let countInspectionImage = InspectionImageCoreDataHandler.countData()

        let totalUploads = countInspectionRating + countInspectionImage
        
        if totalUploads > 0 {
            uploadInspectionButton.setTitle("\(totalUploads) items pending upload", for: .normal)
        } else {
            uploadInspectionButton.setTitle("", for: .normal)
        }
    }
    
    @objc func uploadInspectionData() {
        uploadInspectionRatings()
    }
    
    @objc func uploadInspectionImageData() {
        uploadInspectionImages()
    }
    
    @objc func uploadSmrUpdateData() {
        uploadInspectionSmrUpdates()
    }
    
    @objc func checkSession() {
        let countActiveUsers = LoginCoreDataHandler.countActiveUsers()
        if countActiveUsers == 1 {
            let activeUsers = LoginCoreDataHandler.filterData(fieldName: "active", filterType: "equals", queryString: "1")
            
            for activeUser in activeUsers! {
                if Date() > activeUser.value(forKey: "expiresOn")! as! Date {
                    goBackToLogin()
                } else {
                    if isLoggedIn() {
                        // Ok, allow user to continue
                    } else {
                        goBackToLogin()
                    }
                }
            }
        }
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
    
    func goBackToLogin() {
        let alert = UIAlertController(title: "Session Expired", message: "Return to Main Menu", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(restartAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func uploadInspectionRatings() {
        var UPLOAD_INSPECTION_RATINGS_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            UPLOAD_INSPECTION_RATINGS_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        }
        UPLOAD_INSPECTION_RATINGS_URL.append("?&api_key=\(API_KEY)")

        uploadRatings(url: UPLOAD_INSPECTION_RATINGS_URL)
    }
    
    func uploadInspectionSmrUpdates() {
        var UPLOAD_INSPECTION_SMR_UPDATES_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_SMR_UPDATES)"
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            UPLOAD_INSPECTION_SMR_UPDATES_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_SMR_UPDATES)"
        }
        UPLOAD_INSPECTION_SMR_UPDATES_URL.append("?&api_key=\(API_KEY)")
        
        uploadSmrUpdates(url: UPLOAD_INSPECTION_SMR_UPDATES_URL)
    }
    
    func uploadInspectionImages() {
        var UPLOAD_INSPECTION_IMAGES_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            UPLOAD_INSPECTION_IMAGES_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        }
        UPLOAD_INSPECTION_IMAGES_URL.append("?&api_key=\(API_KEY)")
        
        uploadImages(url: UPLOAD_INSPECTION_IMAGES_URL)
    }

    func uploadImages(url: String) {
        let inspectionImages = InspectionImageCoreDataHandler.fetchObject()
        
        uploadProgressBar.isHidden = true
        uploadProgressBar.frame.size.width = 0
        
        for inspectionImage in inspectionImages! {
            let image = inspectionImage.image
            let inspectionId = inspectionImage.inspectionId!
            let checklistItemId = inspectionImage.checklistItemId
            let photoId = inspectionImage.photoId
            
            let inspectionImageItem: Parameters = [
                "inspectionId": inspectionId,
                "checklistItemId": checklistItemId,
                "photoId": photoId,
                "type": "jpg"
            ]
            
            let fileName = "\(inspectionId)_\(checklistItemId)_\(photoId).jpg"
            let mimeType = "image/jpg"
            let imageData = UIImageJPEGRepresentation(UIImage(data: image!, scale: 1)!, 1.0)
            
            if(imageData != nil) {
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    for (key, value) in inspectionImageItem {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }

                    multipartFormData.append(imageData!, withName: "upload", fileName: fileName, mimeType: mimeType)

                }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headersMultipart) { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        self.uploadProgressBar.isHidden = false

                        upload.uploadProgress { progress in
                            let percentComplete = Float(progress.fractionCompleted)
                            let newProgressBarWidth = (self.view.frame.size.width - 30) * CGFloat(percentComplete)
                            self.uploadProgressBar.frame.size.width = newProgressBarWidth
                        }
                        //                    upload.validate(statusCode: 200..<600)
                        //                        .validate(contentType: ["text/html"])
                        //                        .response { response in
                        //                    }
                        upload.responseString { response in
//                            debugPrint(response)
                            self.uploadProgressBar.isHidden = true
                            self.uploadProgressBar.frame.size.width = 0
                        }

                        _ = InspectionImageCoreDataHandler.deleteObject(inspectionImage: inspectionImage)
                        
//                        ProgressHUD.showSuccess("Inspection Image uploaded!")

                    case .failure(let encodingError):
//                        ProgressHUD.showError("Unable to upload Inspection Image")
//                        print(encodingError)
//                        print("Image upload FAIL")
//                        print("##")
                        self.uploadProgressBar.isHidden = true
                        self.uploadProgressBar.frame.size.width = 0
//                        self.uploadInspectionButton.setTitle("Error trying to upload inspection(s)", for: .normal)
                    }
                }
            }
        }
    }
    
    func uploadSmrUpdates(url: String) {
        let smrUpdates = SmrUpdateCoreDataHandler.fetchObject()
        var params: Any = []
        
        for smrUpdate in smrUpdates! {
            let equipmentUnitId = "\(smrUpdate.equipmentUnitId)"
            let inspectionId = "\(smrUpdate.inspectionId!)"
            let smr = "\(smrUpdate.smr!)"
            let userId = "1"
            
            let smrUpdateItem: [String: Any] = [
                "equipmentUnitId": equipmentUnitId,
                "inspectionId": inspectionId,
                "smr": smr,
                "userId": userId
            ]
            
            // Append Item
            params = (params as? [Any] ?? []) + [smrUpdateItem]
        }
        
//        print(params)
        
        Alamofire.request(url, method: .post, parameters: ["smrupdates": params], encoding: JSONEncoding.default, headers: headersWWWForm).responseString {
            response in

            switch response.result {
            case .success:
                for smrUpdate in smrUpdates! {
                    _ = SmrUpdateCoreDataHandler.deleteObject(smrupdate: smrUpdate)
                }

                break
            case .failure(let error):

                print(error)
            }
        }
    }
    
    func uploadRatings(url: String) {
        let inspectionRatings = InspectionRatingCoreDataHandler.fetchObject()
        var params: Any = []
        
        for inspectionRating in inspectionRatings! {
            let equipmentUnitId = "\(inspectionRating.equipmentUnitId)"
            let checklistItemId = "\(inspectionRating.checklistItemId)"
            let inspectionId = "\(inspectionRating.inspectionId!)"
            let note = "\(inspectionRating.note!)"
            let rating = "\(inspectionRating.rating)"
            let userId = "1"
            
            let inspectionRatingItem: [String: Any] = [
                "equipmentUnitId": equipmentUnitId,
                "checklistItemId": checklistItemId,
                "inspectionId": inspectionId,
                "note": note,
                "rating": rating,
                "userId": userId
            ]
            
            // Append Inspection Item
            params = (params as? [Any] ?? []) + [inspectionRatingItem]
        }
        
//        print(params)
//
//        print("Attempt connect to: \(url)")
        
        Alamofire.request(url, method: .post, parameters: ["ratings": params], encoding: JSONEncoding.default, headers: headersWWWForm).responseString {
            response in
            
            switch response.result {
            case .success:
                for inspectionRating in inspectionRatings! {
//                    let equipmentUnitId = "\(inspectionRating.equipmentUnitId)"
//                    let checklistItemId = "\(inspectionRating.checklistItemId)"
//                    let inspectionId = "\(inspectionRating.inspectionId!)"
//                    let note = "\(inspectionRating.note!)"
//                    let rating = "\(inspectionRating.rating)"
//                    let userId = "1"
                    
                    _ = InspectionRatingCoreDataHandler.deleteObject(inspectionRating: inspectionRating)
                }
                
                break
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
}
