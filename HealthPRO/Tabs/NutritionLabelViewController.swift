//
//  NutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit
import Vision
import VisionKit

class NutritionLabelViewController: UIViewController {

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
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
        processButton.addTarget(self, action: #selector(processButtonTouchUp), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTouchUp), for: .touchUpInside)
        configureOCR()
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
        }
    }
 
    @objc private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        //scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string + "\n"
            }
            
            self.ocrText = ocrText
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US"]
        ocrRequest.usesLanguageCorrection = true
    }
}


extension NutritionLabelViewController: VNDocumentCameraViewControllerDelegate {

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        scanImageView.image = scan.imageOfPage(at: 0)
        //processImage(scan.imageOfPage(at: 0))
        self.processButton.isHidden  = false
        self.clearButton.isHidden = false
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}
