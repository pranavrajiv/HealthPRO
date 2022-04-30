//
//  NutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit
import Vision
import VisionKit

class NutritionLabelViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var scanImageView: UIImageView!
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var ocrText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.processButton.isHidden = true
        self.clearButton.isHidden = true
        
        let camera = UIAction(title: "Camera", image: UIImage(systemName: "camera.fill")) { (action) in
            #if !targetEnvironment(simulator)
            self.scanDocument()
            #endif
        }
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
        self.populateScanLabel(UIImage.init(named:"nutritionLabelSample")!)
        #endif
    }
    
    @objc private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.populateScanLabel(image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func scanDocument() {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    @objc private func clearButtonTouchUp() {
        self.scanImageView.image = nil
        self.ocrText = ""
        self.processButton.isHidden = true
        self.clearButton.isHidden = true
    }
    
    @objc private func processButtonTouchUp() {
        if let image = self.scanImageView.image {
            self.processImage(image)
            
            let secondViewController = ParsedNutritionLabelViewController.init(ocrText: self.ocrText)
            secondViewController.modalPresentationStyle = .fullScreen
            self.present(secondViewController, animated: true, completion: nil)

        }
    }
 
    @objc private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    @objc private func populateScanLabel(_ image:UIImage) {
        scanImageView.image = image
        self.processButton.isHidden  = false
        self.clearButton.isHidden = false
    }
    
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
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}
