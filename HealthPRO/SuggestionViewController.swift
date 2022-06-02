//
//  SuggestionsViewController.swift
//  HealthPRO
//
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
        
        //default to outdoor suggestion
        var weatherFlag = "outdoor";
        
        let suggestions:[Suggestion] = CoreDataHandler.init().getAllSuggestions()
    
        let user = CoreDataHandler.init().getUser()
        if user?.foodPreference == "" { //food preference not set
            
            //random number between 0 and the number of food suggestions
            let randomNumber = Int.random(in: 0..<suggestions.filter({$0.type == "food"}).count)
            self.foodSuggestion.text = suggestions.filter({$0.type == "food"})[randomNumber].suggestionText
        } else { //food preference set by user
            
            //random number between 0 and the number of food suggestions based on user preference
            let randomNumber = Int.random(in: 0..<suggestions.filter({$0.preference == user?.foodPreference}).count)
            self.foodSuggestion.text = suggestions.filter({$0.preference == user?.foodPreference})[randomNumber].suggestionText
        }
        
        // if currentWeather is snow, rain or unavailable then set it to indoor
        if (currentWeatherHere.contains("SNOW") || currentWeatherHere.contains("RAIN") || currentWeatherHere == "") {
            weatherFlag = "indoor";
        }
        
        if user?.activityPreference == "" { //activity preference not set by user
            
            //random number between 0 and the number of activity suggestions accommodating the current weather
            let randomNumber = Int.random(in: 0..<suggestions.filter({$0.type == "activity" && $0.weather == weatherFlag}).count)
            self.activitySuggestion.text = suggestions.filter({$0.type == "activity" && $0.weather == weatherFlag})[randomNumber].suggestionText
        } else { //activity preference set by user
            
            //random number between 0 and the number of activity suggestions based on user preference accommodating the current weather
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
    
    //cancel button pressed
    @objc private func cancelButtonTouchUp() {
        self.dismiss(animated: true)
    }
    
    //get the current weather
    @objc func getTheWeather() -> String {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
       
        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
            return currentWeatherHere.weather.first?.description.uppercased() ?? ""
        }

        return ""
    }
}
