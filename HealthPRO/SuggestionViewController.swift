//
//  SuggestionsViewController.swift
//  HealthPRO
//
//  Created by CIS 498 on 5/7/22.
//

import UIKit

class SuggestionsViewController: UIViewController{
    //@IBOutlet weak var todayDate: UILabel!
    //@IBOutlet weak var weatherImage: UIImageView!
    //@IBOutlet weak var historyButton: UIButton!
    var weatherUpdateTimer:Timer!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        let currentWeatherHere:String = self.getTheWeather()
        var outdoorOkay = true;
        
        if (currentWeatherHere.contains("SNOW") || currentWeatherHere.contains("RAIN")) {
            outdoorOkay = false;
        }
        
        //TODO: load in user's preference, load in suggestions and filter based on user preference and weather flag
        //TODO: present suggestion results per Storyboard format
        
        if let _ = self.weatherUpdateTimer {
            self.weatherUpdateTimer.invalidate()
        }
        
        //Uncomment this line once the close button is implemented for this VC otherwise there is a chance for a memory leak due to the timers not getting invalidated
        //self.weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getTheWeather), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.weatherUpdateTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @objc func getTheWeather() -> String {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        
        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
            return currentWeatherHere.weather[0].description.capitalized
        }
        
        return ""
    }
}
