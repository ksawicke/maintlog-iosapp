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
    var API_UPLOAD_INSPECTIONS = "/api/upload_inspections"
    let API_KEY = "2b3vCKJO901LmncHfUREw8bxzsi3293101kLMNDhf"
    let headers: HTTPHeaders = [
        "Content-Type": "x-www-form-urlencoded"
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
    
    @IBAction func onClickUploadInspections(_ sender: UIButton) {
        var URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTIONS)"
        URL.append("?&api_key=\(API_KEY)")
    
        uploadInspections(url: URL)
    }
    
    @IBAction func onClickLogOut(_ sender: UIButton) {
    
        _ = LoginCoreDataHandler.cleanDelete()
        performSegue(withIdentifier: "goToLoginScreen", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        resetDefaultValues()

        var countInspectionRating = InspectionRatingCoreDataHandler.countData()
        var countInspectionImage = InspectionImageCoreDataHandler.countData()
        
        if countInspectionRating > 0 || countInspectionImage > 0 {
            enableUploadButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableUploadButton() {
        uploadInspectionButton.isEnabled = true
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
    
    func uploadInspections(url: String) {

        // TODO: Continue implementation
        // https://stackoverflow.com/questions/40702845/alamofire-4-swift-3-and-building-a-json-body
        
//        var params = [String: [String]]()
        
        var params: [String: Any] = [
            "ratings": [],
            "images": []
        ]
        
        print(params)

//        var inspectionRatings = InspectionRatingCoreDataHandler.fetchObject()
        var inspectionImages = InspectionImageCoreDataHandler.fetchObject()

//        for inspectionRating in inspectionRatings! {
//            let checklistId = inspectionRating.checklistId
//            let equipmentUnitId = inspectionRating.equipmentUnitId
//            let inspectionId = inspectionRating.inspectionId
//            let note = inspectionRating.note
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
        
        // Close...but this looks like it uses the actual UIImage...
        // https://www.prisma.io/forum/t/upload-image-from-ios-with-alamofire/874
        
        for inspectionImage in inspectionImages! {
            let image = inspectionImage.image
            let inspectionId = inspectionImage.inspectionId
            let photoId = inspectionImage.photoId
            
//            print(image!)
//            print(UIImage(data: image!))
            
            let inspectionImageItem: [String: Any] = [
//                "image": UIImage(data: image!),
                "inspectionId": inspectionId,
                "photoId": photoId
            ]
            
            var URL = "\(API_DEV_BASE_URL)\(API_UPLOAD_INSPECTIONS)"
            URL.append("?&api_key=\(API_KEY)")

            uploadImage(endUrl: URL, imageData: image, parameters: inspectionImageItem)
            
//
//
//
//            // Append Inspection Item
//            params["images"] = (params["images"] as? [[String: Any]] ?? []) + [inspectionImageItem]
        }
        
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
        
    }
    
    func uploadImage(endUrl: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil) {
        
//        let url = "http://google.com" /* your API url */
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: endUrl, method: .post, headers: headers) { (result) in
            switch result{
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Succesfully uploaded")
                        if let err = response.error{
                            onError?(err)
                            return
                        }
                        onCompletion?(nil)
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    onError?(error)
            }
        }
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
