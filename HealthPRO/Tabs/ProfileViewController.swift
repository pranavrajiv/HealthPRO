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
        viewController.cleanup()
    }
    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
