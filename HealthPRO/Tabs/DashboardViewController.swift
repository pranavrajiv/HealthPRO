//
//  DashboardViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/19/22.
//

import UIKit
import Foundation
import Charts
import TinyConstraints

class DashboardViewController: UIViewController{
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var suggestionsButton: UIButton!
    var weatherUpdateTimer:Timer!
    var userWeightHistory:[WeightHistory]!
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        //chartView.xAxis.setLabelCount(6, force: true)
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.axisLineColor = .systemBlue
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
        setData()
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
            let controller = WeightInfoViewController.init(popOverHeading: "Log Daily Weight", popOverMessage: "Enter Today's Weight", button1Label: "Log",button2Label: "", button3Label: "Cancel", weightHistoryId: -1)
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
        lineChartView.heightToWidth(of: graphView)
    }

                                   
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        // Get all of the user's weight history, including weights and timestamps
        userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
        var dataEntry: [ChartDataEntry] = []
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
            }
        }
        // Set the Y axis label
        let set1 = LineChartDataSet(entries: dataEntry, label: "Weight")
        set1.mode = .cubicBezier
        // Prevent the graph from drawing circles around each data point
        //set1.drawCirclesEnabled = false
        // Set the line width
        set1.lineWidth = 3
        // Set the line color
        set1.setColor(.white)
        // Fill in the area underneath the line chart
        set1.drawFilledEnabled = true
        // Set the under-line fill color
        set1.fill = Fill(color: .white)
        // Set the fill transparency
        set1.fillAlpha = 0.8
        let data = LineChartData(dataSet: set1)
        // Don't display each data point's value on the graph
        //data.setDrawValues(false)
        lineChartView.data = data
        // Display dates in a human-readable format instead of epoch time
        lineChartView.xAxis.valueFormatter = ChartFormatter()
        // Disable user interaction with the chart
        lineChartView.isUserInteractionEnabled = false
        // Show a date for every entry on the graph to ensure they are aligned correctly
        lineChartView.xAxis.setLabelCount(dataEntry.count, force: true)
    }
    
    @objc func getTheWeather() {
        let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController as! LoginViewController
        todayDate.text = Date.getTodaysDate()
        currentCity.text = viewController.weatherInfoNow.currentCity
        if let currentWeatherHere  = viewController.weatherInfoNow.currentWeather {
            currentWeather.text = currentWeatherHere.weather[0].description.capitalized
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

extension DashboardViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
