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
    var userWeightHistory:[WeightHistory]!
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if self.showAllSwitch.isOn {
                self.userActivityHistory = CoreDataHandler.init().getAllActivityHistory()
                self.userFoodHistory = CoreDataHandler.init().getAllFoodHistory()
                self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
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
                self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory()
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
            self.userWeightHistory = CoreDataHandler.init().getAllWeightHistory().filter({formatter.string(from: self.datePicker.date) == formatter.string(from: $0.timeStamp!)})
            self.historyTableView.reloadData()
        }
    
        @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            self.historyTableView.reloadData()
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                return self.userFoodHistory.count
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                return self.userActivityHistory.count
            }
            return self.self.userWeightHistory.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath)
            let uiLabels = cell.contentView.subviews.compactMap({ $0 as? UILabel })
                
                for cellLabel in uiLabels {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userFoodHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userFoodHistory[indexPath.row].foodHistoryId.description
                            cellLabel.text = self.userFoodHistory[indexPath.row].foodRelationship?.foodName
                        }
                    } else if self.segmentedControl.selectedSegmentIndex == 1  {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userActivityHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userActivityHistory[indexPath.row].activityHistoryId.description
                            cellLabel.text = self.userActivityHistory[indexPath.row].activityRelationship?.activityName
                        }
                    } else {
                        if cellLabel.accessibilityLabel == "historyDateAccessibilityLabel" {
                            cellLabel.text = formatter.string(from: self.userWeightHistory[indexPath.row].timeStamp!)
                            for constraints in cellLabel.constraints {
                                if constraints.identifier == "dateCreatedConstraint" {
                                    if !self.showAllSwitch.isOn {
                                        constraints.constant = 0
                                    } else {
                                        constraints.constant = 65
                                    }
                                }
                            }
                        } else {
                            cell.accessibilityLabel = self.userWeightHistory[indexPath.row].weightHistoryId.description
                            cellLabel.text = self.userWeightHistory[indexPath.row].weight.description + " lbs"
                        }
                    }
                }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Activity")
            if self.segmentedControl.selectedSegmentIndex == 0 {
                secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Food")
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                secondViewController = LogNutritionAndActivityViewController.init(historyId: Int64(Int((tableView.cellForRow(at: indexPath)?.accessibilityLabel)!)!), type: "Weight")
            }
            secondViewController.modalPresentationStyle = .fullScreen
            self.present(secondViewController, animated: true, completion: nil)
        }

    }
