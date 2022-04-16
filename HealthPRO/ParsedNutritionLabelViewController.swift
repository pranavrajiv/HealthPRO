//
//  ParsedNutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/16/22.
//

import UIKit

class ParsedNutritionLabelViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    var ocrText: String = ""

    convenience init( ocrText: String ) {
        self.init()
        self.ocrText = ocrText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(saveButtonTouchUp), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    
    @objc private func saveButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }

}
