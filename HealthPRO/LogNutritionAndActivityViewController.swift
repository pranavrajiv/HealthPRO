//
//  LogNutritionAndActivityViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/28/22.
//

import UIKit

class LogNutritionAndActivityViewController: UIViewController {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var logItButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var hrsAndServingLabel: UILabel!
    @IBOutlet weak var hrsAndServingTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    var historyId:Int64!
    
    var logType:String!
    var itemId:Int64!
    
    convenience init(id: Int64, type:String) {
        self.init()
        self.logType = type
        self.itemId = id
    }
    
    convenience init(historyId: Int64, type:String) {
        self.init()
        self.logType = type
        self.historyId = historyId
        
        if self.logType == "Activity" {
            self.itemId = CoreDataHandler.init().getAllActivityHistory().first(where: {$0.activityHistoryId == historyId})?.activityRelationship?.activityId
        } else {
            self.itemId = CoreDataHandler.init().getAllFoodHistory().first(where: {$0.foodHistoryId == historyId})?.foodRelationship?.foodId
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.logType == "Activity" {
            self.itemName.text = CoreDataHandler.init().getActivityForId(activityId: self.itemId)?.activityName
            self.hrsAndServingLabel.text = "Hours Active"
        } else {
            self.itemName.text = CoreDataHandler.init().getFoodForId(foodId: self.itemId)?.foodName
            self.hrsAndServingLabel.text = "Serving Size"
        }
        
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTouchUp), for: .touchUpInside)
        self.editButton.addTarget(self, action: #selector(self.editButtonTouchUpInside), for: .touchUpInside)
        self.logItButton.addTarget(self, action: #selector(self.logButtonTouchUp), for: .touchUpInside)
        
        if (self.historyId != nil) {
            self.logItButton.setTitle("Update History", for: .normal)
            self.editButton.setTitle("Delete History", for: .normal)
            
            if self.logType == "Activity" {
                self.hrsAndServingTextField.text = CoreDataHandler.init().getAllActivityHistory().first(where: {$0.activityHistoryId == historyId})?.duration.description
                self.datePicker.date = (CoreDataHandler.init().getAllActivityHistory().first(where: {$0.activityHistoryId == historyId})?.timeStamp)!
            } else {
                self.hrsAndServingTextField.text = CoreDataHandler.init().getAllFoodHistory().first(where: {$0.foodHistoryId == historyId})?.serviceSize.description
                self.datePicker.date = (CoreDataHandler.init().getAllFoodHistory().first(where: {$0.foodHistoryId == historyId})?.timeStamp)!
            }
        }
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
        self.editButton.isUserInteractionEnabled = true
        self.logItButton.isUserInteractionEnabled = true
        self.cancelButton.isUserInteractionEnabled = true
        self.datePicker.isUserInteractionEnabled = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            animateTextField(up: true, keyBoardFrame: keyboardRectangle)
        }
        self.editButton.isUserInteractionEnabled = false
        self.logItButton.isUserInteractionEnabled = false
        self.cancelButton.isUserInteractionEnabled = false
        self.datePicker.isUserInteractionEnabled = false
        
    }
    
    func animateTextField(up: Bool, keyBoardFrame:CGRect) {
        if let currentActiveTextFieldSuperView = self.hrsAndServingTextField.superview {
            let textFieldLocation = currentActiveTextFieldSuperView.convert(CGPoint(x: self.hrsAndServingTextField.frame.maxX, y: self.hrsAndServingTextField.frame.maxY), to: self.view)
            
            let movementDuration: Double = 0.3
            
            var movement:CGFloat = 0
            if up {//Move the keyboard up so that the textField is not covered
                movement = -max(0, textFieldLocation.y - keyBoardFrame.origin.y + 5)
            } else {//Move the keyboard down as much as it was moved up
                movement = max(0, textFieldLocation.y - keyBoardFrame.origin.y + 5 + keyBoardFrame.height)
            }
            UIView.animate(withDuration: movementDuration, delay: 0, options: [.beginFromCurrentState], animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
            }, completion: nil)
        }
    }
    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    
    @objc private func editButtonTouchUpInside() {
        if (self.historyId != nil) {
            if self.logType == "Activity" {
                _ = CoreDataHandler.init().deleteActivityHistoryForId(activityHistoryId: self.historyId)
            } else {
                _ = CoreDataHandler.init().deleteFoodHistoryForId(foodHistoryId: self.historyId)
            }
            self.dismiss(animated: true, completion: nil)
        }else {
            if self.logType == "Activity" {
                let secondViewController = ActivityInfoViewController.init(activityId:self.itemId)
                secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
            } else {
                let secondViewController = ParsedNutritionLabelViewController.init(foodId: self.itemId)
                secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    @objc private func logButtonTouchUp() {
        
        if (self.hrsAndServingTextField.text=="") {
            let ac = UIAlertController(title: "Error", message: "Please enter serving size", preferredStyle: .alert)
            if self.logType == "Activity" {
                ac.message = "Please enter the hours worked out"
            }
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            return
        }
        
        let calorieHoursString = self.hrsAndServingTextField.text
        var calorieNumber = 0.0
        if let calorieNum = Double(calorieHoursString!.filter("0123456789.".contains)) {
            calorieNumber = calorieNum
        }
        if (self.historyId != nil) {
            if self.logType == "Activity" {
                _ = CoreDataHandler.init().updateActivityHistory(historyId: self.historyId, activityId: self.itemId, timeStamp: self.datePicker.date, duration: calorieNumber)
            } else { //food
                _ = CoreDataHandler.init().updateFoodHistory(historyId: self.historyId,foodId: self.itemId, timeStamp: self.datePicker.date, servingSize: calorieNumber)
            }
        }
        else
        {
            if self.logType == "Activity" {
                var historyId:Int64 = -1
                if let largestActivityHistoryId = CoreDataHandler.init().getAllActivityHistory().map({$0.activityHistoryId}).max() {
                    historyId = largestActivityHistoryId
                }
                _ = CoreDataHandler.init().logUserActivity(historyId:historyId + 1, activityId: self.itemId, timeStamp: self.datePicker.date, duration: calorieNumber)
              
            } else {
                var historyId:Int64 = -1
                if let largestFoodHistoryId = CoreDataHandler.init().getAllFoodHistory().map({$0.foodHistoryId}).max() {
                    historyId = largestFoodHistoryId
                }
                _ = CoreDataHandler.init().logUserFood(historyId:historyId + 1,foodId: self.itemId, timeStamp: self.datePicker.date, servingSize: calorieNumber)
            }
            
        }
        
        self.dismiss(animated: true)
    }
    

}
