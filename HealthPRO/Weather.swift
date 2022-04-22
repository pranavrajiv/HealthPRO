//
//  Weather.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/21/22.
//

import Foundation
import MapKit

struct Result: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
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
    let weather: [WeatherInfo]
}

struct WeatherInfo: Codable {
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
    let weather: [WeatherInfo]
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
    let weather: [WeatherInfo]
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


protocol WeatherInfoReceivedDelegate:NSObject {
    func gotTheWeather(theResult:Result, city:String)
}


class Weather: NSObject,CLLocationManagerDelegate  {
    let URL_API_KEY = "fea9a5c38543416166e90cafdd440f84"
    var latitude = ""
    var longitude = ""
    var URL_GET_ONE_CALL = ""
    let URL_BASE = "https://api.openweathermap.org/data/2.5"
    let session = URLSession(configuration: .default)
    var locationManger: CLLocationManager!
   // var currentLocation: CLLocation?
    public weak var delegate:WeatherInfoReceivedDelegate?
    
    
    //custom initializer
    public init(delegate:WeatherInfoReceivedDelegate)
    {
        super.init()
        self.delegate = delegate
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        self.getLocation()
        
        let rootLoginVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        //update weather every minute
        rootLoginVC.weatherTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
    }
    
    
    func buildURL() -> String {
        URL_GET_ONE_CALL = "/onecall?lat=" + latitude + "&lon=" + longitude + "&units=imperial" + "&appid=" + URL_API_KEY
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
    
    @objc func getLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {

            self.latitude = location.coordinate.latitude.description
            self.longitude = location.coordinate.longitude.description
            
            self.getWeather(onSuccess: { (result) in
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(location) { (places, error) in
                    self.delegate?.gotTheWeather(theResult: result, city: places?.first?.locality ?? "")
                }
            }) { (errorMessage) in
                debugPrint(errorMessage)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
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
