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
    var API_PROD_BASE_URL = "https://10.132.146.48/maintlog/index.php"
    var API_UPLOAD_INSPECTION_RATINGS = "/api/upload_inspection_ratings"
    var API_UPLOAD_INSPECTION_IMAGES = "/api/upload_inspection_images"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headersWWWForm: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
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
    
    @IBOutlet weak var barcodeSelectedLabel: UILabel!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var inspectionEntryButton: UIButton!
    @IBOutlet weak var uploadInspectionButton: UIButton!
    @IBOutlet weak var uploadProgressBar: UIView!
    
    @IBAction func onClickUploadInspections(_ sender: UIButton) {
        var UPLOAD_INSPECTION_IMAGES_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            UPLOAD_INSPECTION_IMAGES_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        }
        
        UPLOAD_INSPECTION_IMAGES_URL.append("?&api_key=\(API_KEY)")
        
        var UPLOAD_INSPECTION_RATINGS_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            var UPLOAD_INSPECTION_RATINGS_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        }
        
        UPLOAD_INSPECTION_RATINGS_URL.append("?&api_key=\(API_KEY)")
        
//        uploadImages(url: UPLOAD_INSPECTION_IMAGES_URL)
        
        uploadRatings(url: UPLOAD_INSPECTION_RATINGS_URL)
        
        
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

        let countInspectionRating = InspectionRatingCoreDataHandler.countData()
        let countInspectionImage = InspectionImageCoreDataHandler.countData()
        
        print(countInspectionRating)
        print(countInspectionImage)
        
        let totalUploads = countInspectionRating + countInspectionImage
        
        if totalUploads > 0 {
//        if countInspectionRating > 0 || countInspectionImage > 0 {
            enableUploadButton(totalUploads: totalUploads)
        } else {
            disableUploadButton()
        }
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
        uploadInspectionButton.isEnabled = false
    }
    
    func userScannedANewBarcode(equipmentUnit: String) {
        if equipmentUnit != "" {
            barCodeScanned = true
            barCodeValue = equipmentUnit
            
            barcodeSelectedLabel.text = "Equipment Unit: \(barCodeValue)"
            barcodeSelectedLabel.backgroundColor = UIColor(red: 80/255, green: 164/255, blue: 81/255, alpha: 1.0)
            scanBarcodeButton.setTitle("Scan Another Barcode", for: .normal)
            inspectionEntryButton.isHidden = false
        } else {
            barCodeScanned = false
            barCodeValue = ""
            
            barcodeSelectedLabel.text = "Equipment Unit QR Code not scanned"
            barcodeSelectedLabel.backgroundColor = UIColor(red: 205/255, green: 68/255, blue: 74/255, alpha: 1.0)
            inspectionEntryButton.isHidden = true
        }
    }
    
    func uploadImages(url: String) {
        var inspectionImages = InspectionImageCoreDataHandler.fetchObject()
        
        uploadProgressBar.isHidden = true
        uploadProgressBar.frame.size.width = 0
        
        for inspectionImage in inspectionImages! {
            let image = inspectionImage.image
            let inspectionId = inspectionImage.inspectionId
            let photoId = inspectionImage.photoId
            
            let inspectionImageItem: [String: Any] = [
                "inspectionId": inspectionId,
                "photoId": photoId
            ]
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in inspectionImageItem {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let imageData = UIImagePNGRepresentation(UIImage(data: image!)!) {
                    multipartFormData.append(imageData, withName: "d", fileName: "picture.png", mimeType: "image/png")
                }
    
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headersMultipart) { (result) in
                switch result {
                    case .success(let upload, _, _):
                        self.uploadProgressBar.isHidden = false
                        
                        upload.uploadProgress { progress in
                            let percentComplete = Float(progress.fractionCompleted)
                            let newProgressBarWidth = (self.view.frame.size.width - 30) * CGFloat(percentComplete)
                            self.uploadProgressBar.frame.size.width = newProgressBarWidth
                        }
                        upload.validate()
                        upload.responseJSON { response in
                            print(response)
                            self.uploadProgressBar.isHidden = true
                            self.uploadProgressBar.frame.size.width = 0
                        }
                    
                    case .failure(let encodingError):
                        print(encodingError)
                        print("Image upload FAIL")
                        print("##")
                        self.uploadProgressBar.isHidden = true
                        self.uploadProgressBar.frame.size.width = 0
                    }
            }
        }
    }
    
//    func getUploadInspectionParams() -> [String: Any] {
//
//        // TODO: Continue implementation
//        // https://stackoverflow.com/questions/40702845/alamofire-4-swift-3-and-building-a-json-body
//
//        var params: [String: Any] = [
//            "ratings": [],
//            "images": []
//        ]
//
//        var inspectionRatings = InspectionRatingCoreDataHandler.fetchObject()
//        var inspectionImages = InspectionImageCoreDataHandler.fetchObject()
//
//        for inspectionRating in inspectionRatings! {
//            let checklistId = inspectionRating.checklistId
//            let equipmentUnitId = inspectionRating.equipmentUnitId!
//            let inspectionId = inspectionRating.inspectionId
//            let note = inspectionRating.note!
//            let rating = inspectionRating.rating
//            let uuid = inspectionRating.uuid
//
//            let inspectionRatingItem: [String: Any] = [
//                "checklistId": checklistId,
//                "equipmentUnitId": equipmentUnitId,
//                "inspectionId": inspectionId,
//                "note": note,
//                "rating": rating,
//                "uuid": uuid
//            ]
//
//            // Append Inspection Item
//            params["ratings"] = (params["ratings"] as? [[String: Any]] ?? []) + [inspectionRatingItem]
//        }
//
//        // Close...but this looks like it uses the actual UIImage...
//        // https://www.prisma.io/forum/t/upload-image-from-ios-with-alamofire/874
//
//        for inspectionImage in inspectionImages! {
//            let image = inspectionImage.image
//            let inspectionId = inspectionImage.inspectionId
//            let photoId = inspectionImage.photoId
//
//            let inspectionImageItem: [String: Any] = [
//                "image": UIImage(data: image!)! as Any,
//                "inspectionId": inspectionId,
//                "photoId": photoId
//            ]
//
//            for (key, value) in inspectionImageItem {
//                print("\(key): \(value)")
//            }
//
//            // Append Inspection Item
//            params["images"] = (params["images"] as? [[String: Any]] ?? []) + [inspectionImageItem]
//        }
//
//        return params
    
//        print(JSON(params))
        
//        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//
//            if let responseJSON : JSON = JSON(response.result.value!) {
//                if responseJSON["status"] == true {
//                    self.doSuccessfulAuthTasks(responseJSON: responseJSON)
//                } else {
//                    self.doUnsuccessfulAuthTasks(responseJSON: responseJSON)
//                }
//            }
//        }
        
//    }
    
    func uploadRatings(url: String) {
        var inspectionRatings = InspectionRatingCoreDataHandler.fetchObject()
        var params: Any = []
        
        for inspectionRating in inspectionRatings! {
            let checklistId = inspectionRating.checklistId
            let equipmentUnitId = inspectionRating.equipmentUnitId!
            let inspectionId = inspectionRating.inspectionId
            let note = inspectionRating.note!
            let rating = inspectionRating.rating
            let uuid = inspectionRating.uuid

            let inspectionRatingItem: [String: Any] = [
                "checklistId": checklistId,
                "equipmentUnitId": equipmentUnitId,
                "inspectionId": inspectionId,
                "note": note,
                "rating": rating,
                "uuid": uuid
            ]

            // Append Inspection Item
            params = (params as? [Any] ?? []) + [inspectionRatingItem]
        }
        
        print(params)
    }
    
    func uploadRatingsOld(parameters: Any) {
        var UPLOAD_INSPECTION_RATINGS_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            var UPLOAD_INSPECTION_RATINGS_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_RATINGS)"
        }
        
        UPLOAD_INSPECTION_RATINGS_URL.append("?&api_key=\(API_KEY)")

        print("*****")
        print(parameters)
        
//        Alamofire.request(UPLOAD_INSPECTION_RATINGS_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headersWWWForm) { response in
//            if let responseJSON : JSON = JSON(response.result.value!) {
//                if responseJSON["status"] == true {
//                    print("Upload inspection ratings: GOOD")
//                } else {
//                    print("Upload inspection ratings: BAD")
//                    //                    let errorMessage = responseJSON["message"].string!
//                }
//            }
//        }
//
//        Alamofire.request(UPLOAD_INSPECTION_RATINGS_URL, method: .post, encoding: JSONEncoding.default, headers: headersWWWForm).responseJSON { response in
//
//            if let responseJSON : JSON = JSON(response.result.value!) {
//                if responseJSON["status"] == true {
//                    print("Upload inspection ratings: GOOD")
//                } else {
//                    print("Upload inspection ratings: BAD")
////                    let errorMessage = responseJSON["message"].string!
//                }
//            }
//        }

    }
    
//    func requestWith(endUrl: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
//
//        let url = "http://google.com" /* your API url */
//
//        let headers: HTTPHeaders = [
//            /* "Authorization": "your_access_token",  in case you need authorization header */
//            "Content-type": "multipart/form-data"
//        ]
//
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in parameters {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//            }
//
//            if let data = imageData{
//                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
//            }
//
//        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
//            switch result{
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    print("Succesfully uploaded")
//                    if let err = response.error{
//                        onError?(err)
//                        return
//                    }
//                    onCompletion?(nil)
//                }
//            case .failure(let error):
//                print("Error in upload: \(error.localizedDescription)")
//                onError?(error)
//            }
//        }
//    }
    
    func uploadImages(parameters: Any) {
        var UPLOAD_INSPECTION_IMAGES_URL = "\(API_PROD_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        
        if(UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.DevModeKey)) {
            // USE DEV URL
            UPLOAD_INSPECTION_IMAGES_URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTION_IMAGES)"
        }
        
        UPLOAD_INSPECTION_IMAGES_URL.append("?&api_key=\(API_KEY)")
        
        print("#####")
        print(parameters)
        
        
        
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in parameters {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//            }
//
//            if let data = imageData{
//                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
//            }
//
//        }, usingThreshold: UInt64.init(), to: UPLOAD_INSPECTION_IMAGES_URL, method: .post, headers: headersMultipart) { (result) in
//            switch result{
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    print("Succesfully uploaded")
//                    if let err = response.error{
//                        print(err)
//                        return
//                    }
//                    onCompletion?(nil)
//                }
//            case .failure(let error):
//                print("Error in upload: \(error.localizedDescription)")
//                onError?(error)
//            }
//        }
        
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "image", mimeType: "image/png")
//        }, with: UPLOAD_INSPECTION_IMAGES_URL) {  result in
//            switch result {
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        debugPrint(response)
//                    }
//                case .failure(let encodingError):
//                    print(encodingError)
//            }
//        }
        
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in parameters {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//            }
//
//            if let data = imageData{
//                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
//            }
//
//        }, usingThreshold: UInt64.init(), to: UPLOAD_INSPECTION_IMAGES_URL, method: .post, headers: headersMultipart) { (result) in
//            switch result{
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        print("Succesfully uploaded")
//                        if let err = response.error{
//                            onError?(err)
//                            return
//                        }
//                        onCompletion?(nil)
//                    }
//                case .failure(let error):
//                    print("Error in upload: \(error.localizedDescription)")
//                    onError?(error)
//            }
//        }
    }
    
    //Write the PrepareForSegue Method here
    // STEP 4: Set the second VC's delegate as the current VC, meaning this VC will receive the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToScanBarcode" {
            
            let destinationVC = segue.destination as! BarCodeScannerController
            
            destinationVC.delegate = self
            
        }
        
        if segue.identifier == "goToInspectionEntry" {
            
            //2 If we have a delegate set, call the method userEnteredANewCityName
            // delegate?  means if delegate is set then
            // called Optional Chaining
//            delegate?.userScannedANewBarcode(equipmentUnit: barCodeValue)
            
            //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
            // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
//            self.dismiss(animated: true, completion: nil)
            
            let destinationVC = segue.destination as! InspectionEntryController

            destinationVC.delegate = self
            destinationVC.barCodeScanned = self.barCodeScanned
            destinationVC.barCodeValue = self.barCodeValue
            
        }
        
    }

}
