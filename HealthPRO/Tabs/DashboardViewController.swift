//
//  DashboardViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/19/22.
//

import UIKit

class DashboardViewController: UIViewController{
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    var weatherUpdateTimer:Timer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTheWeather()
        
        if let _ = self.weatherUpdateTimer {
            self.weatherUpdateTimer.invalidate()
        }
        
        self.weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getTheWeather), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.weatherUpdateTimer.invalidate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userLabel.text = "Hello: " +  UserDefaults.standard.string(forKey: "LoginUserName")!
        //self.theWeatherInfo = Weather.init(delegate: self)
    }
    
    
    @objc func getTheWeather() {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        let currentWeatherHere = viewController.weatherInfoNow.currentWeather
        currentCity.text = viewController.weatherInfoNow.currentCity
        todayDate.text = Date.getTodaysDate()
        currentWeather.text = currentWeatherHere?.weather[0].description.capitalized
        currentTemperature.text = currentWeatherHere?.temp.description ?? ""
        if let _ = currentWeatherHere {
            currentTemperature.text! += " F°"
        }
        weatherImage.image = UIImage(named: currentWeatherHere?.weather[0].icon ?? "")
    }
    
}

