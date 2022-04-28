//
//  ParsedNutritionLabelViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/16/22.
//

import UIKit

class ParsedNutritionLabelViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var macroTextFieldCollections: [UITextField]!
    
    @IBOutlet weak var itemNameVal: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var ocrText: String = ""
    var foodItem:Food!
    var macro:[String:String]=["Calories":"","Total Fat":"","Total Carb":"","Cholesterol":"","Sodium":"","Dietary Fiber":"","Sugars":"","Protein":"","Calcium":"","Iron":"","Potassium":""]
    var activeTextField:UITextField!

    convenience init( ocrText: String ) {
        self.init()
        self.ocrText = ocrText
    }
    convenience init( foodId: Int64 ) {
        self.init()
        self.foodItem = CoreDataHandler.init().getFoodForId(foodId: foodId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(saveButtonTouchUp), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTouchUp), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)

        if(self.ocrText != "") {
            self.processOcrText()
        } else {
            itemNameVal.text = foodItem?.foodName
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Calories"})?.text = foodItem?.calories.description
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Total Fat"})?.text = foodItem?.total_fat
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Total Carb"})?.text = foodItem?.carbohydrate
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Cholesterol"})?.text = foodItem?.cholesterol
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Sodium"})?.text = foodItem?.sodium
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Dietary Fiber"})?.text = foodItem?.fiber
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Sugars"})?.text = foodItem?.sugars
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Protein"})?.text = foodItem?.protein
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Calcium"})?.text = foodItem?.calcium
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Iron"})?.text = foodItem?.iron
            macroTextFieldCollections.first(where: {$0.accessibilityIdentifier == "Potassium"})?.text = foodItem?.potassium
        }
       
        self.itemNameVal.delegate = self
        self.macroTextFieldCollections.forEach({$0.delegate = self})
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
        
        // if updading food, call deifferent duinction
        
        if((self.itemNameVal.text == nil) || (self.itemNameVal.text == "")){
            let ac = UIAlertController(title: "Error", message: "Food Item name empty. Please enter a name before saving", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            return
        }
        
        
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        
        let calorieString = macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Calories"})?.text
        var calorieNumber = 0
        if let calorieNum = Int(calorieString?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "0") {
            calorieNumber = calorieNum
        }
        
        //new food
        if (self.foodItem == nil) {
            let largestFoodID = viewController.coreDataHandler.getAllFood().map { $0.foodId }.max()
            _ = viewController.coreDataHandler.addFood(foodId:largestFoodID! + 1,foodName: self.itemNameVal.text ?? "", calories: Int64(calorieNumber), total_fat: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Total Fat"})?.text ?? "", cholesterol: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Cholesterol"})?.text ?? "", sodium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Sodium"})?.text ?? "", calcium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Calcium"})?.text ?? "", iron: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Iron"})?.text ?? "", potassium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Potassium"})?.text ?? "", protein: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Protein"})?.text ?? "", carbohydrate: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Total Carb"})?.text ?? "", sugars: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Sugars"})?.text ?? "", fiber: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Dietary Fiber"})?.text ?? "")
        } else {
            //update food
            _ = viewController.coreDataHandler.updateFood(foodId:self.foodItem.foodId,foodName: self.itemNameVal.text ?? "", calories: Int64(calorieNumber), total_fat: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Total Fat"})?.text ?? "", cholesterol: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Cholesterol"})?.text ?? "", sodium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Sodium"})?.text ?? "", calcium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Calcium"})?.text ?? "", iron: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Iron"})?.text ?? "", potassium: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Potassium"})?.text ?? "", protein: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Protein"})?.text ?? "", carbohydrate: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Total Carb"})?.text ?? "", sugars: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Sugars"})?.text ?? "", fiber: macroTextFieldCollections.first(where: {$0.accessibilityIdentifier=="Dietary Fiber"})?.text ?? "")
        }
        
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    @objc private func deleteButtonTouchUp() {
        if let food = self.foodItem {
            _ = CoreDataHandler.init().deleteFoodForId(foodId: food.foodId)
        }
        self.dismiss(animated: true)
    }

    @objc private func processOcrText() {
        let lines = self.ocrText.split(whereSeparator: \.isNewline)
        
        for (macroKey, _) in macro {
            for (index, line) in lines.enumerated() {
                //print("\(index + 1). \(line)")
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
        
        self.macroTextFieldCollections.forEach({$0.text = macro[$0.accessibilityIdentifier!]})
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
        self.macroTextFieldCollections.forEach({$0.isUserInteractionEnabled = (textField.accessibilityIdentifier == $0.accessibilityIdentifier)})
        self.activeTextField = textField
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.itemNameVal.isUserInteractionEnabled = true
        self.macroTextFieldCollections.forEach({$0.isUserInteractionEnabled = true})
        self.activeTextField = textField
    }
}

extension StringProtocol {
    //gets the index of a substring
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
}
