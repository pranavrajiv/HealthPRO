//
//  DashboardViewController.swift
//  HealthPRO
//
//

import UIKit
import Foundation
import Charts
import TinyConstraints

class DashboardViewController: UIViewController{
    @IBOutlet weak var emptyGraphLabel: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var suggestionsButton: UIButton!
    @IBOutlet weak var graphViewButton: UISegmentedControl!
    var weatherUpdateTimer:Timer!
    var userWeightHistory:[WeightHistory]!
    var userActivityHistory:[ActivityHistory]!
    var userFoodHistory:[FoodHistory]!
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.labelPosition = .outsideChart
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        //chartView.xAxis.setLabelCount(6, force: true)
        chartView.xAxis.labelTextColor = .black
        chartView.xAxis.axisLineColor = .black
        chartView.animate(xAxisDuration: 2.5)
        return chartView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.getTheWeather()
        
        if let _ = self.weatherUpdateTimer {
            self.weatherUpdateTimer.invalidate()
        }
        
        self.weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getTheWeather), userInfo: nil, repeats: true)
        if graphViewButton.selectedSegmentIndex == 0 {
            setWeightData()
            lineChartView.notifyDataSetChanged()
        } else {
            setCalorieData()
            lineChartView.notifyDataSetChanged()
        }
        
        
        let user = CoreDataHandler.init().getUser()
        if user?.height == 0.0 || user?.weight == 0.0 || user?.birthYear == 0 {
            self.lineChartView.isHidden = true
            self.emptyGraphLabel.isHidden = false
        } else {
            self.lineChartView.isHidden = false
            self.emptyGraphLabel.isHidden = true
        }
        
    }
    
    // Notifies when user switched between weight and calorie graphs
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setWeightData()
            lineChartView.notifyDataSetChanged()
        } else {
            setCalorieData()
            lineChartView.notifyDataSetChanged()
        }
    }
    
    @objc func suggestionButtonTouchUpInside() {
        let storyboard = UIStoryboard(name: "SuggestionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "suggestionVC")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func viewHistoryButtonTouchUpInside() {
        
        let storyboard = UIStoryboard(name: "UserHistoryViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "userHistoryVC")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.weatherUpdateTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.historyButton.addTarget(self, action: #selector(viewHistoryButtonTouchUpInside), for: .touchUpInside)
        self.suggestionsButton.addTarget(self, action: #selector(suggestionButtonTouchUpInside), for: .touchUpInside)
        
        //show weight logger
        if(!CoreDataHandler.init().doesWeightHistoryExist(forDate: Date())){
            let controller = WeightInfoViewController.init(popOverHeading: "Log Daily Weight", popOverMessage: "Enter Today's Weight", button1Label: "Log",button2Label: "", button3Label: "Cancel",delegate: self ,weightHistoryId: -1)
            
            controller.modalPresentationStyle = .popover
            
            if let popover = controller.popoverPresentationController {
                popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
               
                popover.sourceView = self.view

               // the position of the popover where it's showed
                popover.sourceRect = CGRect(x: 20, y: 400, width: 0, height: 0)

               // the size you want to display
                controller.preferredContentSize = CGSize(width: self.view.frame.width - 40, height: 200)
               popover.delegate = self
            }
            self.present(controller, animated: true, completion: nil)
        }
        
        // Add the lineChartView to the graphView as a subview; this allows
        // us to sidestep the compatibility issues between Charts and Xcode 13 that don't permit using Storyboard for the UI
        graphView.addSubview(lineChartView)
        // Here we'll use TinyConstraints to set the view constraints on our graph. Since we can't use
        // Storyboard proper to set limits, we'll instead use code-based constraints
        lineChartView.center(in: graphView)
        lineChartView.width(to: graphView)
        lineChartView.height(to: graphView)
        // Change the graph view if the segment button is changed
        graphViewButton.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
    }

                                   
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setCalorieData() {
        lineChartView.leftAxis.removeAllLimitLines()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "YYYY-MM-dd"
        // Get all of the user's activity and food history, including weights and timestamps
        userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
        userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
        // Calculate the maximum and minimum safe weights to plot alongside the user's logged weights
        var dataEntry: [ChartDataEntry] = []
        var calorieDictionary: [TimeInterval: Double] = [:]
        for entry in userFoodHistory {
            // Convert timestamp to epoch time
            let dateAsDouble = entry.timeStamp!.timeIntervalSince1970
            let myDate = Date(timeIntervalSince1970: dateAsDouble)
            let strDate = formatter.string(from: myDate)
            if let roundedDate = formatter.date(from: strDate) {
                let finalDate = roundedDate.timeIntervalSince1970
                let numServings = entry.serviceSize
                let foodEntry = entry.foodRelationship
                let numCaloriesPerServing = (foodEntry?.calories)!
                // Calculate the number of calories consumed by multiplying the number of portions consumed by the number of calories
                // per portion
                let caloriesConsumed = Double(numServings) * Double(numCaloriesPerServing)
                if calorieDictionary[finalDate] != nil {
                    calorieDictionary[finalDate] = calorieDictionary[finalDate]! + caloriesConsumed
                } else {
                    calorieDictionary[finalDate] = caloriesConsumed
                }
            }
        }
        for entry in userActivityHistory {
            // Convert timestamp to epoch time
            let dateAsDouble = entry.timeStamp!.timeIntervalSince1970
            let myDate = Date(timeIntervalSince1970: dateAsDouble)
            let strDate = formatter.string(from: myDate)
            if let roundedDate = formatter.date(from: strDate) {
                let finalDate = roundedDate.timeIntervalSince1970
                let activityDuration = entry.duration

                let activityEntry = entry.activityRelationship
                let caloriesPerHourPerLb = (activityEntry?.caloriesPerHourPerLb)!
                // If there is no weight entry for any day skip processing
                if CoreDataHandler.init().getAllWeightHistory().count == 0 {
                    continue
                }
                
                //get the logged weight for the day that the activity was logged
                var userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().filter({formatter.string(from: roundedDate) == formatter.string(from: $0.timeStamp!)}).first?.weight
                
                //get the last logged weight with timestamp less than the current entry's timestamp
                if (userWeightOnDate == nil) {
                    userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().last(where: {$0.timeStamp! < entry.timeStamp!})?.weight
                }
                
                //get the first logged weight with timestamp greater than the current entry's timestamp
                if (userWeightOnDate == nil) {
                    userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().first(where: {$0.timeStamp! > entry.timeStamp!})?.weight
                }
                
                // Calculate the number of calories burned by multiplying the user's weight on that day by the activity by calories
                // per hour per pound by the activity duration in hours
                let caloriesBurned = Double(caloriesPerHourPerLb) * Double(activityDuration) * Double(userWeightOnDate ?? 0.0)
                if calorieDictionary[finalDate] != nil {
                    calorieDictionary[finalDate] = calorieDictionary[finalDate]! - caloriesBurned
                } else {
                    calorieDictionary[finalDate] = 0.0 - caloriesBurned
                }
            }
        }
        var keysToRemove: [Double] = []
        var count = calorieDictionary.startIndex
        while count < calorieDictionary.endIndex {
            let (key, value) = calorieDictionary[count]
            let basalMetabolicRate = calculateBMR(key: key)
            if basalMetabolicRate == 0.0 {
                keysToRemove.append(key)
            }
            let newValue = value - basalMetabolicRate
            calorieDictionary.updateValue(newValue, forKey: key)
            calorieDictionary.formIndex(after: &count)
        }
        for key in keysToRemove {
            calorieDictionary.removeValue(forKey: key)
        }
        
        let sortedKeys = calorieDictionary.keys.sorted(by: <)
        for key in sortedKeys {
            dataEntry.append(ChartDataEntry(x: Double(key), y: Double(calorieDictionary[key]!)))
        }
        // Set the Y axis label and load dataEntry into the first line chart dataset
        let set1 = LineChartDataSet(entries: dataEntry, label: "Net Calories")
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.black)
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
        // Display dates in a human-readable format instead of epoch time
        lineChartView.xAxis.valueFormatter = ChartFormatter()
        //Rotate x axis label to prevent clipping off the side of the graph
        lineChartView.xAxis.labelRotationAngle = 90.0
        // Disable user interaction with the chart
        lineChartView.isUserInteractionEnabled = false
        // Show a date for every entry on the graph to ensure they are aligned correctly
        lineChartView.xAxis.setLabelCount(dataEntry.count, force: true)
        let oneLbGain = ChartLimitLine(limit: 500, label: "Gain 1 lb/week")
        let twoLbGain = ChartLimitLine(limit: 1000, label: "Gain 2 lbs/week")
        let unsafeGain = ChartLimitLine(limit: 1500, label: "Unsafe weight gain")
        let oneLbLoss = ChartLimitLine(limit: -500, label: "Lose 1 lb/week")
        let twoLbLoss = ChartLimitLine(limit: -1000, label: "Lose 2 lbs/week")
        let unsafeLoss = ChartLimitLine(limit: -1500, label: "Unsafe weight loss")
        lineChartView.leftAxis.addLimitLine(oneLbLoss)
        lineChartView.leftAxis.addLimitLine(twoLbLoss)
        lineChartView.leftAxis.addLimitLine(unsafeLoss)
        lineChartView.leftAxis.addLimitLine(oneLbGain)
        lineChartView.leftAxis.addLimitLine(twoLbGain)
        lineChartView.leftAxis.addLimitLine(unsafeGain)
        let sortedValues = calorieDictionary.values.sorted(by: <)
        if sortedValues.count != 0 {
            lineChartView.leftAxis.axisMinimum = Double(sortedValues.first!) - 100.0
            lineChartView.leftAxis.axisMaximum = Double(sortedValues.last!) + 100.0
        }
    }
    
    func calculateBMR(key: Double) -> Double  {
        // Calculate the user's BMR using the user's provided data,
        // including their age, sex, height and current weight
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "YYYY-MM-dd"
        let user = CoreDataHandler.init().getUser()
        let userHeightInches = user?.height.description
        if Double(userHeightInches!) == 0.0 {
            let basalMetabolicRate = 0.0
            return basalMetabolicRate
        }
        let userBirthYear = Int((user?.birthYear.description)!)
        if Double(userBirthYear!) == 0.0 {
            let basalMetabolicRate = 0.0
            return basalMetabolicRate
        }
        let currentYear = Int(Calendar.current.component(.year, from: Date()))
        let userAge = currentYear - userBirthYear!
        let userHeightCentimeters = round(Double(userHeightInches!)! * 2.54)
        let userHeightComponent = 6.25 * userHeightCentimeters
        let userAgeComponent = 5.0 * Double(userAge)
        var userGenderComponent = 0.0
        if user?.gender == "M" {
            userGenderComponent = 5.0
        }
        if user?.gender == "F" {
            userGenderComponent = -161.0
        }
        // If the user hasn't set their gender, don't calculate the BMR
        if userGenderComponent == 0.0 {
            let basalMetabolicRate = 0.0
            return basalMetabolicRate
        }
        let entryDate = Date(timeIntervalSince1970: key)
        // If there is no weight history logged, don't calculate the BMR
        if CoreDataHandler.init().getAllWeightHistory().count == 0 {
            let basalMetabolicRate = 0.0
            return basalMetabolicRate
        } else {
            var userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().filter({formatter.string(from: entryDate) == formatter.string(from: $0.timeStamp!)}).first?.weight
            
            //get the last logged weight with timestamp less than the current entry's timestamp
            if (userWeightOnDate == nil) {
                userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().last(where: {$0.timeStamp! < entryDate})?.weight
            }
            
            //get the first logged weight with timestamp greater than the current entry's timestamp
            if (userWeightOnDate == nil) {
                userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().first(where: {$0.timeStamp! > entryDate})?.weight
            }
            
            //if userWeightOnDate is still nil return 0.0
            if (userWeightOnDate == nil) {
                let basalMetabolicRate = 0.0
                return basalMetabolicRate
            }
            
            
            let userWeightInKg = round(Double(userWeightOnDate!) * 0.453592)
            let userWeightComponent = 10.0 * Double(userWeightInKg)
            let basalMetabolicRate = userWeightComponent + userHeightComponent - userAgeComponent + userGenderComponent
            return basalMetabolicRate
        }
    }
    
    func setWeightData() {
        lineChartView.leftAxis.removeAllLimitLines()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        // Get all of the user's weight history, including weights and timestamps
        userWeightHistory = CoreDataHandler.init().getAllWeightHistory()

        // Calculate the maximum and minimum safe weights to plot alongside the user's logged weights
        let user = CoreDataHandler.init().getUser()
        let userHeightInches = user?.height.description
        let userHeightMeters = Double(userHeightInches!)! * 0.0254
        let userHeightMetersSquared = Double(userHeightMeters) * Double(userHeightMeters)
        let minimumSafeWeightKilograms = 18.5 * Double(userHeightMetersSquared)
        let maximumSafeWeightKilograms = 24.9 * Double(userHeightMetersSquared)
        let minimumSafeWeightPounds = 2.20462 * Double(minimumSafeWeightKilograms)
        let maximumSafeWeightPounds = 2.20462 * Double(maximumSafeWeightKilograms)
        var dataEntry: [ChartDataEntry] = []
        var valueData: [Double] = []
        for entry in userWeightHistory{
            // Convert timestamp to epoch time
            let dateAsDouble = entry.timeStamp!.timeIntervalSince1970
            let myDate = Date(timeIntervalSince1970: dateAsDouble)
            formatter.dateFormat = "YYYY-MM-dd"
            let strDate = formatter.string(from: myDate)
            if let roundedDate = formatter.date(from: strDate) {
                let finalDate = roundedDate.timeIntervalSince1970
                // Append both the weight and date to the graph data
                dataEntry.append(ChartDataEntry(x: Double(finalDate), y: Double(entry.weight)))
                valueData.append(Double(entry.weight))
            }
        }
        // Set the Y axis label and load dataEntry into the first line chart dataset
        let set1 = LineChartDataSet(entries: dataEntry, label: "Logged Weight")
        let lowerTargetLine = ChartLimitLine(limit: minimumSafeWeightPounds, label: "Minimum healthy weight")
        let upperTargetLine = ChartLimitLine(limit: maximumSafeWeightPounds, label: "Maximum healthy weight")
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.black)
        let data = LineChartData(dataSet: set1)
        // Don't display the upper and lower safe weights if the user hasn't set their height yet
        if Double(userHeightInches!) != 0.0 {
            lineChartView.leftAxis.addLimitLine(lowerTargetLine)
            lineChartView.leftAxis.addLimitLine(upperTargetLine)
            lineChartView.leftAxis.axisMinimum = minimumSafeWeightPounds - 10.0
            lineChartView.leftAxis.axisMaximum = maximumSafeWeightPounds + 10.0
        }
        lineChartView.data = data
        // Display dates in a human-readable format instead of epoch time
        lineChartView.xAxis.valueFormatter = ChartFormatter()
        //Rotate x axis label to prevent clipping off the side of the graph
        lineChartView.xAxis.labelRotationAngle = 90.0
        // Disable user interaction with the chart
        lineChartView.isUserInteractionEnabled = false
        // Show a date for every entry on the graph to ensure they are aligned correctly
        lineChartView.xAxis.setLabelCount(dataEntry.count, force: true)
        let sortedData = valueData.sorted(by: <)
        if sortedData.count != 0 {
            lineChartView.leftAxis.axisMinimum = Double(sortedData.first!) - 20.0
            lineChartView.leftAxis.axisMaximum = Double(sortedData.last!) + 20.0
        }
    }
    
    @objc func getTheWeather() {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        todayDate.text = Date.getTodaysDate()
        currentCity.text = viewController.weatherInfoNow.currentCity
        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
            currentWeather.text = currentWeatherHere.weather[0].description.uppercased()
            currentTemperature.text = currentWeatherHere.temp.description + " F°"
            weatherImage.image = UIImage(named: currentWeatherHere.weather[0].icon)
        }
        
    }
    
}

// Format dates as human-readable strings once they have been loaded into the chart data
public class ChartFormatter: NSObject, IAxisValueFormatter {

    var weightData = [String]()

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: value))
        return date
    }
    
    public func setValues(values: [String]) {
        self.weightData = values
    }
    
}

extension DashboardViewController: UIPopoverPresentationControllerDelegate,WeightDelegate {

    @objc func weightInfoUpdated() {
        if graphViewButton.selectedSegmentIndex == 0 {
            setWeightData()
            lineChartView.notifyDataSetChanged()
        } else {
            setCalorieData()
            lineChartView.notifyDataSetChanged()
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
