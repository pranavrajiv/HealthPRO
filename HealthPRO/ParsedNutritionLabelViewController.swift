//
//  ParsedNutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/16/22.
//

import UIKit

class ParsedNutritionLabelViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var itemNameVal: UITextField!
    @IBOutlet weak var caloriesVal: UITextField!
    @IBOutlet weak var totalFatVal: UITextField!
    @IBOutlet weak var cholesterolVal: UITextField!
    @IBOutlet weak var sodiumVal: UITextField!
    @IBOutlet weak var totalCarbohydratesVal: UITextField!
    @IBOutlet weak var dietaryFibersVal: UITextField!
    @IBOutlet weak var totalSugarsVal: UITextField!
    @IBOutlet weak var proteinVal: UITextField!
    @IBOutlet weak var calciumVal: UITextField!
    @IBOutlet weak var ironVal: UITextField!
    @IBOutlet weak var potassiumVal: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    var ocrText: String = ""
    var macro:[String:String]=["Calories":"","Total Fat":"","Total Carb":"","Cholesterol":"","Sodium":"","Dietary Fiber":"","Sugars":"","Protein":"","Calcium":"","Iron":"","Potassium":""]
    var activeTextField:UITextField!

    convenience init( ocrText: String ) {
        self.init()
        self.ocrText = ocrText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(saveButtonTouchUp), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
        self.processOcrText()
        
        self.itemNameVal.delegate = self
        self.caloriesVal.delegate = self
        self.totalFatVal.delegate = self
        self.cholesterolVal.delegate = self
        self.sodiumVal.delegate = self
        self.totalCarbohydratesVal.delegate = self
        self.dietaryFibersVal.delegate = self
        self.totalSugarsVal.delegate = self
        self.proteinVal.delegate = self
        self.calciumVal.delegate = self
        self.ironVal.delegate = self
        self.potassiumVal.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil
        )
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillDisappear),name: UIResponder.keyboardWillHideNotification,object: nil
        )

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            animateTextField(up: false, keyBoardFrame: keyboardRectangle)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            animateTextField(up: true, keyBoardFrame: keyboardRectangle)
        }
    }
    
    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc private func saveButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }

    @objc private func processOcrText() {
        let lines = self.ocrText.split(whereSeparator: \.isNewline)
        
        for (macroKey, _) in macro {
            for (index, line) in lines.enumerated() {
                print("\(index + 1). \(line)")
                if  (macro[macroKey] == "") {
                    //some macros ends with a 'g' while others ends with a 'mg'
                    if let macroIndex = line.index(of: macroKey) {
                        if let value = self.getMacroValue(macroNutrientLine: String(lines[index][macroIndex...]), endingWith: "mg") {
                            macro[macroKey] = value
                        } else if let value = self.getMacroValue(macroNutrientLine: String(lines[index][macroIndex...]), endingWith: "g") {
                            macro[macroKey] = value
                        }
                        
                        if(macroKey == "Calories") {
                            if let value = self.getMacroValue(macroNutrientLine: String(lines[index][macroIndex...]), endingWith: "") {
                               macro[macroKey] = value
                           } //Apple OCR scanner keeps scanning calorie value in the nextLine. Special case
                            else if(index < (lines.count - 1)) {
                                 if let value = self.getMacroValue(macroNutrientLine: String(lines[index + 1]), endingWith: "") {
                                     macro[macroKey] = value
                                 }
                             }
                        }
                    }
                }
            }
        }

        self.caloriesVal.text = macro["Calories"]
        self.totalFatVal.text = macro["Total Fat"]
        self.cholesterolVal.text = macro["Cholesterol"]
        self.sodiumVal.text = macro["Sodium"]
        self.totalCarbohydratesVal.text = macro["Total Carb"]
        self.dietaryFibersVal.text = macro["Dietary Fiber"]
        self.totalSugarsVal.text = macro["Sugars"]
        self.proteinVal.text = macro["Protein"]
        self.calciumVal.text = macro["Calcium"]
        self.ironVal.text = macro["Iron"]
        self.potassiumVal.text = macro["Potassium"]
        
    }
    
    //regex function to obtain macro nutrient value
    @objc private func getMacroValue(macroNutrientLine:String, endingWith:String)->String? {
        
        let trimmedString = macroNutrientLine.replacingOccurrences(of: " ", with: "")

        let range = NSRange(location: 0, length: trimmedString.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[0-9]*\\.*[0-9]+"+endingWith)

        let results = regex.matches(in: trimmedString,range: range)
        
        if let resultsString = (results.map {String(trimmedString[Range($0.range, in: trimmedString)!])}).first {
            return String(resultsString.dropLast(endingWith.count)+" "+endingWith)
        }
        return nil
    }
    
    func animateTextField(up: Bool, keyBoardFrame:CGRect) {
        let textFieldLocation = self.activeTextField.superview!.convert(CGPoint(x: self.activeTextField.frame.maxX, y: self.activeTextField.frame.maxY), to: self.view)
        
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {//Move the keyboard up so that the textField is not covered
            movement = -max(0,textFieldLocation.y - keyBoardFrame.origin.y + 5)
        } else {//Move the keyboard down as much as it was moved up
            movement = max(0,textFieldLocation.y - keyBoardFrame.origin.y + 5 + keyBoardFrame.height)
        }
        UIView.animate(withDuration: movementDuration, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        }, completion: nil)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.itemNameVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.itemNameVal.accessibilityIdentifier)
        self.caloriesVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.caloriesVal.accessibilityIdentifier)
        self.totalFatVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.totalFatVal.accessibilityIdentifier)
        self.cholesterolVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.cholesterolVal.accessibilityIdentifier)
        self.sodiumVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.sodiumVal.accessibilityIdentifier)
        self.totalCarbohydratesVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.totalCarbohydratesVal.accessibilityIdentifier)
        self.dietaryFibersVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.dietaryFibersVal.accessibilityIdentifier)
        self.totalSugarsVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.totalSugarsVal.accessibilityIdentifier)
        self.proteinVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.proteinVal.accessibilityIdentifier)
        self.calciumVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.calciumVal.accessibilityIdentifier)
        self.ironVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.ironVal.accessibilityIdentifier)
        self.potassiumVal.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.potassiumVal.accessibilityIdentifier)
        
        self.activeTextField = textField
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.itemNameVal.isUserInteractionEnabled = true
        self.caloriesVal.isUserInteractionEnabled = true
        self.totalFatVal.isUserInteractionEnabled = true
        self.cholesterolVal.isUserInteractionEnabled = true
        self.sodiumVal.isUserInteractionEnabled = true
        self.totalCarbohydratesVal.isUserInteractionEnabled = true
        self.dietaryFibersVal.isUserInteractionEnabled = true
        self.totalSugarsVal.isUserInteractionEnabled = true
        self.proteinVal.isUserInteractionEnabled = true
        self.calciumVal.isUserInteractionEnabled = true
        self.ironVal.isUserInteractionEnabled = true
        self.potassiumVal.isUserInteractionEnabled = true
        
        self.activeTextField = textField
    }
}

extension StringProtocol {
    //gets the index of a substring
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
}
