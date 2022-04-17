//
//  ParsedNutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/16/22.
//

import UIKit

class ParsedNutritionLabelViewController: UIViewController {

    @IBOutlet weak var caloriesVal: UITextField!
    @IBOutlet weak var totalFatVal: UIStackView!
    @IBOutlet weak var cholesterolVal: UIStackView!
    @IBOutlet weak var sodiumVal: UIStackView!
    @IBOutlet weak var totalCarbohydratesVal: UIStackView!
    @IBOutlet weak var dietaryFibersVal: UIStackView!
    @IBOutlet weak var totalSugarsVal: UIStackView!
    @IBOutlet weak var proteinVal: UIStackView!
    @IBOutlet weak var calciumVal: UIStackView!
    @IBOutlet weak var ironVal: UIStackView!
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
        self.processOcrText()
    }
    
    
    @objc private func saveButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }

    @objc private func processOcrText() {
        
    }
    
    
    
}
