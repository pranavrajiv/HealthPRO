//
//  ProfileViewController.swift
//  HealthPRO
//
//

import UIKit

class ProfileViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var usageButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var foodPreferenceButton: UIButton!
    @IBOutlet weak var activityPreferenceButton: UIButton!
    var activeTextField:UITextField?
    var isKeyboardUp:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoutButton.addTarget(self, action: #selector(logoutButtonTouchUpInside), for: .touchUpInside)
        self.usageButton.addTarget(self, action: #selector(usageButtonTouchUpInside), for: .touchUpInside)
        self.editButton.addTarget(self, action: #selector(editButtonTouchUpInside), for: .touchUpInside)
        self.foodPreferenceButton.addTarget(self, action: #selector(foodPreferenceButtonTouchUpInside), for: .touchUpInside)
        self.activityPreferenceButton.addTarget(self, action: #selector(activityPreferenceButtonTouchUpInside), for: .touchUpInside)
        self.genderButton.addTarget(self, action: #selector(genderButtonTouchUpInside), for: .touchUpInside)
        self.textFieldCollection.forEach({$0.delegate = self})
        self.textFieldCollection.forEach({$0.isEnabled = false})
        self.foodPreferenceButton.isUserInteractionEnabled = false
        self.activityPreferenceButton.isUserInteractionEnabled = false
        self.genderButton.isUserInteractionEnabled = false
    }
    
    @objc private func populateData() {
        let user = CoreDataHandler.init().getUser()
        self.userName.text = user?.loginId
        self.foodPreferenceButton.setTitle(user?.foodPreference == "" ? "Low Carb" : user?.foodPreference, for: .normal)
        self.activityPreferenceButton.setTitle(user?.activityPreference == "" ? "Cardio" : user?.activityPreference, for: .normal)
        (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "weight"}))?.text = user?.weight.description
        (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "birthYear"}))?.text = user?.birthYear.description
        (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "height"}))?.text = user?.height.description
        self.genderButton.titleLabel?.text = user?.gender
        (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "contactNumber"}))?.text = user?.contactNumber
        (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "emailAddress"}))?.text = user?.emailAddress
    }
    
    @objc private func saveData() {
        if let weight = Double((self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "weight"})?.text) ?? "0.0"),let height = Double((self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "height"})?.text) ?? "0.0") , let gender = self.genderButton.titleLabel?.text, let email = (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "emailAddress"}))?.text, let contactNumber = (self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "contactNumber"}))?.text, let birthYear = Int((self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "birthYear"})?.text) ?? "0"), let foodPreference = self.foodPreferenceButton.titleLabel?.text, let activityPreference = self.activityPreferenceButton.titleLabel?.text {
            _ = CoreDataHandler.init().updateUser(weight: weight, height: height, gender: gender, emailAddress: email, contactNumber: contactNumber, birthYear: birthYear, foodPreference: foodPreference, activityPreference: activityPreference)

            if self.genderButton.titleLabel?.text == "F" {
                self.userAvatar.image = UIImage(named: "User_Avatar_Female")
            } else {
                self.userAvatar.image = UIImage(named: "User_Avatar_Male")
            }
            
            //add weight history entry
            if(CoreDataHandler.init().doesWeightHistoryExist(forDate: Date())){
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                _  = CoreDataHandler.init().updateWeightHistory(historyId: CoreDataHandler.init().getAllWeightHistory().first(where: {formatter.string(from: $0.timeStamp!) == formatter.string(from: Date())})!.weightHistoryId, timeStamp: Date(), weight: weight)
            } else {
                var historyId:Int64 = -1
                if let largestWeightHistoryId = CoreDataHandler.init().getAllWeightHistory().map({$0.weightHistoryId}).max() {
                    historyId = largestWeightHistoryId
                }
                _  = CoreDataHandler.init().logUserWeightHistory(historyId: historyId + 1, timeStamp: Date(), weight: weight)
            }
            
        }
    }
    
    @objc private func editButtonTouchUpInside(){
        self.textFieldCollection.forEach({$0.isEnabled = !$0.isEnabled})
        self.foodPreferenceButton.isUserInteractionEnabled = !self.foodPreferenceButton.isUserInteractionEnabled
        self.activityPreferenceButton.isUserInteractionEnabled = !self.activityPreferenceButton.isUserInteractionEnabled
        self.genderButton.isUserInteractionEnabled = !self.genderButton.isUserInteractionEnabled
        
        
        if self.editButton.titleLabel?.text == "Save Info" {
            self.saveData()
        } else {
            self.textFieldCollection.first(where: {$0.accessibilityIdentifier == "birthYear"})?.becomeFirstResponder()
        }
        self.editButton.setTitle(self.editButton.titleLabel?.text == "Edit Profile" ? "Save Info" : "Edit Profile", for: .normal)
    }
    
    @objc private func foodPreferenceButtonTouchUpInside(){
        self.foodPreferenceButton.setTitle(self.foodPreferenceButton.titleLabel?.text == "Low Carb" ? "Low Fat" : "Low Carb", for: .normal)
    }
    
    @objc private func activityPreferenceButtonTouchUpInside(){
        self.activityPreferenceButton.setTitle(self.activityPreferenceButton.titleLabel?.text == "Cardio" ? "Strength" : "Cardio", for: .normal)
        
    }

    @objc private func genderButtonTouchUpInside(){
        self.genderButton.setTitle(self.genderButton.titleLabel?.text == "M" ? "F" : "M", for: .normal)
    }
    
    @objc private func logoutButtonTouchUpInside(){
        
        let ac = UIAlertController(title: "Confirmation", message: "Please confirm if you would like to Logout", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
            viewController.cleanup()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac, animated: true)
    }
    
    @objc private func usageButtonTouchUpInside(){
        
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        
        if let currentUser = viewController.coreDataHandler.getUser() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            let ac = UIAlertController(title: "App Usage Data", message: String(format: "User registered on %@ \n\nSince the first login, overall application usage time is %@ mins",formatter.string(from: currentUser.dateCreated ?? Date()), ((currentUser.usageTImeSeconds+Int64(Date().timeIntervalSince(viewController.appStartTimeStamp)))/60).description), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.populateData()
        
        if self.genderButton.titleLabel?.text == "F" {
            self.userAvatar.image = UIImage(named: "User_Avatar_Female")
        } else {
            self.userAvatar.image = UIImage(named: "User_Avatar_Male")
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillDisappear),name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func animateTextField(up: Bool, keyBoardFrame:CGRect) {
        if up == self.isKeyboardUp  {
            return
        }
        self.isKeyboardUp = up
        if let currentActiveTextField = self.activeTextField,let currentActiveTextFieldSuperView = currentActiveTextField.superview {
            let textFieldLocation = currentActiveTextFieldSuperView.convert(CGPoint(x: currentActiveTextField.frame.maxX, y: currentActiveTextField.frame.maxY), to: self.view)
            
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        self.textFieldCollection.forEach({$0.isUserInteractionEnabled = (textField.accessibilityIdentifier == $0.accessibilityIdentifier) ? true : false })
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = textField
        self.textFieldCollection.forEach({$0.isUserInteractionEnabled = true})
    }
    
    
    
    
}
