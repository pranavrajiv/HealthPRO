//
//  DashboardViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/19/22.
//

import UIKit

class DashboardViewController: UIViewController,WeatherInfoReceivedDelegate{
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    var theWeatherInfo:Weather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userLabel.text = "Hello: " +  UserDefaults.standard.string(forKey: "LoginUserName")!
        self.theWeatherInfo = Weather.init(delegate: self)
    }
    
    
    //delegate callback
    func gotTheWeather(theResult:Result, city:String){
        self.updateView(currentWeatherHere: theResult.current, city: city)
    }
    
    func updateView(currentWeatherHere: Current, city: String) {
        currentCity.text = city
        todayDate.text = Date.getTodaysDate()
        currentWeather.text = currentWeatherHere.weather[0].description.capitalized
        currentTemperature.text = currentWeatherHere.temp.description+" F°"
        weatherImage.image = UIImage(named: currentWeatherHere.weather[0].icon)
    }
    
}
