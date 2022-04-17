//
//  ParsedNutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/16/22.
//

import UIKit

class ParsedNutritionLabelViewController: UIViewController {

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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    var ocrText: String = ""
    var macro:[String:String]=["Calories":"","Total Fat":"","Total Carb":"","Cholesterol":"","Sodium":"","Dietary Fiber":"","Sugars":"","Protein":"","Calcium":"","Iron":""]

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
                        
                        //Apple OCR scanner keeps scanning calorie value in the nextLine. Special case
                        if( (macroKey == "Calories") && (macro["Calories"] == "") && (index < (lines.count - 1)) ) {
                            if let value = self.getMacroValue(macroNutrientLine: String(lines[index + 1]), endingWith: "") {
                                macro[macroKey] = value
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
}

extension StringProtocol {
    //gets the index of a substring
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
}
