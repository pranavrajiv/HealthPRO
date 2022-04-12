//
//  LoginViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/9/22.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.addTarget(self, action: #selector(loginProfile), for: .touchUpInside)
    }

    @objc private func loginProfile() {
        
        let context = LAContext()
            var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Biometric needed for login"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
                            controller.modalPresentationStyle = .fullScreen
                            self?.present(controller, animated: true, completion: nil)
                        }
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            // no biometric
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }

        
        
        
        
    }
}

