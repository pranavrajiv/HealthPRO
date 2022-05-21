//
//  SuggestionsViewController.swift
//  HealthPRO
//
//  Created by CIS 498 on 5/7/22.
//

import UIKit

class SuggestionsViewController: UIViewController{
    var weatherUpdateTimer:Timer!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activitySuggestion: UILabel!
    @IBOutlet weak var foodSuggestion: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
        self.activitySuggestion.text = ""
        self.foodSuggestion.text = ""
        
        let currentWeatherHere:String = self.getTheWeather()
        var weatherFlag = "outdoor";
        
        let suggestions:[Suggestion] = CoreDataHandler.init().getAllSuggestions()
    
        let user = CoreDataHandler.init().getUser()
        if user?.foodPreference == "" {
            self.foodSuggestion.text = suggestions.filter({$0.type == "food"})[Int.random(in: 0..<suggestions.filter({$0.type == "food"}).count)].suggestionText
        } else {
            self.foodSuggestion.text = suggestions.filter({$0.preference == user?.foodPreference})[Int.random(in: 0..<suggestions.filter({$0.preference == user?.foodPreference}).count)].suggestionText
        }
        
        if (currentWeatherHere.contains("SNOW") || currentWeatherHere.contains("RAIN") || currentWeatherHere == "") {
            weatherFlag = "indoor";
        }
        
        if user?.activityPreference == "" {
            let randomNumber = Int.random(in: 0..<suggestions.filter({$0.type == "activity" && $0.weather == weatherFlag}).count)
            self.activitySuggestion.text = suggestions.filter({$0.type == "activity" && $0.weather == weatherFlag})[randomNumber].suggestionText
        } else {
            let randomNumber = Int.random(in: 0..<suggestions.filter({$0.preference == user?.activityPreference && $0.weather == weatherFlag }).count)
            self.activitySuggestion.text = suggestions.filter({$0.preference == user?.activityPreference && $0.weather == weatherFlag })[randomNumber].suggestionText
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    @objc func getTheWeather() -> String {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
       
        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
            return currentWeatherHere.weather[0].description.uppercased()
        }

        return ""
    }
}
