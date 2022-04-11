//
//  LoginViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/9/22.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.addTarget(self, action: #selector(loginProfile), for: .touchUpInside)
    }

    @objc private func loginProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
        }
    }
}

