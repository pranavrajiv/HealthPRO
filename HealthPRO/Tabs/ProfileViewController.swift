//
//  ProfileViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/11/22.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var usageButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
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
    
}
