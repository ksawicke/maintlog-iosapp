//
//  BarCodeScannerController.swift
//  Komatsu Maintlog
//
//  Created by Kevin Sawicke <kevin@rinconmountaintech.com> on 4/26/18.
//  Copyright © 2018 Komatsu NA. All rights reserved.

import UIKit
import AVFoundation

//Write the protocol declaration here:
// STEP 1: create a protocol with a name and a required method
protocol ChangeEquipmentUnitDelegate {
    
    func userScannedANewBarcode (unitNumber : String)
    
}

class BarCodeScannerController: UIViewController {
    
    //Declare the delegate variable here:
    // STEP 3: create a delegate property (this is standard accepted practice)
    // We set it to type "ChangeEquipmentUnitDelegate" which is the same name as our protocol from step 1
    // At the end we put a ? since it is an Optional. It might be nil. If nil, line
    // below in getWeatherPressed starting with delegate? will not be triggered.
    // This means the data won't be sent to the other Controller
    var delegate : ChangeEquipmentUnitDelegate?
    
    @IBOutlet var barcodeDetectedLabel:UILabel!
    @IBOutlet var barcodeScannerHeader:UIView!
    
    @IBAction func onCloseScanBarcode(_ sender: UIButton) {
        
        //2 If we have a delegate set, call the method userEnteredANewCityName
        // delegate?  means if delegate is set then
        // called Optional Chaining
        delegate?.userScannedANewBarcode(unitNumber: "")
        
        //3 dismiss the BarCodeScannerController to go back to the SelectScreenController
        // STEP 5: Dismiss the second VC so we can go back to the SelectScreenController
        self.dismiss(animated: true, completion: nil)
        
//        dismiss(animated: true, completion: nil)
    }
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Error attempting to access the camera")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: barcodeDetectedLabel)
        view.bringSubview(toFront: barcodeScannerHeader)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Equipment Unit found:", message: "\(decodedURL)", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: { (action) -> Void in

            // 1. Get the equipmentUnit the user scanned
            var unitNumber = decodedURL
            
            // 1b. Check the equipment scanned in db
            let equipmentUnitScanned = EquipmentUnitCoreDataHandler.filterData(fieldName: "unitNumber", filterType: "equals", queryString: unitNumber)
            
            //            print(equipmentUnitScanned!)
            
            for managedObject in equipmentUnitScanned! {
                if let _ = managedObject.value(forKey: "manufacturerName"),
                    let _ = managedObject.value(forKey: "modelNumber"),
                    let scannedEquipmentTypeId = managedObject.value(forKey: "equipmentTypeId"),
                    let _ = managedObject.value(forKey: "id") {
                    
                    let equipmentTypeSelected = scannedEquipmentTypeId as! Int16
                    
                    let checklistCount = LoginCoreDataHandler.filterData(fieldName: "role", filterType: "", queryString: "\(scannedEquipmentTypeId)")
                    
                    print((checklistCount?.count)!)
                    
                    if (checklistCount?.count)! != 1 {
                        unitNumber = ""
                        
                        ProgressHUD.showError("Checklist not found")
                    }
                }
            }
            
            // 2. If we have a delegate set, call the method userScannedANewBarcode
            // delegate?  means if delegate is set then
            // called Optional Chaining
            self.delegate?.userScannedANewBarcode(unitNumber: unitNumber)
            
            // 3. Now go to the Inspection Entry Controller for now.
            // TODO: Later we need to determine which Controller
            // the user actually wanted to go to since the scanner
            // can be used also for the Log Entry section
            
            self.dismiss(animated: true, completion: nil)
            
//            let vc = InspectionEntryController(
//                nibName: "InspectionEntryController",
//                bundle: nil)
//            self.navigationController?.pushViewController(vc,
//                                                     animated: true)
            
//            if let url = URL(string: decodedURL) {
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
}

extension BarCodeScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            barcodeDetectedLabel.text = "Barcode not detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
                barcodeDetectedLabel.text = metadataObj.stringValue
            }
        }
    }
    
}
