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
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var graphView: UIView!
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
        //TODO Temporary button added pragmatically to prevent merge conflicts in nib file that can arise due to implementation of the charts in this VC
        let myButton = UIButton(type: .system)
        myButton.tintColor = UIColor.black
        myButton.backgroundColor = UIColor.systemBlue
        myButton.frame = CGRect(x: 10, y: 38, width: 100, height: 45)
        myButton.setTitle("Show History", for: .normal)
        myButton.addTarget(self, action: #selector(viewHistoryButtonTouchUpInside), for: .touchUpInside)
        self.view.addSubview(myButton)
        
        self.getTheWeather()
        
        if let _ = self.weatherUpdateTimer {
            self.weatherUpdateTimer.invalidate()
        }
        
        self.weatherUpdateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getTheWeather), userInfo: nil, repeats: true)
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
        self.userLabel.text = "Hello: " +  UserDefaults.standard.string(forKey: "LoginUserName")!
        //self.theWeatherInfo = Weather.init(delegate: self)
        graphView.addSubview(lineChartView)
        lineChartView.center(in: graphView)
        lineChartView.width(to: graphView)
        lineChartView.heightToWidth(of: graphView)
        setData()
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
        let currentWeatherHere = viewController.weatherInfoNow.currentWeather
        currentCity.text = viewController.weatherInfoNow.currentCity
        todayDate.text = Date.getTodaysDate()
        currentWeather.text = currentWeatherHere?.weather[0].description.capitalized
        currentTemperature.text = currentWeatherHere?.temp.description ?? ""
        if let _ = currentWeatherHere {
            currentTemperature.text! += " F°"
        }
        weatherImage.image = UIImage(named: currentWeatherHere?.weather[0].icon ?? "")
    }
    
}

