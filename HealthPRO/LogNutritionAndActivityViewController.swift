//
//  LogNutritionAndActivityViewController.swift
//  HealthPRO
//
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
    var isKeyboardUp:Bool = false
    //stores if its a activity or a food log
    var logType:String!
    var itemId:Int64!
    
    convenience init(id: Int64, type:String) {
        self.init()
        self.logType = type
        self.itemId = id
    }
    
    //set the logType to be a activity or food
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
            self.hrsAndServingLabel.text = "Hours Active"
        } else {
            self.hrsAndServingLabel.text = "Serving Size"
        }
        
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTouchUp), for: .touchUpInside)
        self.editButton.addTarget(self, action: #selector(self.editButtonTouchUpInside), for: .touchUpInside)
        self.logItButton.addTarget(self, action: #selector(self.logButtonTouchUp), for: .touchUpInside)
        self.datePicker.maximumDate = Date()
        
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
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillDisappear),name: UIResponder.keyboardWillHideNotification,object: nil)
        if self.logType == "Activity" {
            self.itemName.text = CoreDataHandler.init().getActivityForId(activityId: self.itemId)?.activityName
        } else {
            self.itemName.text = CoreDataHandler.init().getFoodForId(foodId: self.itemId)?.foodName
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //keyboard disappear. Enable all userInteraction
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
    
    //keyboard Appear. Disable all userInteraction
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
    
    //this function moves the position of textfields higher incase the keyboard covers them
    func animateTextField(up: Bool, keyBoardFrame:CGRect) {
        if up == self.isKeyboardUp {
            return
        }
        self.isKeyboardUp = up
        
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

    //editActivityFood or deleteHistory pressed
    @objc private func editButtonTouchUpInside() {
        if (self.historyId != nil) {//deleteHistory
            let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Delete", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if self.logType == "Activity" {
                    _ = CoreDataHandler.init().deleteActivityHistoryForId(activityHistoryId: self.historyId)
                } else {
                    _ = CoreDataHandler.init().deleteFoodHistoryForId(foodHistoryId: self.historyId)
                }
                self.dismiss(animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(ac, animated: true)
        }else {//editActivityFood
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
    
    //cancel button pressed
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    //logActivityFood or updateHistory pressed
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
        
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Save", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let calorieHoursString = self.hrsAndServingTextField.text
            var calorieNumber = 0.0
            if let calorieNum = Double(calorieHoursString!.filter("0123456789.".contains)) {
                calorieNumber = calorieNum
            }
            if (self.historyId != nil) {//updateHistory
                if self.logType == "Activity" {
                    _ = CoreDataHandler.init().updateActivityHistory(historyId: self.historyId, activityId: self.itemId, timeStamp: self.datePicker.date, duration: calorieNumber)
                } else {
                    _ = CoreDataHandler.init().updateFoodHistory(historyId: self.historyId,foodId: self.itemId, timeStamp: self.datePicker.date, servingSize: calorieNumber)
                }
            }
            else
            {//logActivityFood
                if self.logType == "Activity" {
                    let historyId:Int64 =  CoreDataHandler.init().getLargestActivityHistoryId()
                    _ = CoreDataHandler.init().logUserActivity(historyId:historyId + 1, activityId: self.itemId, timeStamp: self.datePicker.date, duration: calorieNumber)
                  
                } else {
                    let historyId:Int64 = CoreDataHandler.init().getLargestFoodHistoryId()
                    
                    _ = CoreDataHandler.init().logUserFood(historyId:historyId + 1,foodId: self.itemId, timeStamp: self.datePicker.date, servingSize: calorieNumber)
                }
                
            }
            
            self.dismiss(animated: true)
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac, animated: true)
    
    }
    

}
