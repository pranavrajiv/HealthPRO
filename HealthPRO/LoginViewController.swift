//
//  LoginViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/9/22.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var coreDataHandler:CoreDataHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreDataHandler = CoreDataHandler.init()
        
        // Do any additional setup after loading the view.
        loginRegisterButton.addTarget(self, action: #selector(loginOrRegisterProfile(_:)), for: .touchUpInside)
        segCtrl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginRegisterButton.titleLabel?.text = "Login"
        } else {
            loginRegisterButton.titleLabel?.text = "Register"
        }
        loginRegisterButton.sizeToFit()
    }

    @objc private func loginOrRegisterProfile(_ sender: UIButton){
        //login button pressed
        if self.segCtrl.selectedSegmentIndex == 0 {
            loginRegisterButton.titleLabel?.text = "Login"
            
            if (self.emailTextField.text=="") {
                // error
                let ac = UIAlertController(title: "Login failure", message: "Email address empty", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                return
            }
            
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Biometric needed for login"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            if self!.coreDataHandler.doesUserExist(id: self?.emailTextField.text ?? "") {
                                self?.logInProfile()
                            } else {
                                let ac = UIAlertController(title: "Login failure", message: "Email address does not exist. Please register", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                            
                        } else {
                            if self?.loginWithEmailPasswordSuccessful() == true {
                                self?.logInProfile()
                            } else {
                                // error
                                let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                        }
                    }
                }
            } else {
                if self.loginWithEmailPasswordSuccessful() == true {
                    self.logInProfile()
                } else {
                    // no biometric
                    let ac = UIAlertController(title: "Authentication failed", message: "Email or Password incorrect", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        } else {//register button pressed
            
            //reset segment to login so that user can login after registration is complete
            self.segCtrl.selectedSegmentIndex = 0
            
            if let loginId = self.emailTextField.text, let password = self.passwordTextField.text {
                //check if user already added to Core Data
                if(self.coreDataHandler.doesUserExist(id: loginId)) {
                  let ac = UIAlertController(title: "Registration Failed!!!", message: "User Already Exists", preferredStyle: .alert)
                  ac.addAction(UIAlertAction(title: "OK", style: .default))
                  self.present(ac, animated: true)
                    
                } else if(self.coreDataHandler.addUser(id: loginId, password: password)) {
                    let ac = UIAlertController(title: "Registration Complete", message: "Successfully Registered. Please login", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    @objc private func loginWithEmailPasswordSuccessful()->Bool {
        return self.coreDataHandler.isValidLogin(id: self.emailTextField.text ?? "", passcode: self.passwordTextField.text ?? "")
    }
    
    @objc private func logInProfile() {
        UserDefaults.standard.set(emailTextField.text, forKey: "LoginUserName")
        UserDefaults.standard.synchronize()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
}

