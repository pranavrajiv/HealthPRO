//
//  UserHistoryViewController.swift
//  HealthPRO
//
//  Created by Pranav Rajiv on 4/29/22.
//

import UIKit

class UserHistoryViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate  {

    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var userActivityHistory:[ActivityHistory]!
    var userFoodHistory:[FoodHistory]!
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if self.showAllSwitch.isOn {
                self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
                self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
            } else {
                self.datePickerChanged()
            }
            self.historyTableView.reloadData()
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.dismissButton.addTarget(self, action: #selector(dismissButtonTouchUp), for: .touchUpInside)
            self.segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
            self.datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
            self.showAllSwitch.addTarget(self, action: #selector(showAllSwitchChanged), for: .valueChanged)
            self.showAllSwitch.isOn = false
            self.historyTableView.delegate = self
            self.historyTableView.dataSource = self
            // Do any additional setup after loading the view.
        }

        @objc private func dismissButtonTouchUp() {
            self.dismiss(animated: true)
        }
    
        @objc private func showAllSwitchChanged() {
            if self.showAllSwitch.isOn {
                self.datePicker.isHidden = true
                self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
                self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
            } else {
                self.datePicker.isHidden = false
                self.datePickerChanged()
            }
            self.historyTableView.reloadData()
        }
    
        @objc private func datePickerChanged() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.historyTableView.reloadData()
        }
    
        @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            self.historyTableView.reloadData()
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                return self.userFoodHistory.count
            }
            return self.userActivityHistory.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath)
            if self.segmentedControl.selectedSegmentIndex == 0 {
                cell.accessibilityLabel = self.userFoodHistory[indexPath.row].foodHistoryId.description
                cell.textLabel?.text = self.userFoodHistory[indexPath.row].foodRelationship?.foodName
            } else {
                cell.accessibilityLabel = self.userActivityHistory[indexPath.row].activityHistoryId.description
                cell.textLabel?.text = self.userActivityHistory[indexPath.row].activityRelationship?.activityName
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Activity")
            if self.segmentedControl.selectedSegmentIndex == 0 {
                secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Food")
            }
           
            secondViewController.modalPresentationStyle = .fullScreen
            self.present(secondViewController, animated: true, completion: nil)
        }
        
        

    }
