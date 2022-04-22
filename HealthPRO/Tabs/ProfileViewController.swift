//
//  ProfileViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.addTarget(self, action: #selector(logoutButtonTouchUpInside), for: .touchUpInside)
    }
    
    @objc private func logoutButtonTouchUpInside(){

        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        viewController.weatherTimer.invalidate()
        viewController.cleanup()
        
        UserDefaults.standard.set("", forKey: "LoginUserName")
        UserDefaults.standard.synchronize()
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
    }

}
