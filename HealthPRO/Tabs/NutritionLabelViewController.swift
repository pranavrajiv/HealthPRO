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
    @IBOutlet weak var scanImageView: UIImageView!
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var ocrText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.processButton.isUserInteractionEnabled = false
        //TODO set background Color for processButton when disabled
        
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
        configureOCR()
    }
    
    @objc private func scanDocument() {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string + "\n"
            }
            
            
            DispatchQueue.main.async {
                //self.ocrTextView.text = ocrText
                //self.scanButton.isEnabled = true
                self.ocrText = ocrText
            }
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
        self.processButton.isUserInteractionEnabled = true
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
