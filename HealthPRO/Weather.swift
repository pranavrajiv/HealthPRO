//
//  Weather.swift
//  HealthPRO
//
//

import Foundation
import MapKit

//part of the json struct that the weather api response conforms to
struct Result: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
}

//part of the json struct that the weather api response conforms to
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

//part of the json struct that the weather api response conforms to
struct WeatherInfo: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

//part of the json struct that the weather api response conforms to
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

//part of the json struct that the weather api response conforms to
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

//part of the json struct that the weather api response conforms to
struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

//part of the json struct that the weather api response conforms to
struct Feels_Like: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

//weather delegate function
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
    var weatherInfoNowTimer:Timer!
    public weak var delegate:WeatherInfoReceivedDelegate?
    
    //custom initializer
    public init(delegate:WeatherInfoReceivedDelegate)
    {
        super.init()
        self.delegate = delegate
        
        //instantiate locationManager
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        self.getLocation()
        self.weatherInfoNowTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
    }
    
    //creates the url to send request to the weather api
    func buildURL() -> String {
        URL_GET_ONE_CALL = "/onecall?lat=" + latitude + "&lon=" + longitude + "&units=imperial" + "&appid=" + URL_API_KEY
        return URL_BASE + URL_GET_ONE_CALL
    }
    
    //send the request to weather api to get the weather
    func getWeather(onSuccess: @escaping (Result) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: buildURL()) else {
            var notificationInfo: [AnyHashable: Any] = [:]
            notificationInfo["message"] = "Error building URL for weather api"
            NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
            onError("Error building URL")
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    var notificationInfo: [AnyHashable: Any] = [:]
                    notificationInfo["message"] = "Weather API error: " + error.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    var notificationInfo: [AnyHashable: Any] = [:]
                    notificationInfo["message"] = "Weather API error: Invalid data or response"
                    NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
                    onError("Invalid data or response")
                    return
                }
                
                do {
                    if response.statusCode == 200 {
                        let items = try JSONDecoder().decode(Result.self, from: data)
                        onSuccess(items)
                    } else {
                        var notificationInfo: [AnyHashable: Any] = [:]
                        notificationInfo["message"] = "Weather API error: Response wasn't 200. It was: " + "\n\(response.statusCode)"
                        NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
                        onError("Response wasn't 200. It was: " + "\n\(response.statusCode)")
                    }
                } catch {
                    var notificationInfo: [AnyHashable: Any] = [:]
                    notificationInfo["message"] = "Weather API error: "+error.localizedDescription
                    NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
                    onError(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    //function request location
    @objc func getLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
        }
    }
    
    //locationManager updated location and gets the weather
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
                var notificationInfo: [AnyHashable: Any] = [:]
                notificationInfo["message"] = "Unable to update location due to the following error: "+errorMessage.description
                NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
                debugPrint(errorMessage)
            }
        }
    }
    
    //locationManager failed
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        var notificationInfo: [AnyHashable: Any] = [:]
        notificationInfo["message"] = "LocationManager failed due to the following error: "+error.localizedDescription
        NotificationCenter.default.post(name: NSNotification.Name("LogError"), object: nil, userInfo: notificationInfo)
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
