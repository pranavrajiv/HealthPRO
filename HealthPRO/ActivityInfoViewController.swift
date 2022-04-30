//
//  ActivityInfoViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/28/22.
//

import UIKit

class ActivityInfoViewController: UIViewController,UITextFieldDelegate  {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var isIndoorButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityName: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var calories: UITextField!
    var activeTextField:UITextField!
    var activityItem:Activity!
    //stores current parent so that the parent can be dismissed if deleting an item
    private var presentingController: UIViewController?
    
    convenience init( activityId: Int64 ) {
        self.init()
        self.activityItem = CoreDataHandler.init().getActivityForId(activityId: activityId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.addTarget(self, action: #selector(saveButtonTouchUp), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTouchUp), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
        isIndoorButton.addTarget(self, action: #selector(isIndoorButtonTouchUp(_:)), for: .touchUpInside)

        if(self.activityItem != nil) {
            self.activityName.text = self.activityItem.activityName
            self.calories.text = self.activityItem.caloriesPerHourPerLb.description
            self.isIndoorButton.setTitle(self.activityItem.isIndoor, for: .normal)
        }
        self.activityName.delegate = self
        self.calories.delegate = self
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentingController = presentingViewController
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
    
    func animateTextField(up: Bool, keyBoardFrame:CGRect) {
        let textFieldLocation = self.activeTextField.superview!.convert(CGPoint(x: self.activeTextField.frame.maxX, y: self.activeTextField.frame.maxY), to: self.view)
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activityName.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.activityName.accessibilityIdentifier)
        self.calories.isUserInteractionEnabled = (textField.accessibilityIdentifier == self.calories.accessibilityIdentifier)
        self.activeTextField = textField
        
        self.saveButton.isUserInteractionEnabled = false
        self.deleteButton.isUserInteractionEnabled = false
        self.cancelButton.isUserInteractionEnabled = false
        self.isIndoorButton.isUserInteractionEnabled = false
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activityName.isUserInteractionEnabled = true
        self.calories.isUserInteractionEnabled = true
        self.activeTextField = textField
        
        self.saveButton.isUserInteractionEnabled = true
        self.deleteButton.isUserInteractionEnabled = true
        self.cancelButton.isUserInteractionEnabled = true
        self.isIndoorButton.isUserInteractionEnabled = true
        
    }
    
    @objc private func saveButtonTouchUp() {
        
        if((self.activityName.text == nil) || (self.activityName.text == "")){
            let ac = UIAlertController(title: "Error", message: "Activity name empty. Please enter a name before saving", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            return
        }
        
        
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        
        let calorieString = self.calories.text
        var calorieNumber = 0.0
        if let calorieNum = Double(calorieString!.filter("0123456789.".contains)) {
            calorieNumber = calorieNum
        }
        
        //new activity
        if (self.activityItem == nil) {
             var largestActivityID:Int64 = -1
            if let activityID = viewController.coreDataHandler.getAllActivities().map({ $0.activityId }).max() {
                largestActivityID = activityID
             }
            
            _ = viewController.coreDataHandler.addActivity(activityId: largestActivityID + 1, activityName: self.activityName.text!, caloriesPerHourPerLb: calorieNumber, isIndoor: self.isIndoorButton.titleLabel!.text!)
        }
        else {
            //update activity
            _ = viewController.coreDataHandler.updateActivity(activityId: self.activityItem.activityId, activityName: self.activityName.text!, caloriesPerHourPerLb: calorieNumber,isIndoor: self.isIndoorButton.titleLabel!.text!)
        }
        
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    
    @objc private func deleteButtonTouchUp() {
        if let currentActivity = self.activityItem {
            _ = CoreDataHandler.init().deleteActivityForId(activityId: currentActivity.activityId)
            
            self.dismiss(animated: false, completion: {
                     self.presentingController?.dismiss(animated: false)
            })
        } else {
            self.dismiss(animated: true)
        }
        
    }
    
    @objc private func isIndoorButtonTouchUp(_ sender: UIButton) {
        if sender.titleLabel?.text == "YES" {
            sender.setTitle("NO", for: .normal)
        } else {
            sender.setTitle("YES", for: .normal)
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    }
    
    
}
