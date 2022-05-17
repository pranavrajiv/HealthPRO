//
//  ProfileViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class ProfileViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var usageButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    var activeTextField:UITextField?
    var isKeyboardUp:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoutButton.addTarget(self, action: #selector(logoutButtonTouchUpInside), for: .touchUpInside)
        self.usageButton.addTarget(self, action: #selector(usageButtonTouchUpInside), for: .touchUpInside)
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
//        self.saveButton.isUserInteractionEnabled = false
//        self.deleteButton.isUserInteractionEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = textField
//        self.saveButton.isUserInteractionEnabled = true
//        self.deleteButton.isUserInteractionEnabled = true
    }
    
    
    
    
}
