//
//  DashboardViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/19/22.
//

import UIKit
import MapKit

struct Result: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
    
    mutating func sortHourlyArray() {
        hourly.sort { (hour1: Hourly, hour2: Hourly) -> Bool in
            return hour1.dt < hour2.dt
        }
    }
    
    mutating func sortDailyArray() {
        daily.sort { (day1, day2) -> Bool in
            return day1.dt < day2.dt
        }
    }
}
struct Current: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let uvi: Double
    let clouds: Int
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let clouds: Int
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Temperature
    let feels_like: Feels_Like
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
    let clouds: Int
    let uvi: Double
}

struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct Feels_Like: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}


class DashboardViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    let URL_API_KEY = "fea9a5c38543416166e90cafdd440f84"
    var URL_LATITUDE = ""
    var URL_LONGITUDE = ""
    var URL_GET_ONE_CALL = ""
    let URL_BASE = "https://api.openweathermap.org/data/2.5"
    let session = URLSession(configuration: .default)
    var locationManger: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocation()
    }
    
    func getTheWeather(){
        self.getWeather(onSuccess: { (result) in
        //self.weatherResult = result
        
        //self.weatherResult?.sortDailyArray()
        //self.weatherResult?.sortHourlyArray()
        
            self.updateView(currentWeatherHere: result.current, city: self.currentCity.text!)
        
        }) { (errorMessage) in
            debugPrint(errorMessage)
        }
    }
    
    func updateView(currentWeatherHere: Current, city: String) {
        currentCity.text = city
        todayDate.text = Date.getTodaysDate()
        currentWeather.text = currentWeatherHere.weather[0].description.capitalized
        currentTemperature.text = currentWeatherHere.temp.description
        weatherImage.image = UIImage(named: currentWeatherHere.weather[0].icon)
    }

    func buildURL() -> String {
        URL_GET_ONE_CALL = "/onecall?lat=" + URL_LATITUDE + "&lon=" + URL_LONGITUDE + "&units=imperial" + "&appid=" + URL_API_KEY
        return URL_BASE + URL_GET_ONE_CALL
    }
    
    func getWeather(onSuccess: @escaping (Result) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: buildURL()) else {
            onError("Error building URL")
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response")
                    return
                }
                
                do {
                    if response.statusCode == 200 {
                        let items = try JSONDecoder().decode(Result.self, from: data)
                        onSuccess(items)
                    } else {
                        onError("Response wasn't 200. It was: " + "\n\(response.statusCode)")
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
            
        }
        task.resume()
    }
    
    func getLocation() {
       
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            
            self.URL_LATITUDE = self.currentLocation!.coordinate.latitude.description
            self.URL_LONGITUDE = self.currentLocation!.coordinate.longitude.description
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        if let city = placemark.locality {
                            self.currentCity.text = city
                        }
                    }
                }
            }
            
            getTheWeather()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
}
extension Date {
    static func getTodaysDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}
