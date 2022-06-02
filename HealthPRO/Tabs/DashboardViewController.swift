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
    //timer that keeps pulling weather info every 5 seconds
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
        //check if user profile is complete to display graphs
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
    
    //clicked on suggestion button
    @objc func suggestionButtonTouchUpInside() {
        let storyboard = UIStoryboard(name: "SuggestionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "suggestionVC")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    //clicked on user history button
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
        
        //show daily weight logger
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
        // Add all of the calories consumed per day and store them in a dictionary
        let calorieDictionary = aggregateUserFoodHistory(formatter: formatter)
        // Subtract all of the calories burned per day via activities and store them in a dictionary
        var newCalorieDictionary = aggregateUserActivityHistory(formatter: formatter, calorieDictionary: calorieDictionary)
        // Calculate the user's BMR for each day that food or exercise has been logged
        var keysToRemove: [Double] = []
        var count = newCalorieDictionary.startIndex
        while count < newCalorieDictionary.endIndex {
            let (key, value) = newCalorieDictionary[count]
            let basalMetabolicRate = calculateBMR(key: key)
            if basalMetabolicRate == 0.0 {
                keysToRemove.append(key)
            }
            let newValue = value - basalMetabolicRate
            newCalorieDictionary.updateValue(newValue, forKey: key)
            newCalorieDictionary.formIndex(after: &count)
        }
        // For each day that a BMR has been calculated, subtract it from the net calories
        for key in keysToRemove {
            newCalorieDictionary.removeValue(forKey: key)
        }
        // Sort the graph data to ensure it is plotted correctly
        let sortedKeys = newCalorieDictionary.keys.sorted(by: <)
        for key in sortedKeys {
            dataEntry.append(ChartDataEntry(x: Double(key), y: Double(newCalorieDictionary[key]!)))
        }
        // Plot the net calorie data
        plotCalorieData(dataEntry: dataEntry, newCalorieDictionary: newCalorieDictionary)
        // Add limit lines showing weekly weight gain and loss with net calories consumed
        setCalorieLimitLines()
    }
    
    func aggregateUserFoodHistory(formatter: DateFormatter) -> [TimeInterval: Double] {
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
        return calorieDictionary
    }
    
    func aggregateUserActivityHistory(formatter: DateFormatter, calorieDictionary: [TimeInterval: Double]) -> [TimeInterval: Double] {
        var newCalorieDictionary = calorieDictionary
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
                if newCalorieDictionary[finalDate] != nil {
                    newCalorieDictionary[finalDate] = calorieDictionary[finalDate]! - caloriesBurned
                } else {
                    newCalorieDictionary[finalDate] = 0.0 - caloriesBurned
                }
            }
        }
        return newCalorieDictionary
    }
    
    func calculateBMR(key: Double) -> Double  {
        // Calculate the user's BMR using the user's provided data,
        // including their age, sex, height and current weight
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "YYYY-MM-dd"
        let user = CoreDataHandler.init().getUser()
        // Get the user's height and birth year data, entering a BMR of 0 if any data is not found
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
        // Calculate the individual BMR component variables: age, height, weight and gender
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
        let userWeightOnDate = findMostRecentLoggedWeight(formatter: formatter, key: key)
        // If no user weight has been logged, don't calculate the BMR
        if userWeightOnDate == 0.0 {
            let basalMetabolicRate = 0.0
            return basalMetabolicRate
        }
        let userWeightInKg = round(Double(userWeightOnDate) * 0.453592)
        let userWeightComponent = 10.0 * Double(userWeightInKg)
        let basalMetabolicRate = userWeightComponent + userHeightComponent - userAgeComponent + userGenderComponent
        return basalMetabolicRate
    }
    
    func findMostRecentLoggedWeight(formatter: DateFormatter, key: Double) -> Double {
        let entryDate = Date(timeIntervalSince1970: key)
        // If there is no weight history logged, don't calculate the BMR
        if CoreDataHandler.init().getAllWeightHistory().count == 0 {
            let userWeightOnDate = 0.0
            return userWeightOnDate
        } else {
            // Try to get weight logged on the same day of the food or exercise entries
            var userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().filter({formatter.string(from: entryDate) == formatter.string(from: $0.timeStamp!)}).first?.weight
            // If nothing is found, try to get the last logged weight with timestamp less than the current entry's timestamp
            if (userWeightOnDate == nil) {
                userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().last(where: {$0.timeStamp! < entryDate})?.weight
            }
            // If nothing is found again, try to get the first logged weight with timestamp greater than the current entry's timestamp
            if (userWeightOnDate == nil) {
                userWeightOnDate = CoreDataHandler.init().getAllWeightHistory().first(where: {$0.timeStamp! > entryDate})?.weight
            }
            // Unwrap and return the result. If it is still nil, return 0.0 for the weight
            return userWeightOnDate ?? 0.0
        }
    }
    
    func plotCalorieData(dataEntry: [ChartDataEntry], newCalorieDictionary: [TimeInterval: Double]) {
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
        let sortedValues = newCalorieDictionary.values.sorted(by: <)
        if sortedValues.count != 0 {
            lineChartView.leftAxis.axisMinimum = Double(sortedValues.first!) - 100.0
            lineChartView.leftAxis.axisMaximum = Double(sortedValues.last!) + 100.0
        }
    }
    
    func setCalorieLimitLines() {
        // 3500 calories per week translates to 1 lb of weight gain or loss per week
        // Here we'll show what that looks like on a per-day basis (divide weekly amounts by 7)
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
    }
    
    func setWeightData() {
        lineChartView.leftAxis.removeAllLimitLines()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        // Get all of the user's weight history, including weights and timestamps
        userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
        var dataEntry: [ChartDataEntry] = []
        var valueData: [Double] = []
        for entry in userWeightHistory{
            let finalDate = roundWeightDates(formatter: formatter, entry: entry)
            if finalDate != 0.0 {
                // Append both the weight and date to the graph data
                dataEntry.append(ChartDataEntry(x: Double(finalDate), y: Double(entry.weight)))
                valueData.append(Double(entry.weight))
            }
        // Plot the data and associated limit lines
        plotWeightData(dataEntry: dataEntry, valueData: valueData)
        // Calculate and display limit lines for minimum and maximum safe weights
        setWeightLimitLines()
        }
    }
    
    func plotWeightData(dataEntry: [ChartDataEntry], valueData: [Double]) {
        // Set the Y axis label and load dataEntry into the first line chart dataset
        let set1 = LineChartDataSet(entries: dataEntry, label: "Logged Weight")
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
        let sortedData = valueData.sorted(by: <)
        if sortedData.count != 0 {
            lineChartView.leftAxis.axisMinimum = Double(sortedData.first!) - 20.0
            lineChartView.leftAxis.axisMaximum = Double(sortedData.last!) + 20.0
        }
    }
    
    func setWeightLimitLines() {
        // Calculate the maximum and minimum safe weights to plot alongside the user's logged weights
        let user = CoreDataHandler.init().getUser()
        let userHeightInches = user?.height.description
        let userHeightMeters = Double(userHeightInches!)! * 0.0254
        let userHeightMetersSquared = Double(userHeightMeters) * Double(userHeightMeters)
        let minimumSafeWeightKilograms = 18.5 * Double(userHeightMetersSquared)
        let maximumSafeWeightKilograms = 24.9 * Double(userHeightMetersSquared)
        let minimumSafeWeightPounds = 2.20462 * Double(minimumSafeWeightKilograms)
        let maximumSafeWeightPounds = 2.20462 * Double(maximumSafeWeightKilograms)
        let lowerTargetLine = ChartLimitLine(limit: minimumSafeWeightPounds, label: "Minimum healthy weight")
        let upperTargetLine = ChartLimitLine(limit: maximumSafeWeightPounds, label: "Maximum healthy weight")
        // Don't display the upper and lower safe weights if the user hasn't set their height yet
        if Double(userHeightInches!) != 0.0 {
            lineChartView.leftAxis.addLimitLine(lowerTargetLine)
            lineChartView.leftAxis.addLimitLine(upperTargetLine)
            lineChartView.leftAxis.axisMinimum = minimumSafeWeightPounds - 10.0
            lineChartView.leftAxis.axisMaximum = maximumSafeWeightPounds + 10.0
        }
    }
    
    func roundWeightDates(formatter:  DateFormatter, entry: WeightHistory) -> TimeInterval {
        var finalDate: TimeInterval = 0.0
        // Convert timestamp to epoch time
        let dateAsDouble = entry.timeStamp!.timeIntervalSince1970
        let myDate = Date(timeIntervalSince1970: dateAsDouble)
        formatter.dateFormat = "YYYY-MM-dd"
        let strDate = formatter.string(from: myDate)
        if let roundedDate = formatter.date(from: strDate) {
            finalDate = roundedDate.timeIntervalSince1970
        }
        return finalDate
    }
    
    //get the weather from LoginViewController
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
