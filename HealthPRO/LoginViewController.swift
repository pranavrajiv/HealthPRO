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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginRegisterButton.addTarget(self, action: #selector(loginRegisterProfile(_:)), for: .touchUpInside)
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

    @objc private func loginRegisterProfile(_ sender: UIButton){
        if self.segCtrl.selectedSegmentIndex == 0 {
            loginRegisterButton.titleLabel?.text = "Login"
            
            let context = LAContext()
                var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Biometric needed for login"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            self?.openProfile()
                        } else {
                            if self?.loginWithEmailPasswordSuccessful() == true {
                                self?.openProfile()
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
                    self.openProfile()
                } else {
                    // no biometric
                    let ac = UIAlertController(title: "Authentication failed", message: "Email or Password incorrect", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        } else {
            //reset segment to login so that user can login after registration is complete
            self.segCtrl.selectedSegmentIndex = 0
            
            //TODO add code to register
            
            let ac = UIAlertController(title: "Registration Complete", message: "Successfully Registered. Please login", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
        
        
    }
    
    @objc private func loginWithEmailPasswordSuccessful()->Bool {
        // TODO check database to see if login is correct
        if ((self.emailTextField.text == "test") && (self.passwordTextField.text == "test")) {
            return true
        }
        return false
    }
    
    @objc private func openProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
}

