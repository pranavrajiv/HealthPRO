//
//  NutritionLabelViewController.swift
//  HealthPRO
//
//

import UIKit
import Vision
import VisionKit

class NutritionLabelViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var scanImageView: UIImageView!
    //varibale thats used to handle OCR requests
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var ocrText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.processButton.isHidden = true
        self.clearButton.isHidden = true
        
        //Camera option to load nutrition label
        let camera = UIAction(title: "Camera", image: UIImage(systemName: "camera.fill")) { (action) in
            //if not running in simulator give option to scan document
            #if !targetEnvironment(simulator)
            self.scanDocument()
            #endif
        }
        //PhotoLibrary option to load nutrition label
        let photoLibrary = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.fill")) { (action) in
            self.openPhotoLibrary()
        }
        
        let menu = UIMenu(title: "Scan Options", options: .displayInline, children: [camera , photoLibrary])
        scanButton.menu = menu
        scanButton.showsMenuAsPrimaryAction = true
        
        processButton.addTarget(self, action: #selector(processButtonTouchUp), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTouchUp), for: .touchUpInside)
        configureOCR()
        
        #if targetEnvironment(simulator)
        self.populateScanLabel(UIImage.init(named:"nutritionLabelSample")!)//populates a default nutrition label if running in the simulator
        #endif
    }
    
    //open photo library
    @objc private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //cancel imagePicker for scanning
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    //image selected by image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.populateScanLabel(image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //instantiate the VNDocumentCameraViewController to start scanning
    @objc private func scanDocument() {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    //clear button pressed
    @objc private func clearButtonTouchUp() {
        self.scanImageView.image = nil
        self.ocrText = ""
        self.processButton.isHidden = true
        self.clearButton.isHidden = true
    }
    
    //process the nutrition label to extract OCR
    @objc private func processButtonTouchUp() {
        if let image = self.scanImageView.image {
            self.processImage(image)
            
            let secondViewController = ParsedNutritionLabelViewController.init(ocrText: self.ocrText)
            secondViewController.modalPresentationStyle = .fullScreen
            self.present(secondViewController, animated: true, completion: nil)

        }
    }
 
    //perform OCR request on the nutrition label
    @objc private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Could not perform OCR request due to the following Error: "+error.localizedDescription
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
        }
    }
    
    //displays the nutrition label
    @objc private func populateScanLabel(_ image:UIImage) {
        scanImageView.image = image
        self.processButton.isHidden  = false
        self.clearButton.isHidden = false
    }
    
    //creates the VNRecognizeTextRequest and appends every detected text line with a new line
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedOcrText = ""
            for observation in observations {
                guard let textLine = observation.topCandidates(1).first else { return }
                detectedOcrText += textLine.string + "\n"
            }
            self.ocrText = detectedOcrText
        }
        
        ocrRequest.recognitionLanguages = ["en-US"]
        ocrRequest.usesLanguageCorrection = true
        ocrRequest.recognitionLevel = .accurate
    }
}


extension NutritionLabelViewController: VNDocumentCameraViewControllerDelegate {
    //indicates when a Nutrition label images has been captured by the camera
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        scanImageView.image = scan.imageOfPage(at: 0)
        self.processButton.isHidden  = false
        self.clearButton.isHidden = false
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        var notificationInfo: [AnyHashable: Any] = [:]
        notificationInfo["message"] = "VNDocumentCameraViewController failed due to the following Error: "+error.localizedDescription
        NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
        
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}
