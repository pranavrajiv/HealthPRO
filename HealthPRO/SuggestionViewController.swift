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

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activitySuggestion: UILabel!
    @IBOutlet weak var foodSuggestion: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: .touchUpInside)
        self.activitySuggestion.text = ""
        self.foodSuggestion.text = ""
        
        //let currentWeatherHere:String = self.getTheWeather()
        var outdoorOkay = true;
        
        let suggestions:[Suggestion] = CoreDataHandler.init().getAllSuggestions()
    
        let user = CoreDataHandler.init().getUser()
        if user?.foodPreference == "" {
            self.foodSuggestion.text = suggestions.filter({$0.type == "food"})[Int.random(in: 0..<suggestions.filter({$0.type == "food"}).count)].suggestionText
        } else {
            self.foodSuggestion.text = suggestions.filter({$0.preference == user?.foodPreference})[Int.random(in: 0..<suggestions.filter({$0.preference == user?.foodPreference}).count)].suggestionText
        }
        
        if user?.activityPreference == "" {
            self.activitySuggestion.text = suggestions.filter({$0.type == "activity"})[Int.random(in: 0..<suggestions.filter({$0.type == "activity"}).count)].suggestionText
        } else {
            self.activitySuggestion.text = suggestions.filter({$0.preference == user?.activityPreference})[Int.random(in: 0..<suggestions.filter({$0.preference == user?.activityPreference}).count)].suggestionText
        }
        
//        if (currentWeatherHere.contains("SNOW") || currentWeatherHere.contains("RAIN")) {
//            outdoorOkay = false;
//        }
        
        //TODO: load in user's preference, load in suggestions and filter based on user preference and weather flag
        //TODO: present suggestion results per Storyboard format
        
       
        
        //Uncomment this line once the close button is implemented for this VC otherwise there is a chance for a memory leak due to the timers not getting invalidated
        //self.weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getTheWeather), userInfo: nil, repeats: true)
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
    
//    @objc func getTheWeather() -> String {
//        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
//
//        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
//            return currentWeatherHere.weather[0].description.capitalized
//        }
//
//        return ""
//    }
}
