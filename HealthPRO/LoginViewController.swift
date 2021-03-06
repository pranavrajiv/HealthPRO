//
//  LoginViewController.swift
//  HealthPRO
//
//

import UIKit
import LocalAuthentication
import TabularData

//this struct holds the latest weather info
struct WeatherNow {
    var currentWeather:Current!
    var weatherInfo:Weather!
    var currentCity: String!
    var weatherInOneHour: String!
    var weatherInTwoHours: String!
    
    init(theWeather:Weather) {
        self.weatherInfo = theWeather
    }
    
    //updates the weather
    mutating func updateCurrent(result:Result,currentCity:String) {
        self.currentCity = currentCity
        self.currentWeather = result.current
        self.weatherInOneHour = result.hourly[1].weather[0].description.uppercased()
        self.weatherInTwoHours = result.hourly[2].weather[0].description.uppercased()
    }
    
    mutating func cleanup() {
        self.currentCity = ""
        self.currentWeather = nil
        self.weatherInOneHour = ""
        self.weatherInTwoHours = ""
        self.weatherInfo?.weatherInfoNowTimer.invalidate()
        self.weatherInfo = nil
    }
}


class LoginViewController: UIViewController,WeatherInfoReceivedDelegate {
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    //holds the CoreData object
    var coreDataHandler:CoreDataHandler!
    //holds current weather
    var weatherInfoNow:WeatherNow!
    //stores the timeStamp when the app was first launched
    var appStartTimeStamp:Date!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //to make sure that all timer are invalidated first
        if let _ = self.weatherInfoNow {
            self.weatherInfoNow.cleanup()
        }
        self.weatherInfoNow = WeatherNow(theWeather: Weather.init(delegate: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //if no food entries are in core data, then populate it
        if self.coreDataHandler.getAllFood().count == 0 {
            self.populateFood()
        }
    
        //if no activity entries are in core data, then populate it
        if self.coreDataHandler.getAllActivities().count == 0 {
            self.populateActivity()
        }
        
        //if no suggestions entries are in core data, then populate it
        if self.coreDataHandler.getAllSuggestions().count == 0 {
            self.populateSuggestions()
        }
        
        self.afterInitialLaunch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreDataHandler = CoreDataHandler.init()
        
        //stores launch count of the app into userDefaults
        if let launchCount = UserDefaults.standard.object(forKey: "LaunchCount") as? Int {
            UserDefaults.standard.set(launchCount+1, forKey: "LaunchCount")
        } else {
            UserDefaults.standard.set(1, forKey: "LaunchCount")
        }
        
        UserDefaults.standard.synchronize()
        
        //indicates that the app entered background
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //indicates that the app entered background
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWentToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        //used to log into error file
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LogError"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(logTheError),name: NSNotification.Name("LogError"),object: nil)
        
        
        self.loginRegisterButton.setTitle("Login", for: .normal)
        self.loginRegisterButton.titleLabel?.font = loginRegisterButton.titleLabel?.font.withSize(35)
        self.loginRegisterButton.layer.cornerRadius = 25
        self.loginRegisterButton.addTarget(self, action: #selector(loginOrRegisterProfile(_:)), for: .touchUpInside)
        self.segCtrl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    //Used to Log into Error file any unexpected errors
    @objc func logTheError(notification:NSNotification) {
        if let data = notification.userInfo as? [String: String], let message = data["message"] {
            let fileManager = FileManager.default
            do {
                if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let locationOfFile = documentDirectory.appendingPathComponent("Health_Pro_Error.txt")
                    if !fileManager.fileExists(atPath: locationOfFile.path) {
                        fileManager.createFile(atPath: locationOfFile.path, contents: nil, attributes: nil)
                    }
                    var contentsOfFile =  try String(contentsOf: locationOfFile, encoding: .utf8)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
                    contentsOfFile += dateFormatter.string(from: Date()) + " ----->>>>> " + message + "\n"
                    
                    do {
                        try contentsOfFile.write(to: locationOfFile, atomically: true, encoding: .utf8)
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    //application came back to foreground
    @objc public func applicationBecameActive() {
        //to make sure that all timer are invalidated first
        if let _ = self.weatherInfoNow{
            self.weatherInfoNow.cleanup()
        }
        self.weatherInfoNow = WeatherNow(theWeather: Weather.init(delegate: self))
    }
    
    //application went to background
    @objc public func applicationWentToBackground() {
        self.cleanup()
        //done because the cleanup function will call the self.viewWillAppear due to the self.dismiss action in it. Now we need to remove the initialized weatherInfoNow
        if let _ = self.weatherInfoNow{
            self.weatherInfoNow.cleanup()
        }
        self.weatherInfoNow  = nil
    }
    
    //cleanup textfields when logging out and login back again
    @objc public func cleanup() {
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
        self.weatherInfoNow.cleanup()
        self.weatherInfoNow  = nil
        if let _ = self.appStartTimeStamp {
            _ = self.coreDataHandler.updateUserAppUsageTime(usageTime: Int64(Date().timeIntervalSince(self.appStartTimeStamp))+(self.coreDataHandler.getUser()?.usageTImeSeconds ?? 0))
        }
        self.appStartTimeStamp = nil
        UserDefaults.standard.set("", forKey: "LoginUserName")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    //delegate callback
    func gotTheWeather(theResult:Result, city:String){
        self.weatherInfoNow.updateCurrent(result: theResult, currentCity: city)
    }
    
    //notifies when user switched between login and register
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.loginRegisterButton.setTitle("Login", for: .normal)
        } else {
            self.loginRegisterButton.setTitle("Register", for: .normal)
        }
        loginRegisterButton.sizeToFit()
    }

    //login/Register button pressed 
    @objc private func loginOrRegisterProfile(_ sender: UIButton){
        //login button pressed
        if self.segCtrl.selectedSegmentIndex == 0 {
            loginRegisterButton.titleLabel?.text = "Login"
            
            if (self.usernameTextField.text=="") {
                // error
                let ac = UIAlertController(title: "Login failure", message: "Username empty", preferredStyle: .alert)
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
                            //if user exists and biometric is success, then login
                            if self!.coreDataHandler.doesUserExist(id: self?.usernameTextField.text ?? "") {
                                self?.logInProfile()
                            } else {
                                //biometric success but user not present
                                let ac = UIAlertController(title: "Login failure", message: "Email address does not exist. Please register", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                            
                        } else {
                            //biometric unsuccessful but login with password successful
                            if self?.loginWithEmailPasswordSuccessful() == true {
                                self?.logInProfile()
                            } else { // error. Biometric and login with password unsuccessful
                                let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                        }
                    }
                }
            } else {
                // no biometric but login with password successful
                if self.loginWithEmailPasswordSuccessful() == true {
                    self.logInProfile()
                } else { // no biometric and login with password unsuccessful
                    let ac = UIAlertController(title: "Authentication failed", message: "Username or Password incorrect", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        } else {//register button pressed
            
            self.loginRegisterButton.setTitle("Register", for: .normal)

            if self.usernameTextField.text == "" || self.passwordTextField.text == "" {
                let ac = UIAlertController(title: "Registration Failed!!!", message: "Username or Password cannot be blank", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                
            } else  if let loginId = self.usernameTextField.text, let password = self.passwordTextField.text {
                //check if user already added to Core Data
                if(self.coreDataHandler.doesUserExist(id: loginId)) {
                  let ac = UIAlertController(title: "Registration Failed!!!", message: "User Already Exists", preferredStyle: .alert)
                  ac.addAction(UIAlertAction(title: "OK", style: .default))
                  self.present(ac, animated: true)
                    
                } else if(self.coreDataHandler.addUser(id: loginId, password: password)) {
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.usernameTextField.becomeFirstResponder()
                    self.segCtrl.selectedSegmentIndex = 0
                    self.loginRegisterButton.setTitle("Login", for: .normal)
                    let ac = UIAlertController(title: "Registration Complete", message: "Successfully Registered. Please login", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    //Dismiss the keyboard when touched outside the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //function checks if user and password correct in coreData
    @objc private func loginWithEmailPasswordSuccessful()->Bool {
        return self.coreDataHandler.isValidLogin(id: self.usernameTextField.text ?? "", passcode: self.passwordTextField.text ?? "")
    }
    
    //logs the user into their profile
    @objc private func logInProfile() {
        
        UserDefaults.standard.set(usernameTextField.text, forKey: "LoginUserName")
        UserDefaults.standard.synchronize()
        self.appStartTimeStamp = Date()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //add CSV food entries into CoreData
    @objc private func populateFood() {
        let url = Bundle.main.url(forResource: "nutrition", withExtension: "csv")!
        guard let result = try? DataFrame(contentsOfCSVFile: url) else {
            
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Unable to populate Food into CoreData"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
            
            return
        }

        for i in 0...result.shape.rows - 1 {
            print(i)
            if let foodName = result.selecting(columnNames: "name").columns.first?[i] as? String,let calories = result.selecting(columnNames: "calories").columns.first?[i] as? Int,let total_fat = result.selecting(columnNames: "total_fat").columns.first?[i] as? String,let cholesterol = result.selecting(columnNames: "cholesterol").columns.first?[i] as? String,let sodium = result.selecting(columnNames: "sodium").columns.first?[i] as? String,let calcium = result.selecting(columnNames: "calcium").columns.first?[i] as? String,let iron = result.selecting(columnNames: "irom").columns.first?[i] as? String,let potassium = result.selecting(columnNames: "potassium").columns.first?[i] as? String,let protein = result.selecting(columnNames: "protein").columns.first?[i] as? String,let carbohydrate = result.selecting(columnNames: "carbohydrate").columns.first?[i] as? String,let sugars = result.selecting(columnNames: "sugars").columns.first?[i] as? String,let fiber = result.selecting(columnNames: "fiber").columns.first?[i] as? String {
                _ = self.coreDataHandler.addFood(foodId:Int64(i),foodName: foodName, calories: Int64(calories), total_fat: total_fat, cholesterol: cholesterol, sodium: sodium, calcium: calcium, iron: iron, potassium: potassium, protein: protein, carbohydrate: carbohydrate, sugars: sugars, fiber: fiber)
            }
        }
    }
    
    //add CSV activity entries into CoreData
    @objc private func populateActivity() {
        let url = Bundle.main.url(forResource: "activity", withExtension: "csv")!
        guard let result = try? DataFrame(contentsOfCSVFile: url) else {
            
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Unable to populate Activity into CoreData"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
            
            return
            
        }

        for i in 0...result.shape.rows - 1 {
            print(i)
            if let activityName = result.selecting(columnNames: "Activity (1 hour)").columns.first?[i] as? String,let calories = result.selecting(columnNames: "Calories Per Lb").columns.first?[i] as? Double,let isIndoor = result.selecting(columnNames: "Is Indoor").columns.first?[i] as? String {
                _ = self.coreDataHandler.addActivity(activityId: Int64(i), activityName: activityName, caloriesPerHourPerLb: Double(calories), isIndoor: isIndoor)
            }
        }
    }
    
    //add CSV suggestions entries into CoreData
    @objc private func populateSuggestions() {
        let url = Bundle.main.url(forResource: "suggestions", withExtension: "csv")!
        guard let result = try? DataFrame(contentsOfCSVFile: url) else {
            
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Unable to populate Suggestions into CoreData"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
            
            return
            
        }

        for i in 0...result.shape.rows - 1 {
            print(i)
            if let tag = result.selecting(columnNames: "tag").columns.first?[i] as? String,
               let suggestionText = result.selecting(columnNames: "suggestion").columns.first?[i] as? String,
               let userPreference = result.selecting(columnNames: "preference").columns.first?[i] as? String,
               let type = result.selecting(columnNames: "type").columns.first?[i] as? String,
               let weather = result.selecting(columnNames: "weather").columns.first?[i] as? String {
                _ = self.coreDataHandler.addSuggestion(suggestionId: Int64(i), suggestionTag: tag, suggestionText: suggestionText, userPreference:userPreference, weather: weather,type:type)
            }
        }
    }
    
    //post onboarding steps
    @objc private func afterInitialLaunch() {
        self.activityIndicator.stopAnimating()
        self.blurView.isHidden = true;
        
        if self.coreDataHandler.getAllFood().count == 0 {
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Food List Empty"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
        }
        
        if self.coreDataHandler.getAllActivities().count == 0 {
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Activity List Empty"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
        }
        
        if self.coreDataHandler.getAllSuggestions().count == 0 {
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Suggestion List Empty"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
        }
        
    }
    
    
}

