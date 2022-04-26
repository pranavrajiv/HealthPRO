//
//  LoginViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/9/22.
//

import UIKit
import LocalAuthentication
import TabularData

class LoginViewController: UIViewController {
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var coreDataHandler:CoreDataHandler!
    var weatherTimer:Timer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.coreDataHandler.getAllFood().count == 0 {
            self.initialLaunch()
        }
        self.afterInitialLaunch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreDataHandler = CoreDataHandler.init()
        
        if let launchCount = UserDefaults.standard.object(forKey: "LaunchCount") as? Int {
            UserDefaults.standard.set(launchCount+1, forKey: "LaunchCount")
        } else {
            UserDefaults.standard.set(1, forKey: "LaunchCount")
        }
        UserDefaults.standard.synchronize()
        
        //indicates that the app entered background
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanup), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Do any additional setup after loading the view.
        loginRegisterButton.addTarget(self, action: #selector(loginOrRegisterProfile(_:)), for: .touchUpInside)
        segCtrl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    //cleanup textfields when logging out and login back again
    @objc public func cleanup() {
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
        self.weatherTimer.invalidate()
        UserDefaults.standard.set("", forKey: "LoginUserName")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
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
            
            if (self.usernameTextField.text=="") {
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
                            if self!.coreDataHandler.doesUserExist(id: self?.usernameTextField.text ?? "") {
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
            
            if let loginId = self.usernameTextField.text, let password = self.passwordTextField.text {
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
        return self.coreDataHandler.isValidLogin(id: self.usernameTextField.text ?? "", passcode: self.passwordTextField.text ?? "")
    }
    
    @objc private func logInProfile() {
        UserDefaults.standard.set(usernameTextField.text, forKey: "LoginUserName")
        UserDefaults.standard.synchronize()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc private func initialLaunch() {
        
        let url = Bundle.main.url(forResource: "nutrition", withExtension: "csv")!
        guard let result = try? DataFrame(contentsOfCSVFile: url) else {return}

        for i in 0...result.shape.rows - 1 {
            print(i)
            if let resultColumn = result.selecting(columnNames: "name").columns.first?[i] as? String,let calories = result.selecting(columnNames: "calories").columns.first?[i] as? Int,let total_fat = result.selecting(columnNames: "total_fat").columns.first?[i] as? String,let cholesterol = result.selecting(columnNames: "cholesterol").columns.first?[i] as? String,let sodium = result.selecting(columnNames: "sodium").columns.first?[i] as? String,let calcium = result.selecting(columnNames: "calcium").columns.first?[i] as? String,let iron = result.selecting(columnNames: "irom").columns.first?[i] as? String,let potassium = result.selecting(columnNames: "potassium").columns.first?[i] as? String,let protein = result.selecting(columnNames: "protein").columns.first?[i] as? String,let carbohydrate = result.selecting(columnNames: "carbohydrate").columns.first?[i] as? String,let sugars = result.selecting(columnNames: "sugars").columns.first?[i] as? String,let fiber = result.selecting(columnNames: "fiber").columns.first?[i] as? String {
               _ = self.coreDataHandler.addFood(foodName: resultColumn, calories: Int64(calories), total_fat: total_fat, cholesterol: cholesterol, sodium: sodium, calcium: calcium, iron: iron, potassium: potassium, protein: protein, carbohydrate: carbohydrate, sugars: sugars, fiber: fiber)
            }
        }
        self.activityIndicator.stopAnimating()
        self.blurView.isHidden = true;
    }
    
    @objc private func afterInitialLaunch() {
//        let foodItems = self.coreDataHandler.getAllFood()
        
//        for foodItem in foodItems {
//            print(foodItem.foodID)
//            print(foodItem.foodName)
//            print(foodItem.carbohydrate)
//            print("\n\n")
//        }
        
        self.activityIndicator.stopAnimating()
        self.blurView.isHidden = true;
    }
    
    
}

