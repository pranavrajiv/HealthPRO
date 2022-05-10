//
//  DashboardViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/19/22.
//

import UIKit
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
        chartView.xAxis.setLabelCount(6, force: false)
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
        
        if(!CoreDataHandler.init().doesWeightHistoryExist(forDate: Date())){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                let ac = UIAlertController(title: "Log Today's Weight", message: "Enter your current weight", preferredStyle: .alert)
                ac.addTextField { (textField) in
                    textField.placeholder = "lbs"
                    textField.textAlignment = .center
                    textField.isEnabled = false
                }
                ac.addAction(UIAlertAction(title: "Log", style: .default, handler: { action in
                    if let weightText = ac.textFields?.first?.text {
                        if weightText != "" {
                            self.logUserWeight(weight:weightText)
                        }
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(ac, animated: true, completion: {
                    if let getTextfield  = ac.textFields?.first{
                        getTextfield.resignFirstResponder()
                        getTextfield.isEnabled = true
                    }
                })
            }
        }
       
        graphView.addSubview(lineChartView)
        lineChartView.center(in: graphView)
        lineChartView.width(to: graphView)
        lineChartView.heightToWidth(of: graphView)
        setData()
    }
    
    @objc private func logUserWeight(weight:String){
        if let weightDouble = Double(weight) {
            var historyId:Int64 = -1
            if let largestWeightHistoryId = CoreDataHandler.init().getAllWeightHistory().map({$0.weightHistoryId}).max() {
                historyId = largestWeightHistoryId
            }
            _  = CoreDataHandler.init().logUserWeightHistory(historyId: historyId + 1, timeStamp: Date(), weight: weightDouble)
        }
        
    }
                                   
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Weight")
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        set1.fillAlpha = 0.8
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor = .systemRed
    }
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 5.0),
        ChartDataEntry(x: 2.0, y: 7.0),
        ChartDataEntry(x: 3.0, y: 5.0),
        ChartDataEntry(x: 4.0, y: 10.0),
        ChartDataEntry(x: 5.0, y: 6.0),
        ChartDataEntry(x: 6.0, y: 5.0),
        ChartDataEntry(x: 7.0, y: 7.0),
        ChartDataEntry(x: 8.0, y: 8.0),
        ChartDataEntry(x: 9.0, y: 12.0),
        ChartDataEntry(x: 10.0, y: 13.0),
        ChartDataEntry(x: 11.0, y: 5.0),
        ChartDataEntry(x: 12.0, y: 7.0),
        ChartDataEntry(x: 13.0, y: 3.0),
        ChartDataEntry(x: 14.0, y: 15.0),
        ChartDataEntry(x: 15.0, y: 6.0),
        ChartDataEntry(x: 16.0, y: 6.0),
        ChartDataEntry(x: 17.0, y: 7.0),
        ChartDataEntry(x: 18.0, y: 3.0),
        ChartDataEntry(x: 19.0, y: 12.0),
        ChartDataEntry(x: 20.0, y: 13.0),
        ChartDataEntry(x: 21.0, y: 15.0),
        ChartDataEntry(x: 22.0, y: 13.0),
        ChartDataEntry(x: 23.0, y: 15.0),
        ChartDataEntry(x: 24.0, y: 10.0),
        ChartDataEntry(x: 25.0, y: 10.0),
        ChartDataEntry(x: 26.0, y: 24.0),
        ChartDataEntry(x: 27.0, y: 25.0),
        ChartDataEntry(x: 28.0, y: 27.0),
    ]
    
    
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

